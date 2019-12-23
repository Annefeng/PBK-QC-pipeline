#!/bin/bash

pop=$1
pop_preimpqc=$2

cd $pop_preimpqc

touch ${pop}_pbk_batch_assoc_pe-06_snps.tsv ${pop}_pbk_batch_assoc_pe-05_snps.tsv ${pop}_pbk_batch_assoc_pe-04_snps.tsv ${pop}_pbk_batch_assoc_pe-03_snps.tsv ${pop}_pbk_batch_assoc_pe-02_snps.tsv

for f in ${pop}_pbk_batch_*.assoc.logistic; do 
	echo $f
	awk '$9<1e-06{print $1"\t"$2"\t"$3"\t"$4}' $f >> ${pop}_pbk_batch_assoc_pe-06_snps.tsv
	awk '$9<1e-05{print $1"\t"$2"\t"$3"\t"$4}' $f >> ${pop}_pbk_batch_assoc_pe-05_snps.tsv
	awk '$9<1e-04{print $1"\t"$2"\t"$3"\t"$4}' $f >> ${pop}_pbk_batch_assoc_pe-04_snps.tsv
	awk '$9<1e-03{print $1"\t"$2"\t"$3"\t"$4}' $f >> ${pop}_pbk_batch_assoc_pe-03_snps.tsv
	awk '$9<1e-02{print $1"\t"$2"\t"$3"\t"$4}' $f >> ${pop}_pbk_batch_assoc_pe-02_snps.tsv
done

# wc -l ${pop}_pbk_batch_assoc_p*.tsv
sort ${pop}_pbk_batch_assoc_pe-06_snps.tsv | uniq > tmp && mv tmp ${pop}_pbk_batch_assoc_pe-06_snps.tsv
sort ${pop}_pbk_batch_assoc_pe-05_snps.tsv | uniq > tmp && mv tmp ${pop}_pbk_batch_assoc_pe-05_snps.tsv
sort ${pop}_pbk_batch_assoc_pe-04_snps.tsv | uniq > tmp && mv tmp ${pop}_pbk_batch_assoc_pe-04_snps.tsv
sort ${pop}_pbk_batch_assoc_pe-03_snps.tsv | uniq > tmp && mv tmp ${pop}_pbk_batch_assoc_pe-03_snps.tsv
sort ${pop}_pbk_batch_assoc_pe-02_snps.tsv | uniq > tmp && mv tmp ${pop}_pbk_batch_assoc_pe-02_snps.tsv

awk '{print $2}' ${pop}_pbk_batch_assoc_pe-06_snps.tsv > ${pop}_pbk_batch_assoc_pe-06.snplist
awk '{print $2}' ${pop}_pbk_batch_assoc_pe-05_snps.tsv > ${pop}_pbk_batch_assoc_pe-05.snplist
awk '{print $2}' ${pop}_pbk_batch_assoc_pe-04_snps.tsv > ${pop}_pbk_batch_assoc_pe-04.snplist
awk '{print $2}' ${pop}_pbk_batch_assoc_pe-03_snps.tsv > ${pop}_pbk_batch_assoc_pe-03.snplist
awk '{print $2}' ${pop}_pbk_batch_assoc_pe-02_snps.tsv > ${pop}_pbk_batch_assoc_pe-02.snplist






