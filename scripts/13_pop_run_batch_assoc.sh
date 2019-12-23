#!/bin/bash

datadir=$1
pop=$2
pop_preqcdir=$3
batch1=$4
batch2=$5

# datadir=/data/js95/pbk_36k/biobank_data_subset/data
# pop_preqcdir=/data/js95/yfeng/projects/pbk_genomics_qc/${pop}_preimp_qc
# batch1=MEGA
# batch2=MEG_A1_A

PLINK=/data/js95/shared_software/plink

cd $pop_preqcdir
if [ ! -f ${pop}_pbk_sexcheck_het_ibd.remove.indlist ]; then
    cat ${pop}_pbk_sex_mismatch_F025_M075.indlist ${pop}_pbk_het_outlier_5sd.indlist ${pop}_pbk_ibd_pihat02.indlist | sort | uniq > ${pop}_pbk_sexcheck_het_ibd.remove.indlist
fi


# Make pseudo case/control variable: one batch as "case" (=2), another batch as "control" (=1)
awk 'NR==FNR{a[$2];next} ($2 in a) {print $0}' $datadir/"$batch1"/data.fam ${pop}_pbk_btqc_mgqc-rsid.fam | awk '{print $1"\t"$2"\t"1}' > pheno."$batch1"."$batch2".bt1
awk 'NR==FNR{a[$2];next} ($2 in a) {print $0}' $datadir/"$batch2"/data.fam ${pop}_pbk_btqc_mgqc-rsid.fam | awk '{print $1"\t"$2"\t"2}' > pheno."$batch1"."$batch2".bt2

cat pheno."$batch1"."$batch2".bt1 pheno."$batch1"."$batch2".bt2 > pheno."$batch1"."$batch2"
rm pheno."$batch1"."$batch2".bt*


# Run assoc
$PLINK \
--bfile ${pop}_pbk_btqc_mgqc-rsid \
--remove ${pop}_pbk_sexcheck_het_ibd.remove.indlist \
--pheno pheno."$batch1"."$batch2" \
--logistic hide-covar sex \
--out ${pop}_pbk_batch_"$batch1"."$batch2"

