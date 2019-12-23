#!/bin/bash

module load R/3.4.0
source ~/R-3.4.0-ownlib.bash

pop=$1
pop_preqcdir=$2
pop_pcadir=$3
ref=$4
fhighld_region=$5
scrdir=$6


PLINK=/data/js95/shared_software/plink

cd $pop_pcadir

#############################
#  [ PCA on study sample ]  #
#############################

# Find strand ambiguous SNPs
python $scrdir/find_atgc_snps.py $pop_preqcdir/${pop}_pbk_btqc_mgqc-rsid.bim > ${pop}_pbk_btqc_mgqc-rsid.atgc.snplist

cat ${pop}_pbk_btqc_mgqc-rsid.atgc.snplist $pop_preqcdir/${pop}_pbk_batch_assoc_pe-04.snplist | sort | uniq > ${pop}_pbk_btqc_mgqc-rsid.remove.snplist

awk 'NR==FNR{a[$1];next} !($2 in a) {print $2}' ${pop}_pbk_btqc_mgqc-rsid.remove.snplist $pop_preqcdir/${pop}_pbk_btqc_mgqc-rsid.bim > ${pop}_pbk_btqc_mgqc-rsid.keep.snplist


# Perform LD pruning
$PLINK \
--bfile $pop_preqcdir/${pop}_pbk_btqc_mgqc-rsid \
--autosome \
--geno 0.02 \
--maf 0.05 \
--snps-only just-acgt \
--remove $pop_preqcdir/${pop}_pbk_sexcheck_het_ibd.remove.indlist \
--extract ${pop}_pbk_btqc_mgqc-rsid.keep.snplist \
--exclude range $fhighld_region \
--indep-pairwise 200 100 0.1 \
--out ${pop}_pbk_unrel-ldpr

# Run pca
$PLINK \
--bfile $pop_preqcdir/${pop}_pbk_btqc_mgqc-rsid \
--remove $pop_preqcdir/${pop}_pbk_sexcheck_het_ibd.remove.indlist \
--extract ${pop}_pbk_unrel-ldpr.prune.in \
--pca 20 header tabs \
--out ${pop}_pbk_unrel.pca


rm ${pop}_pbk_btqc_mgqc-rsid.remove.snplist
rm ${pop}_pbk_btqc_mgqc-rsid.keep.snplist




###############################
# [ PCA with reference data ] #
###############################

ref=/data/js95/yfeng/utility/1kG/ALL.1KG_phase3.20130502.genotypes.maf005

# Subset to EUR samples in the ref panel
if [ pop == "eur" ]; then 
    awk '$1=="CEU" || $1=="TSI" || $1=="FIN" || $1=="GBR" || $1=="IBS"' $ref.fam | awk '{print $1"\t"$2}' > $ref.${pop}.fam
elif [ pop == "afr" ]; then 
    awk '$1=="YRI" || $1=="LWK" || $1=="GWD" || $1=="MSL" || $1=="ESN" || $1=="ASW" || $1=="ACB"' $ref.fam | awk '{print $1"\t"$2}' > $ref.${pop}.fam 
elif [ pop == "eas" ]; then 
    awk '$1=="CHB" || $1=="JPT" || $1=="CHS" || $1=="CDX" || $1=="KHV"' $ref.fam | awk '{print $1"\t"$2}' > $ref.${pop}.fam
elif [ pop == "amr" ]; then
    awk '$1=="MXL" || $1=="JPT" || $1=="PUR" || $1=="CLM" || $1=="PEL"' $ref.fam | awk '{print $1"\t"$2}' > $ref.${pop}.fam
elif [ pop == "sas" ]; then
    awk '$1=="GIH" || $1=="PJL" || $1=="BEB" || $1=="STU" || $1=="ITU"' $ref.fam | awk '{print $1"\t"$2}' > $ref.${pop}.fam
fi


# Find SNPs in common between study sample and ref sample
awk 'NR==FNR{a[$0];next} ($0 in a)' $pop_preqcdir/${pop}_pbk_btqc_mgqc-rsid.bim $ref.bim > ${pop}_pbk_ref.common.snplist

# Retain only overlapping SNPs (do this separately for each file; necessary step before merging b/c bmerge does not retain only overlapping SNPs)
$PLINK \
--bfile $pop_preqcdir/${pop}_pbk_btqc_mgqc-rsid \
--extract ${pop}_pbk_ref.common.snplist \
--make-bed \
--out pbk-tmp

$PLINK \
--bfile $ref \
--keep $ref.${pop}.fam \
--extract ${pop}_pbk_ref.common.snplist \
--make-bed \
--out ref-tmp

# Merge study sample with ref panel
$PLINK --bfile pbk-tmp \
--keep-allele-order \
--bmerge ref-tmp \
--make-bed \
--out ${pop}_pbk_ref

rm *tmp*

# If there are strand-flipping or multi-allelic SNPs...exclude them and repeat the steps (shouldn't be too many)
if [ -f ${pop}_pbk_ref-merge.missnp ]; then
    
    mv ${pop}_pbk_ref.log ${pop}_pbk_ref-merge.log

    $PLINK \
    --bfile $pop_preqcdir/${pop}_pbk_btqc_mgqc-rsid \
    --extract ${pop}_pbk_ref.common.snplist \
    --exclude ${pop}_pbk_ref-merge.missnp \
    --make-bed \
    --out pbk-tmp

    $PLINK \
    --bfile $ref \
    --keep $ref.${pop}.fam \
    --extract ${pop}_pbk_ref.common.snplist \
    --exclude ${pop}_pbk_ref-merge.missnp \
    --make-bed \
    --out ref-tmp

    $PLINK \
    --bfile pbk-tmp \
    --keep-allele-order \
    --bmerge ref-tmp \
    --make-bed \
    --out ${pop}_pbk_ref

    rm *tmp*
fi


# Find strand ambiguous SNPs
python $scrdir/find_atgc_snps.py ${pop}_pbk_ref.bim > ${pop}_pbk_ref.atgc.snplist

# Write a list of non-strand ambiguous SNPs to keep
awk 'NR==FNR{a[$1];next} !($2 in a) {print $2}' ${pop}_pbk_ref.atgc.snplist ${pop}_pbk_ref.bim > ${pop}_pbk_ref.non-atgc.snplist


# Perform LD pruning
$PLINK \
--bfile ${pop}_pbk_ref \
--autosome \
--geno 0.02 \
--maf 0.05 \
--snps-only just-acgt \
--extract ${pop}_pbk_ref.non-atgc.snplist \
--exclude range $fhighld_region \
--indep-pairwise 200 100 0.1 \
--out ${pop}_pbk_ref-ldpr


# Run pca
$PLINK \
--bfile ${pop}_pbk_ref \
--extract ${pop}_pbk_ref-ldpr.prune.in \
--pca 20 header tabs \
--out ${pop}_pbk_ref.pca



# Plot PCs
Rscript $scrdir/14_pop_pca.R $pop $pop_pcadir
