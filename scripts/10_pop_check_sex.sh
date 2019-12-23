#!/bin/bash

module load R/3.4.0
source ~/R-3.4.0-ownlib.bash

pcadir=$1
pop=$2
pop_preqcdir=$3
scrdir=$4

PLINK=/data/js95/shared_software/plink

cd $pop_preqcdir

# Perform LD pruning: chrX
$PLINK \
--bfile ${pop}_pbk_btqc_mgqc-rsid \
--chr 23 \
--geno 0.02 \
--maf 0.05 \
--snps-only just-acgt \
--indep-pairwise 200 100 0.1 \
--out ${pop}_pbk_btqc_mgqc-ldpr-chrx


# Check sex
$PLINK \
--bfile ${pop}_pbk_btqc_mgqc-rsid \
--extract ${pop}_pbk_btqc_mgqc-ldpr-chrx.prune.in \
--check-sex \
--out ${pop}_pbk_btqc_mgqc-chrx


# Plot F-statistic
Rscript $scrdir/10_pop_check_sex.R $pop $pop_preqcdir

