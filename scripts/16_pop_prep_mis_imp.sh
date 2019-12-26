#!/bin/bash

# Prep data for Michigan imputation server:
# https://imputationserver.readthedocs.io/en/latest/prepare-your-data/

# module load perl/default

pop=$1				#pop=eur for HRC for now (predominantly EUR)
pop_preqcdir=$2
fhrc_check_pl=$3
fhrc_sites=$4

module load plink/1.90b3

cd $pop_preqcdir

perl $fhrc_check_pl -b ${pop}_pbk_unrel_qc_aut.bim -f ${pop}_pbk_unrel_qc_aut-af.frq -r $fhrc_sites -h
sh Run-plink.sh

# -> output: updated plink files by chromosome


####
# Do this once:
# miscdir=/data/js95/yfeng/projects/pbk_genomics_qc/misc
# cd $miscdir
# wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip #moved this to folder $miscdir/HRC-1000G-check-bim-v4.2.7
# wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz

# gunzip HRC-1000G-check-bim-v4.2.7.zip
# unzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz

# perl $miscdir/HRC-1000G-check-bim-v4.2.7/HRC-1000G-check-bim.pl -b eur_pbk_unrel_qc_aut.bim -f eur_pbk_unrel_qc_aut-af.frq -r $miscdir/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h
# sh Run-plink.sh
