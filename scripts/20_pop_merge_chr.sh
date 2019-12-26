#!/bin/bash

pop=$1
pop_postqcdir=$2

PLINK=/data/js95/shared_software/plink
cd $pop_postqcdir/

# Make a file that contains plink binary files across all chromosomes for merging
ls ${pop}_pbk_unrel_qc_aut.imp.chr*.maf001.info08.bed | cat > merge-bed.tmp
ls ${pop}_pbk_unrel_qc_aut.imp.chr*.maf001.info08.bim | cat > merge-bim.tmp
ls ${pop}_pbk_unrel_qc_aut.imp.chr*.maf001.info08.fam | cat > merge-fam.tmp

paste merge-bed.tmp merge-bim.tmp merge-fam.tmp > plink-merge-all-chroms.txt
rm merge*.tmp


# Merge all chromosomes
$PLINK \
--merge-list plink-merge-all-chroms.txt \
--make-bed \
--out ${pop}_pbk_unrel_qc_aut.imp.maf001.info08-tmp


# Replace variant ID with rsID (if exists): 
cat chr*_varid_rsid.tsv > varid_rsid-tmp
# if rsID not present, use the original varid
awk '{if($2==""){print $1"\t"$1}else{print $1"\t"$2}}' varid_rsid-tmp > ${pop}_pbk_unrel_qc_aut.imp.varid.rsid.tsv && rm varid_rsid-tmp

$PLINK \
--bfile ${pop}_pbk_unrel_qc_aut.imp.maf001.info08-tmp \
--update-name ${pop}_pbk_unrel_qc_aut.imp.varid.rsid.tsv 2 1 \
--make-bed \
--out ${pop}_pbk_unrel_qc_aut.imp.maf001.info08

rm *tmp*
