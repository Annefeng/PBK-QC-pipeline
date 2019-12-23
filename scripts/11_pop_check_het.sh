#!/bin/bash

module load R/3.4.0
source ~/R-3.4.0-ownlib.bash

pcadir=$1
pop=$2
pop_preqcdir=$3
fhighld_region=$4
scrdir=$5


PLINK=/data/js95/shared_software/plink
cd $pop_preqcdir


# Perform LD pruning: autosomal SNPs
$PLINK \
--bfile ${pop}_pbk_btqc_mgqc-rsid \
--autosome \
--geno 0.02 \
--maf 0.05 \
--snps-only just-acgt \
--extract $pcadir/pbk_btqc_mgqc-rsid.non-atgc.snplist \
--exclude range $fhighld_region \
--indep-pairwise 200 100 0.1 \
--out ${pop}_pbk_btqc_mgqc-ldpr-aut


# Estimate autosomal heterozygosity rate/inbreeding coeff
# also use pruned SNPs! see: http://zzz.bwh.harvard.edu/plink/ibdibs.shtml
$PLINK \
--bfile ${pop}_pbk_btqc_mgqc-rsid \
--extract ${pop}_pbk_btqc_mgqc-ldpr-aut.prune.in \
--het \
--out ${pop}_pbk_btqc_mgqc-inbr

# Calculate hetorozygosity rate (i.e., the proportion of heterozygous genotypes for a given individual.)
awk 'NR>1{print ($5-$3)/$5}' ${pop}_pbk_btqc_mgqc-inbr.het | sed '1i HetRate' | paste ${pop}_pbk_btqc_mgqc-inbr.het - > ${pop}_pbk_btqc_mgqc-inbr.hetrate

# Plot het rate distribution
Rscript $scrdir/11_pop_check_het.R $pop $pop_preqcdir



