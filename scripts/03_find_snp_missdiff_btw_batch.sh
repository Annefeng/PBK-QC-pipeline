#!/bin/bash

module load R/3.4.0
source ~/R-3.4.0-ownlib.bash

preqcdir=$1
misdiff_thresh=$2
scrdir=$3

# preqcdir=/data/js95/yfeng/projects/pbk_genomics_qc/preimp_qc
Rscript $scrdir/03_find_snp_misdiff_btw_batch.R $preqcdir $misdiff_thresh

