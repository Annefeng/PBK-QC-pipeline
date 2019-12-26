
## NOTE: each job is dependent upon the previous job; do not submit them all at once

# scr=/data/js95/yfeng/projects/tmp/scripts
# wd=/data/js95/yfeng/projects/tmp

scr=/data/js95/yfeng/projects/pbk_genomics_qc/scripts
wd=/data/js95/yfeng/projects/pbk_genomics_qc
data=/data/js95/pbk_36k/biobank_data_subset/data


#### preimpqc
sh $scr/master.sh preimpqc callrate.qc $data $wd/preimp_qc $wd/scripts $wd/misc/batches.tsv
sh $scr/master.sh preimpqc plot.missdiff $data $wd/preimp_qc $wd/scripts $wd/misc/uniq_batch_pairs.tsv
sh $scr/master.sh preimpqc find.missdiff $data $wd/preimp_qc $wd/scripts 0.0075
sh $scr/master.sh preimpqc write.batch.qc $data $wd/preimp_qc $wd/scripts $wd/misc/batches.tsv
sh $scr/master.sh preimpqc merge.batch $data $wd/preimp_qc $wd/scripts
sh $scr/master.sh preimpqc merged.qc $data $wd/preimp_qc $wd/scripts $wd/misc/variant_name_rsID.tsv


#### pca
sh $scr/master.sh pca pca $wd/preimp_qc $wd/pca $wd/scripts /data/js95/yfeng/utility/1kG/ALL.1KG_phase3.20130502.genotypes.maf005 $wd/misc/long_range_LD_intervals.txt
sh $scr/master.sh pca predict.pop $wd/preimp_qc $wd/pca $wd/scripts TRUE 6 0.9
sh $scr/master.sh pca predict.pop $wd/preimp_qc $wd/pca $wd/scripts FALSE 6 0.8


#### pop-specific preimpqc: EUR
sh $scr/master.sh pop.preimpqc write.pop eur $wd/eur_preimp_qc $wd/scripts $wd/preimp_qc $wd/pca 0.9
sh $scr/master.sh pop.preimpqc pop.sqc eur $wd/eur_preimp_qc $wd/scripts $wd/pca $wd/misc/long_range_LD_intervals.txt
sh $scr/master.sh pop.preimpqc run.batch.assoc eur $wd/eur_preimp_qc $wd/scripts $data $wd/misc/uniq_batch_pairs.tsv
sh $scr/master.sh pop.preimpqc find.batch.assoc eur $wd/eur_preimp_qc $wd/scripts

# bsub -q medium -W 10:00 -o /dev/null "$scr/master.sh pop.preimpqc pop.batch.assoc eur $wd/eur_preimp_qc $wd/scripts $data $wd/misc/uniq_batch_pairs.tsv"


### pop-specific pca on unrelated inds
sh $scr/master.sh pop.pca eur $wd/eur_preimp_qc $wd/eur_pca /data/js95/yfeng/utility/1kG/ALL.1KG_phase3.20130502.genotypes.maf005 $wd/misc/long_range_LD_intervals.txt $wd/scripts


### pop-specific prepimpqc: final
sh $scr/master.sh pop.preimpqc.final write.qc.plink eur $wd/eur_preimp_qc $wd/scripts 
sh $scr/master.sh pop.preimpqc.final prep.mis.imp eur $wd/eur_preimp_qc $wd/scripts $wd/misc/HRC-1000G-check-bim-v4.2.7/HRC-1000G-check-bim.pl $wd/misc/HRC.r1-1.GRCh37.wgs.mac5.sites.tab &
sh $scr/master.sh pop.preimpqc.final write.qc.vcf eur $wd/eur_preimp_qc $wd/scripts


### pop-specific postimpqc
sh $scr/master.sh pop.postimpqc annotate.imp.vcf eur $wd/eur_postimp_qc $wd/scripts $wd/misc/dbSNP_b151_GRCh37_all_20180423.vcf.gz
sh $scr/master.sh pop.postimpqc vcf2plink eur $wd/eur_postimp_qc $wd/scripts $wd/misc/update_fid.tsv $wd/misc/update_sex.tsv
sh $scr/master.sh pop.postimpqc merge.imp.plink eur $wd/eur_postimp_qc $wd/scripts



