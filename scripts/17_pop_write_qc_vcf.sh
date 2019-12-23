#!/bin/bash

pop=$1
pop_preqcdir=$2
cd $pop_preqcdir

# cd /data/js95/yfeng/projects/pbk_genomics_qc/eur_preimp_qc
PLINK=/data/js95/shared_software/plink

module load vcftools
module load tabix

$PLINK \
--bfile ${pop}_pbk_unrel_qc_aut-updated-chr${LSB_JOBINDEX} \
--recode vcf-iid \
--real-ref-alleles \
--out ${pop}_pbk_unrel_qc_aut-updated-chr${LSB_JOBINDEX}

vcf-sort ${pop}_pbk_unrel_qc_aut-updated-chr${LSB_JOBINDEX}.vcf | bgzip -c > ${pop}_pbk_unrel_qc_aut-updated-chr${LSB_JOBINDEX}.vcf.gz

