#!/bin/bash

preqcdir=$1
fvarmap=$2


PLINK=/data/js95/shared_software/plink
cd $preqcdir/


# Find out duplicated SNPs (same chr, pos, ref, alt)
$PLINK \
--bfile pbk_btqc_mg \
--list-duplicate-vars ids-only suppress-first \
--out pbk_btqc_mg-dupcheck


# Remove duplicated, un-mapped (--not-chr), and monomorhpic (mac>0) SNPs, and convert variant name to rsID (if exists)
$PLINK \
--bfile pbk_btqc_mg \
--not-chr 0 \
--mac 1 \
--exclude pbk_btqc_mg-dupcheck.dupvar \
--make-bed \
--out pbk_btqc_mgqc


# Convert variant name to rsID (if exists)
$PLINK \
--bfile pbk_btqc_mgqc \
--update-name $fvarmap \
--make-bed \
--out pbk_btqc_mgqc-rsid




##########
# variants have chr"0" and position "0" are those that cannot be confidently mapped 
# --> exclude them using --not-chr
# --update-name to change all vairant id to rsID, for later merging with 1kG data