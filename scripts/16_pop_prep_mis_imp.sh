#!/bin/bash

# Prep data for Michigan imputation server:
# https://imputationserver.readthedocs.io/en/latest/prepare-your-data/

# module load perl/default

pop=$1				#pop=eur for HRC for now (predominantly EUR)
pop_preqcdir=$2
ref_panel=$3		# HR or 1KG
fref_check_pl=$4
fref_sites=$5

module load plink/1.90b3

cd $pop_preqcdir
POP=$(echo $pop | tr '[a-z]' '[A-Z]')

if [ $ref_panel == "HRC" ]; then
	perl $fref_check_pl -b ${pop}_pbk_unrel_qc_aut.bim -f ${pop}_pbk_unrel_qc_aut-af.frq -r $fref_sites -h
elif [ $ref_panel == "1KG" ]; then
	perl $fref_check_pl -b ${pop}_pbk_unrel_qc_aut.bim -f ${pop}_pbk_unrel_qc_aut-af.frq -r $fref_sites -g -p $POP
fi

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

# **ref panel: HRC
# perl $miscdir/HRC-1000G-check-bim-v4.2.7/HRC-1000G-check-bim.pl -b eur_pbk_unrel_qc_aut.bim -f eur_pbk_unrel_qc_aut-af.frq -r $miscdir/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h
# sh Run-plink.sh

# **ref panel: 1KG
# perl $miscdir/HRC-1000G-check-bim-v4.2.7/HRC-1000G-check-bim.pl -b eur_pbk_unrel_qc_aut.bim -f eur_pbk_unrel_qc_aut-af.frq -r $miscdir/1000GP_Phase3_combined.legend.gz -g -p EUR
# sh Run-plink.sh
