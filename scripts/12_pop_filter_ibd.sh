#!/bin/bash

module load R/3.4.0
source ~/R-3.4.0-ownlib.bash

pcadir=$1
pop=$2
pop_preqcdir=$3
fhighld_region=$4
scrdir=$5

PLINK=/data/js95/shared_software/plink
cd $pop_preqcdir

# Perform LD pruning: autosomal SNPs
$PLINK \
--bfile ${pop}_pbk_btqc_mgqc-rsid \
--autosome \
--geno 0.02 \
--maf 0.05 \
--snps-only just-acgt \
--extract $pcadir/pbk_btqc_mgqc-rsid.non-atgc.snplist \
--exclude range $fhighld_region \
--indep-pairwise 200 100 0.1 \
--out ${pop}_pbk_btqc_mgqc-ldpr-aut-tmp


# if [ !-f ${pop}_pbk_btqc_mgqc-ibd-min0.125.genome.gz ]; then
# Estimate IBD
$PLINK \
--bfile ${pop}_pbk_btqc_mgqc-rsid \
--extract ${pop}_pbk_btqc_mgqc-ldpr-aut-tmp.prune.in \
--genome \
--min 0.125 \
--out ${pop}_pbk_btqc_mgqc-ibd-min0.125

gzip ${pop}_pbk_btqc_mgqc-ibd-min0.125.genome

# Plot IBD to infer relatedness and extract one from each pair of related's (pihat>0.2) for removal
Rscript $scrdir/12_pop_filter_ibd.R $pop $pop_preqcdir


rm ${pop}_pbk_btqc_mgqc-ldpr-aut-tmp*

