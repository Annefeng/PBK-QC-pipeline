#!/bin/bash

preqcdir=$1
pcadir=$2
ref=$3
fhighld_region=$4
scrdir=$5

# ref=/data/js95/yfeng/utility/1kG/ALL.1KG_phase3.20130502.genotypes.maf005

PLINK=/data/js95/shared_software/plink

cd $pcadir

###############################
# [ PCA with reference data ] #
###############################

# Find SNPs in common between study sample and ref sample
awk 'NR==FNR{a[$0];next} ($0 in a)' $preqcdir/pbk_btqc_mgqc-rsid.bim $ref.bim > pbk_ref.common.snplist

# Retain only overlapping SNPs (do this separately for each file; necessary step before merging b/c bmerge does not retain only overlapping SNPs)
$PLINK \
--bfile $preqcdir/pbk_btqc_mgqc-rsid \
--extract pbk_ref.common.snplist \
--make-bed \
--out pbk-tmp

$PLINK \
--bfile $ref \
--extract pbk_ref.common.snplist \
--make-bed \
--out ref-tmp

# Merge study sample with ref panel
$PLINK --bfile pbk-tmp \
--keep-allele-order \
--bmerge ref-tmp \
--make-bed \
--out pbk_ref

rm *tmp*

# If there are strand-flipping or multi-allelic SNPs...exclude them and repeat the steps (shouldn't be too many)
if [ -f pbk_ref-merge.missnp ]; then
    
    mv pbk_ref.log pbk_ref-merge.log

    $PLINK \
    --bfile $preqcdir/pbk_btqc_mgqc-rsid \
    --extract pbk_ref.common.snplist \
    --exclude pbk_ref-merge.missnp \
    --make-bed \
    --out pbk-tmp

    $PLINK \
    --bfile $ref \
    --extract pbk_ref.common.snplist \
    --exclude pbk_ref-merge.missnp \
    --make-bed \
    --out ref-tmp

    $PLINK \
    --bfile pbk-tmp \
    --keep-allele-order \
    --bmerge ref-tmp \
    --make-bed \
    --out pbk_ref

    rm *tmp*
fi


# Find strand ambiguous SNPs
python $scrdir/find_atgc_snps.py pbk_ref.bim > pbk_ref.atgc.snplist

# Write a list of non-strand ambiguous SNPs to keep
awk 'NR==FNR{a[$1];next} !($2 in a) {print $2}' pbk_ref.atgc.snplist pbk_ref.bim > pbk_ref.non-atgc.snplist


# Perform LD pruning
$PLINK \
--bfile pbk_ref \
--autosome \
--geno 0.02 \
--maf 0.05 \
--snps-only just-acgt \
--extract pbk_ref.non-atgc.snplist \
--exclude range $fhighld_region \
--indep-pairwise 200 100 0.1 \
--out pbk_ref-ldpr


# Run pca
$PLINK \
--bfile pbk_ref \
--extract pbk_ref-ldpr.prune.in \
--pca 20 header tabs \
--out pbk_ref.pca



#############################
#  [ PCA on study sample ]  #
#############################

# Find strand ambiguous SNPs
python $scrdir/find_atgc_snps.py $preqcdir/pbk_btqc_mgqc-rsid.bim > pbk_btqc_mgqc-rsid.atgc.snplist

# Write a list of non-strand ambiguous SNPs to keep
awk 'NR==FNR{a[$1];next} !($2 in a) {print $2}' pbk_btqc_mgqc-rsid.atgc.snplist $preqcdir/pbk_btqc_mgqc-rsid.bim > pbk_btqc_mgqc-rsid.non-atgc.snplist

# Perform LD pruning
$PLINK \
--bfile $preqcdir/pbk_btqc_mgqc-rsid \
--autosome \
--geno 0.02 \
--maf 0.05 \
--snps-only just-acgt \
--extract pbk_btqc_mgqc-rsid.non-atgc.snplist \
--exclude range $fhighld_region \
--indep-pairwise 200 100 0.1 \
--out pbk_btqc_mgqc-rsid

# Run pca
$PLINK \
--bfile pbk_btqc_mgqc-rsid \
--pca 20 header tabs \
--out pbk_btqc_mgqc-rsid.pca

