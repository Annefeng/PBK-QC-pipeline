#!/bin/bash

pop=$1
pop_postqcdir=$2
maf_thresh=$3
impRsq_thresh=$4
fupdate_fid=$5
fupdate_sex=$6

# # test:
# LSB_JOBINDEX=22
# pop_postqcdir=/data/js95/yfeng/projects/pbk_genomics_qc/eur_postimp_qc
# maf_thresh=0.01
# impRsq_thresh=0.8

cd $pop_postqcdir
PLINK=/data/js95/shared_software/plink


# Michigan server imputation reuslts come in two files per chromosome:
# 1. chr${}.info.gz: one row per variant, including chr, pos, rel, alt, MAF, imputation Rsq, etc 
# 2. chr${}.dose.vcf.gz: the imputed dosage data for study samples


# Extract from vcf a list of SNPs with INFO score/impuation Rsq >0.8 and MAF >1%
# (can filter on info.gz file; minimac format: https://genome.sph.umich.edu/wiki/Minimac3_Info_File)
zcat chr${LSB_JOBINDEX}.info.gz | awk -v x=$maf_thresh 'NR>1 && $5<x{print $1}' > chr${LSB_JOBINDEX}-tmp.maf.le.${maf_thresh}.snplist
zcat chr${LSB_JOBINDEX}.info.gz | awk -v y=$impRsq_thresh 'NR>1 && $7<y{print $1}' > chr${LSB_JOBINDEX}-tmp.impRsq.le.${impRsq_thresh}.snplist

zcat chr${LSB_JOBINDEX}.info.gz | awk -v x=$maf_thresh -v y=$impRsq_thresh '$5>=x && $7>=y' > ${pop}_pbk_unrel_qc_aut.imp.chr${LSB_JOBINDEX}.maf${maf_thresh}.impRsq${impRsq_thresh}.snplist


# Convert from vcf to plink hardcalls retaining only these SNPs (discarding phase and dosage info)
$PLINK \
--vcf chr${LSB_JOBINDEX}.dose.vcf.gz \
--extract ${pop}_pbk_unrel_qc_aut.imp.chr${LSB_JOBINDEX}.maf${maf_thresh}.impRsq${impRsq_thresh}.snplist \
--double-id \
--make-bed \
--out chr${LSB_JOBINDEX}-tmp1


# Filter on call rate on the transformed hardcall genotypes and update fid
$PLINK \
--bfile chr${LSB_JOBINDEX}-tmp1 \
--geno 0.02 \
--update-ids $fupdate_fid \
--make-bed \
--out chr${LSB_JOBINDEX}-tmp2
# mv chr${LSB_JOBINDEX}-tmp2.log ${pop}_pbk_unrel_qc_aut.imp.chr${LSB_JOBINDEX}.maf${maf_thresh}.impRsq${impRsq_thresh}.geno.update-fid.log


# Filter by hwe and update sex (--update-ids cannot be used in the same run as --update-sex)
$PLINK \
--bfile chr${LSB_JOBINDEX}-tmp2 \
--hwe 1e-10 \
--update-sex $fupdate_sex \
--make-bed \
--out ${pop}_pbk_unrel_qc_aut.imp.chr${LSB_JOBINDEX}.maf${maf_thresh}.impRsq${impRsq_thresh}




######
# Summarize number of samples and SNPs removed at each step
touch qc_summary_chr${LSB_JOBINDEX}.tsv
nsnps=$(zcat chr${LSB_JOBINDEX}.info.gz | wc -l)
echo "Chr"${LSB_JOBINDEX} > qc_summary_chr${LSB_JOBINDEX}.tsv
echo "Nsnps "`expr $nsnps` >> qc_summary_chr${LSB_JOBINDEX}.tsv

nsnps_tmp1=$(wc -l chr${LSB_JOBINDEX}-tmp1.bim | awk '{print $1}')
nsnps_tmp2=$(wc -l chr${LSB_JOBINDEX}-tmp2.bim | awk '{print $1}')
nsnps_final=$(wc -l ${pop}_pbk_unrel_qc_aut.imp.chr${LSB_JOBINDEX}.maf${maf_thresh}.impRsq${impRsq_thresh}.bim | awk '{print $1}')

echo "Nsnps with MAF < ${maf_thresh}: "$(cat chr${LSB_JOBINDEX}-tmp.maf.le.${maf_thresh}.snplist | wc -l) >> qc_summary_chr${LSB_JOBINDEX}.tsv
echo "Ninds with impRsq < ${impRsq_thresh}: "$(cat chr${LSB_JOBINDEX}-tmp.impRsq.le.${impRsq_thresh}.snplist | wc -l) >> qc_summary_chr${LSB_JOBINDEX}.tsv
echo "Nsnps with MAF < ${maf_thresh} or impRsq < ${impRsq_thresh}: "`expr $nsnps - $nsnps_tmp1` >> qc_summary_chr${LSB_JOBINDEX}.tsv
echo "Nsnps with call rate < 0.98: "`expr $nsnps_tmp1 - $nsnps_tmp2` >> qc_summary_chr${LSB_JOBINDEX}.tsv
echo "Nsnps with pHWE < 1e-10: "`expr $nsnps_tmp2 - $nsnps_final` >> qc_summary_chr${LSB_JOBINDEX}.tsv


rm chr${LSB_JOBINDEX}-tmp*


####
# VCF files just contain sample IDs, instead of the distinct family and within-family IDs tracked by PLINK.
# --double-id causes both family and within-family IDs to be set to the sample ID.