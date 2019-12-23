#/bin/bash

datadir=$1
preqcdir=$2
batch=$3 		# e.g., MEGA

######################
# test:
# datadir=/data/js95/pbk_36k/biobank_data_subset/data
# preqcdir=/data/js95/yfeng/projects/pbk_genomics_qc/preimp_qc
# batch=MEGA

PLINK=/data/js95/shared_software/plink

if [ ! -d $preqcdir/$batch ]; then
	mkdir $preqcdir/$batch
fi

cd $preqcdir/$batch
######################


# 1. Output a list of SNPs with call rate > 0.95
$PLINK \
--bfile $datadir/$batch/data \
--geno 0.05 \
--write-snplist \
--out pbk_geno05


# 2. Filter to SNPs in the previous step, output a list of samples with call rate > 0.98
$PLINK \
--bfile $datadir/$batch/data \
--extract pbk_geno05.snplist \
--missing \
--out pbk_geno05
awk 'NR>1{if($6<0.02){print $1,$2}}' pbk_geno05.imiss > pbk_geno05_mind02.indlist


# 3. Filter to samples in the previous step, output a list of SNPs with call rate > 0.98
$PLINK \
--bfile $datadir/$batch/data \
--extract pbk_geno05.snplist \
--keep pbk_geno05_mind02.indlist \
--geno 0.02 \
--write-snplist \
--out pbk_geno05_mind02_geno02


# 4. Keep samples and SNPs passing previous filters, calculate SNP-level missing rate
$PLINK \
--bfile $datadir/$batch/data \
--extract pbk_geno05_mind02_geno02.snplist \
--keep pbk_geno05_mind02.indlist \
--missing \
--out pbk_geno05_mind02_geno02


######
# Summarize number of samples and SNPs removed at each step
touch qc_summary.tsv
ninds=$(cat $datadir/$batch/data.fam | wc -l)
nsnps=$(cat $datadir/$batch/data.bim | wc -l)
echo "Ninds "$ninds > qc_summary.tsv
echo "Nsnps "$nsnps >> qc_summary.tsv

echo "Nsnps with call rate >0.95 "$(cat pbk_geno05.snplist | wc -l) >> qc_summary.tsv
echo "Ninds with call rate >0.98 "$(cat pbk_geno05_mind02.indlist | wc -l) >> qc_summary.tsv
echo "Nsnps with call rate >0.98 "$(cat pbk_geno05_mind02_geno02.snplist | wc -l) >> qc_summary.tsv


