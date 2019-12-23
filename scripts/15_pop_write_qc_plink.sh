#!/bin/bash

pop=$1
pop_preqcdir=$2

PLINK=/data/js95/shared_software/plink

cd $pop_preqcdir

# Rmove samples not passing sex, het, and ibd filter
$PLINK \
--bfile ${pop}_pbk_btqc_mgqc-rsid \
--remove ${pop}_pbk_sexcheck_het_ibd.remove.indlist \
--exclude ${pop}_pbk_batch_assoc_pe-04.snplist \
--make-bed \
--out ${pop}_pbk_unrel-tmp

# Perform final SNP-level QC on predicted EUR samples 
$PLINK \
--bfile ${pop}_pbk_unrel-tmp \
--geno 0.02 \
--write-snplist \
--out ${pop}_pbk_unrel_geno02


$PLINK \
--bfile ${pop}_pbk_unrel-tmp \
--hardy \
--out ${pop}_pbk_unrel-hardy
# --hwe

awk '$9<1e-10{print $2}' ${pop}_pbk_unrel-hardy.hwe > ${pop}_pbk_unrel_hwe_pe-10.snplist

# Remove SNPs with call rate < 0.98 and p-hwe < 1e-10
$PLINK \
--bfile ${pop}_pbk_unrel-tmp \
--extract ${pop}_pbk_unrel_geno02.snplist \
--exclude ${pop}_pbk_unrel_hwe_pe-10.snplist \
--make-bed \
--out ${pop}_pbk_unrel_qc

rm ${pop}_pbk_unrel-tmp*


# Save only autosomal, non-indel, and polymorphic SNPs
$PLINK \
--bfile ${pop}_pbk_unrel_qc \
--autosome \
--mac 1 \
--snps-only just-acgt \
--make-bed \
--out ${pop}_pbk_unrel_qc_aut


# Calc freq
$PLINK \
--bfile ${pop}_pbk_unrel_qc_aut \
--freq \
--out ${pop}_pbk_unrel_qc_aut-af
# # when not using --mac 1 (not excluding monomorphic SNPs):
# awk '$5==0' ${pop}_pbk_unrel_qc_aut-af.frq | wc -l #-> still ~80K monomorphic sites; to remove


