#!/bin/bash

pop=$1
pop_postqcdir=$2
maf_thresh=$3
impRsq_thresh=$4

PLINK=/data/js95/shared_software/plink
cd $pop_postqcdir/

# Make a file that contains plink binary files across all chromosomes for merging
ls ${pop}_pbk_unrel_qc_aut.imp.chr*.maf${maf_thresh}.impRsq${impRsq_thresh}.bed | cat > merge-bed..maf${maf_thresh}.impRsq${impRsq_thresh}.tmp
ls ${pop}_pbk_unrel_qc_aut.imp.chr*.maf${maf_thresh}.impRsq${impRsq_thresh}.bim | cat > merge-bim..maf${maf_thresh}.impRsq${impRsq_thresh}.tmp
ls ${pop}_pbk_unrel_qc_aut.imp.chr*.maf${maf_thresh}.impRsq${impRsq_thresh}.fam | cat > merge-fam..maf${maf_thresh}.impRsq${impRsq_thresh}.tmp

paste merge-bed..maf${maf_thresh}.impRsq${impRsq_thresh}.tmp merge-bim..maf${maf_thresh}.impRsq${impRsq_thresh}.tmp merge-fam..maf${maf_thresh}.impRsq${impRsq_thresh}.tmp > plink-merge-all-chroms.maf${maf_thresh}.impRsq${impRsq_thresh}.txt
rm merge*.tmp


# Merge all chromosomes
$PLINK \
--merge-list plink-merge-all-chroms.maf${maf_thresh}.impRsq${impRsq_thresh}.txt \
--make-bed \
--out ${pop}_pbk_unrel_qc_aut.imp.maf${maf_thresh}.impRsq${impRsq_thresh}-tmp
mv ${pop}_pbk_unrel_qc_aut.imp.maf${maf_thresh}.impRsq${impRsq_thresh}-tmp.log ${pop}_pbk_unrel_qc_aut.imp.maf${maf_thresh}.impRsq${impRsq_thresh}-merge.log


# Replace variant ID with rsID (if exists): 
if [ ! -f ${pop}_pbk_unrel_qc_aut.imp.varid.rsid.tsv ]; then
	cat chr*_varid_rsid.tsv > varid_rsid-tmp
	# if rsID not present, use the original varid
	awk '{if($2==""){print $1"\t"$1}else{print $1"\t"$2}}' varid_rsid-tmp > ${pop}_pbk_unrel_qc_aut.imp.varid.rsid.tsv && rm varid_rsid-tmp
fi

# # Remove any duplicates
# sort afr_pbk_unrel_qc_aut.imp.varid.rsid.tsv | uniq > tmp && mv tmp afr_pbk_unrel_qc_aut.imp.varid.rsid.tsv


$PLINK \
--bfile ${pop}_pbk_unrel_qc_aut.imp.maf${maf_thresh}.impRsq${impRsq_thresh}-tmp \
--update-name ${pop}_pbk_unrel_qc_aut.imp.varid.rsid.tsv 2 1 \
--make-bed \
--out ${pop}_pbk_unrel_qc_aut.imp.maf${maf_thresh}.impRsq${impRsq_thresh}

rm *tmp*
