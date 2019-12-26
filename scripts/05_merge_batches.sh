#!/bin/bash

preqcdir=$1

PLINK=/data/js95/shared_software/plink
cd $preqcdir/

# preqcdir=/data/js95/yfeng/projects/pbk_genomics_qc/preimp_qc
# Make a file that contains plink binary files across all batches for merging
ls */pbk_btqc.bed | cat > merge-bed.tmp
ls */pbk_btqc.bim | cat > merge-bim.tmp
ls */pbk_btqc.fam | cat > merge-fam.tmp

paste merge-bed.tmp merge-bim.tmp merge-fam.tmp > plink-merge-all-batches.txt
rm merge*.tmp

$PLINK \
--merge-list plink-merge-all-batches.txt \
--make-bed \
--out pbk_btqc_mg
# --out pbk_preimpqc_merged


# Calcualte allele freq
$PLINK \
--bfile pbk_btqc_mg \
--freq \
--out pbk_btqc_mg-af
# --out pbk_preimpqc_merged-af
