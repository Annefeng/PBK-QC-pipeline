#!/bin/bash

pop=$1
pop_postqcdir=$2
db_vcf=$3

# # test
# LSB_JOBINDEX=22
# pop_postqcdir=/data/js95/yfeng/projects/pbk_genomics_qc/eur_postimp_qc
# db_vcf=/data/js95/yfeng/projects/pbk_genomics_qc/misc/dbsnp_all_20180418.vcf.gz


cd $pop_postqcdir/
snpeff=/data/js95/shared_software/snpEff

module load java/1.8.0_181
module load tabix/default
module load bcftools

# Download dbgap snp file from ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/
# All_20180423.vcf.gz & All_20180423.vcf.gz.tbi

# bgzip All_20180423.vcf.gz && tabix -p vcf All_20180423.vcf.gz # already has tabix-indexed file so this step can be omitted

# mv All_20180423.vcf.gz dbSNP_b151_GRCh37_all_20180423.vcf.gz
# mv All_20180423.vcf.gz.tbi dbSNP_b151_GRCh37_all_20180423.vcf.gz.tbi 

# java -Xmx6g -jar $snpeff/SnpSift.jar annotate -id $db_vcf chr${LSB_JOBINDEX}.dose.vcf.gz > chr${LSB_JOBINDEX}_annotated.vcf

bcftools view -G chr${LSB_JOBINDEX}.dose.vcf.gz | java -Xmx6g -jar $snpeff/SnpSift.jar annotate -id $db_vcf | bcftools query -f '%ID\n' | awk -F";" '$1=$1' OFS="\t" > chr${LSB_JOBINDEX}_varid_rsid.tsv

# bcftools view -G: strip all samples, keeping only variants (maintaining the INFO metadata) 




