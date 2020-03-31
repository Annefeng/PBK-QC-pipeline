#/bin/bash

# module load R/3.4.0
# source ~/R-3.4.0-ownlib.bash

module=$1

#***********************************************************************************************#
#                              Module: Pre-imputation QC (all samples)                          #
#***********************************************************************************************#

if [ $module == "preimpqc" ]; then
	
    submode=$2
	datadir=$3
	preqcdir=$4
	scrdir=$5

    #--------------------------------------------------------#
    #                   Call rate QC by batch                #
    #--------------------------------------------------------#
    
    if [ $submode == "callrate.qc" ]; then
        # nbatch=$5
        fbatch=$6       # file that conatins one row per batch name
        nbatch=$(cat $fbatch | wc -l)
        for idx in `seq 1 $nbatch`; do 
            batch=$(sed -n ''$idx'p' $fbatch)
            # echo $batch
            # if [ ! -f $preqcdir/$batch/_SUCCESS.callrate.qc ]; then
            bsub -q medium -o /dev/null $scrdir/01_callrate_qc_by_batch.sh $datadir $preqcdir $batch
            # fi
        done
    fi

    #--------------------------------------------------------#
    #       Identify SNPs with differentail missng rate      #
    #--------------------------------------------------------#

    # - plot SNP missing rate diff across batches based on overlapping SNPs
    if [ $submode == "plot.missdiff" ]; then
        fbatchpr=$6      # file that contains all possible pairs of bathces, with one pair per row separated into two columns
        bsub -q medium -o /dev/null $scrdir/02_plot_snp_missdiff_btw_batch.sh $preqcdir $fbatchpr $scrdir
    fi

    # - find SNPs that show differential missing rate given any pair of batches (empirically pick a threshold)
    if [ $submode == "find.missdiff" ]; then
        missdiff_thresh=$6
        bsub -q medium -o /dev/null $scrdir/03_find_snp_missdiff_btw_batch.sh $preqcdir $missdiff_thresh $scrdir
    fi

    #--------------------------------------------------------#
    #        Write initial qc'ed plink files by batch        #
    #--------------------------------------------------------#

    if [ $submode == "write.batch.qc" ]; then
        # nbatch=$5
        fbatch=$6
        nbatch=$(cat $fbatch | wc -l)
        for idx in `seq 1 $nbatch`; do 
            batch=$(sed -n ''$idx'p' $fbatch)
            bsub -q medium -o /dev/null $scrdir/04_makebed_initqc_by_batch.sh $datadir $preqcdir $batch
        done
    fi

    #--------------------------------------------------------#
    #                       Merge bathces                    #
    #--------------------------------------------------------#

    if [ $submode == "merge.batch" ]; then
        bsub -q big -o /dev/null $scrdir/05_merge_batches.sh $preqcdir
    fi

    #--------------------------------------------------------#
    #   Perform some merged-batch QC, also convert to rsID   #
    #--------------------------------------------------------#

    if [ $submode == "merged.qc" ]; then
        fvarmap=$6
        bsub -q big -o /dev/null $scrdir/06_remove_dup_mono_snps.sh $preqcdir $fvarmap
    fi

fi



#***********************************************************************************************#
#                                    Module: PCA (all samples)                                  #
#***********************************************************************************************#

if [ $module == "pca" ]; then

    submode=$2
    preqcdir=$3
    pcadir=$4
    scrdir=$5

    #--------------------------------------------------------#
    #               Run PCA with ref panel (1KG)             #
    #--------------------------------------------------------#

    if [ $submode == "pca" ]; then
        ref=$6
        fhighld_region=$7
        bsub -q big -o /dev/null $scrdir/07_pca.sh $preqcdir $pcadir $ref $fhighld_region $scrdir
    fi

    #--------------------------------------------------------#
    #          Classify ancestry for study samples           #
    #--------------------------------------------------------#

    if [ $submode == "predict.pop" ]; then
        pcplot0=$6      #TRUE or FALSE
        npc=$7
        pred_prob=$8
        bsub -q medium -o $pcadir/pbk_${submode}_npc${npc}_predProb${pred_prob}.out $scrdir/08_classify_ancestry.sh $pcadir $pcplot0 $npc $pred_prob $scrdir
    fi

fi



#***********************************************************************************************#
#                              Module: Pre-imputation QC (pop-specific)                         #
#***********************************************************************************************#

