#!/bin/bash

module load R/3.4.0
source ~/R-3.4.0-ownlib.bash

pcadir=$1
pcplot0=$2
npc=$3
pred_prob=$4
scrdir=$5

Rscript $scrdir/08_classify_ancestry.R $pcadir $pcplot0 $npc $pred_prob