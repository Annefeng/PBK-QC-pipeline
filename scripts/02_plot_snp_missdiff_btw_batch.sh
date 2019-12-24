#!/bin/bash

module load R/3.4.0
source ~/R-3.4.0-ownlib.bash

preqcdir=$1
fbatchpr=$2
scrdir=$3

# preqcdir=/data/js95/yfeng/projects/pbk_genomics_qc/preimp_qc

cd $preqcdir

# Find common SNPs across all batches
# (ref: https://stackoverflow.com/questions/10678486/finding-common-rows-in-files-based-on-one-column)
awk 'NR>1{arr[$2]++; if (FILENAME != prevfile) {c++; prevfile = FILENAME}} END {for (i in arr) {if (arr[i] == c) {print i}}}' */pbk_geno05_mind02_geno02.lmiss > pbk_geno05_mind02_geno02.lmiss.common.snplist

# Based on overlapping SNPs, use R to plot SNP missing rate diff across batches 
Rscript $scrdir/02_plot_snp_misdiff_btw_batch.R $preqcdir $fbatchpr




###############
# for batch in MEGA  MEG_A1_A  MEG_A1_B  MEGAEX  MEG_C  MEG_D  MEG_E  MEG_X1; do 
    # wc -l $batch/pbk_geno05_mind02_geno02.lmiss
    # echo $batch
    # cat $batch/qc_summary.tsv
# done


# MEGA
# Ninds 4924
# Nsnps 1416020
# Nsnps with call rate >0.95 1416016
# Ninds with call rate >0.98 4924
# Nsnps with call rate >0.98 1414935
# MEG_A1_A
# Ninds 4781
# Nsnps 1778953
# Nsnps with call rate >0.95 1768889
# Ninds with call rate >0.98 4781
# Nsnps with call rate >0.98 1754742
# MEG_A1_B
# Ninds 5020
# Nsnps 1778953
# Nsnps with call rate >0.95 1767259
# Ninds with call rate >0.98 5020
# Nsnps with call rate >0.98 1753275
# MEGAEX
# Ninds 5344
# Nsnps 1741376
# Nsnps with call rate >0.95 1740534
# Ninds with call rate >0.98 5344
# Nsnps with call rate >0.98 1736686
# MEG_C
# Ninds 5492
# Nsnps 1778953
# Nsnps with call rate >0.95 1764911
# Ninds with call rate >0.98 5492
# Nsnps with call rate >0.98 1751424
# MEG_D
# Ninds 5146
# Nsnps 1778953
# Nsnps with call rate >0.95 1767133
# Ninds with call rate >0.98 5146
# Nsnps with call rate >0.98 1749982
# MEG_E
# Ninds 4851
# Nsnps 1778953
# Nsnps with call rate >0.95 1767635
# Ninds with call rate >0.98 4851
# Nsnps with call rate >0.98 1750557
# MEG_X1
# Ninds 866
# Nsnps 1778953
# Nsnps with call rate >0.95 1768426
# Ninds with call rate >0.98 866
# Nsnps with call rate >0.98 1752499