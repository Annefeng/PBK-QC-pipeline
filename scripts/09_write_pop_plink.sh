#!/bin/bash

preqcdir=$1
pcadir=$2
pop=$3
pop_preqcdir=$4
pred_prob=$5

PLINK=/data/js95/shared_software/plink

cd $pop_preqcdir

POP=$(echo $pop | tr '[a-z]' '[A-Z]')
awk -v x=$POP -v y=$pred_prob '$25==x && $26>y' $pcadir/pbk_ref.PC.predPop.tsv | awk '{print $2"\t"$1}' > $pcadir/pbk_ref.PC.predPop${pred_prob}.${pop}.indlist

$PLINK \
--bfile $preqcdir/pbk_btqc_mgqc-rsid \
--keep $pcadir/pbk_ref.PC.predPop${pred_prob}.${pop}.indlist \
--make-bed \
--out ${pop}_pbk_btqc_mgqc-rsid

$PLINK \
--bfile ${pop}_pbk_btqc_mgqc-rsid \
--keep $pcadir/pbk_ref.PC.predPop${pred_prob}.${pop}.indlist \
--freq \
--out ${pop}_pbk_btqc_mgqc-rsid-af

#######
$PLINK \
--bfile $preqcdir/pbk_btqc_mgqc \
--keep $pcadir/pbk_ref.PC.predPop${pred_prob}.${pop}.indlist \
--make-bed \
--out ${pop}_pbk_btqc_mgqc
