#/bin/bash

datadir=$1
preqcdir=$2
batch=$3

PLINK=/data/js95/shared_software/plink


cd $preqcdir/$batch

$PLINK \
--bfile $datadir/$batch/data \
--extract $preqcdir/pbk_geno05_mind02_geno02.lmiss.common.snplist \
--exclude $preqcdir/overall_missRateDiff0.0075.snplist \
--keep pbk_geno05_mind02.indlist \
--make-bed \
--out pbk_btqc
# --out pbk_geno05_mind02_geno02_common.snp_misdiff0075