if [ $module == "pop.preimpqc" ]; then

    submode=$2
    pop=$3                  # 1KG super populations (lowercase): afr, amr, eas, eur, sas
    pop_preqcdir=$4
    scrdir=$5

    #--------------------------------------------------------#
    #             Write pop-specific plink files             #
    #--------------------------------------------------------#

    if [ $submode == "write.pop" ]; then
        preqcdir=$6
        pcadir=$7
        pred_prob=$8
        bsub -q big -o /dev/null $scrdir/09_write_pop_plink.sh $preqcdir $pcadir $pop $pop_preqcdir $pred_prob
    fi

    #--------------------------------------------------------#
    #             Perform pop-specific sample QC             #
    #--------------------------------------------------------#

    if [ $submode == "pop.sqc" ]; then
        pcadir=$6
        fhighld_region=$7

        # Sex check
        bsub -q medium -o /dev/null $scrdir/10_pop_check_sex.sh $pcadir $pop $pop_preqcdir $scrdir

        # Heterozygosity rate
        bsub -q medium -o /dev/null $scrdir/11_pop_check_het.sh $pcadir $pop $pop_preqcdir $fhighld_region $scrdir

        # IBD estimation
        bsub -q big -o /dev/null $scrdir/12_pop_filter_ibd.sh $pcadir $pop $pop_preqcdir $fhighld_region $scrdir
    fi

    #--------------------------------------------------------#
    #          Idenitfy SNPs showing batch association       #
    #--------------------------------------------------------#

    if [ $submode == "run.batch.assoc" ]; then
        datadir=$6
        fbatchpr=$7
        nbatchpr=$(cat $fbatchpr | wc -l)
        nsnp=$(wc -l $pop_preqcdir/${pop}_pbk_btqc_mgqc-rsid.bim | awk '{print $1}')
        
        for idx in `seq 1 $nbatchpr`; do
            batch1=$(sed -n ''$idx'p' $fbatchpr | awk '{print $1}')
            batch2=$(sed -n ''$idx'p' $fbatchpr | awk '{print $2}')
            echo $batch1 $batch2
            fout=$pop_preqcdir/${pop}_pbk_batch_${batch1}.${batch2}.assoc.logistic
            if [ ! -f $fout ]; then
                bsub -q big -R rusage[mem=8000] -o /dev/null \
                $scrdir/13_pop_run_batch_assoc.sh $datadir $pop $pop_preqcdir $batch1 $batch2
            elif [ -f $fout ] && [ $(awk 'NR>1{print $1}' $fout | wc -l) != $nsnp ]; then
                bsub -q big -R rusage[mem=8000] -o /dev/null \
                $scrdir/13_pop_run_batch_assoc.sh $datadir $pop $pop_preqcdir $batch1 $batch2
            fi
        done
    fi

    if [ $submode == "find.batch.assoc" ]; then
        bsub -q short -o /dev/null $scrdir/13_pop_find_batch_assoc_snps.sh $pop $pop_preqcdir
    fi

fi



#***********************************************************************************************#
#                          Module: PCA on pop-specific, unrelated sampels                       #
#***********************************************************************************************#

if [ $module == "pop.pca" ]; then

    pop=$2
    pop_preqcdir=$3
    pop_pcadir=$4
    ref=$5
    fhighld_region=$6
    scrdir=$7

    bsub -q big -o /dev/null $scrdir/14_pop_pca.sh $pop $pop_preqcdir $pop_pcadir $ref $fhighld_region $scrdir 
fi



#***********************************************************************************************#
#                         Module: Final pre-imputation QC (pop-specific)                        #
#***********************************************************************************************#

if [ $module == "pop.preimpqc.final" ]; then

    submode=$2
    pop=$3
    pop_preqcdir=$4
    scrdir=$5

    #--------------------------------------------------------#
    #    Perform final SNP QC and write QC'ed plink files    #
    #--------------------------------------------------------#

    if [ $submode == "write.qc.plink" ]; then 
        bsub -q medium -o /dev/null $scrdir/15_pop_write_qc_plink.sh $pop $pop_preqcdir
    fi

    #--------------------------------------------------------#
    # Prepare data for HRC/1KG imputation (Michigan server)  #
    #--------------------------------------------------------#

    # Perform QC to align data with HRC or 1KG for imputation; chr-specific files generated
    if [ $submode == "prep.mis.imp" ]; then
        ref_panel=$6
        fref_check_pl=$7
        fref_sites=$8
        # bsub -q medium $scrdir/16_pop_prep_mis_imp.sh $pop $pop_preqcdir $ref_panel $fref_check_pl $fref_sites
        sh $scrdir/16_pop_prep_mis_imp.sh $pop $pop_preqcdir $ref_panel $fref_check_pl $fref_sites
    fi

    #--------------------------------------------------------#
    #      Convert plink to vcf for imputation using MIS     #
    #--------------------------------------------------------#

    if [ $submode == "write.qc.vcf" ]; then
        bsub -q big -J make_vcf[1-22] -W 3:00 -R rusage[mem=8000] -o /dev/null "$scrdir/17_pop_write_qc_vcf.sh $pop $pop_preqcdir"
    fi

fi



#***********************************************************************************************#
#                            Module: Post-imputation QC (pop-specific)                          #
#***********************************************************************************************#

if [ $module == "pop.postimpqc" ]; then

    submode=$2
    pop=$3
    pop_postqcdir=$4
    scrdir=$5

    #--------------------------------------------------------#
    #           Annotate imputed variants with rsID          #
    #--------------------------------------------------------#

    # Variant ID from MIS is in the form of chr:pos:ref:alt; annotate using dbSNP vcf to get rsIDs
    if [ $submode == "annotate.imp.vcf" ]; then 
        db_vcf=$6
        bsub -q big -J annotvcf[1-22] -W 15:00 -R rusage[mem=10000] -o /dev/null "$scrdir/18_pop_annot_imp_vcf.sh $pop $pop_postqcdir $db_vcf"
    fi

    #--------------------------------------------------------#
    #  Convert vcf (dosage) to plink and perform postimp QC  #
    #--------------------------------------------------------#

    if [ $submode == "vcf2plink" ]; then 
        maf_thresh=$6
        impRsq_thresh=$7
        fupdate_fid=$8
        fupdate_sex=$9
        bsub -q big -J vcf2plink[1-22] -W 5:00 -R rusage[mem=8000] -o /dev/null "$scrdir/19_pop_vcf2plink.sh $pop $pop_postqcdir $maf_thresh $impRsq_thresh $fupdate_fid $fupdate_sex"
    fi

    #--------------------------------------------------------#
    #   Create one merged plink file from chr-specifc files  #
    #--------------------------------------------------------#

    if [ $submode == "merge.imp.plink" ]; then
        maf_thresh=$6
        impRsq_thresh=$7
        bsub -q big -R rusage[mem=8000] -o /dev/null $scrdir/20_pop_merge_chr.sh $pop $pop_postqcdir $maf_thresh $impRsq_thresh
    fi

fi

