#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
preqcdir <- args[1]
missdiff_thresh <- as.numeric(args[2])

setwd(preqcdir)

dat_missdiff <- read.table("snp_missRateDiff_btw_batch.tsv", h=T, sep="\t", stringsAsFactors=F)

snps_to_remove <- NULL
for ( i in 2:ncol(dat_missdiff) ){
    # print(i)
    print(names(dat_missdiff)[i])
    snps_w_missdiff <- dat_missdiff$snplist[abs(dat_missdiff[, i]) > missdiff_thresh]
    print(length(snps_w_missdiff))
    # Write out SNPs with missing rate diff > missdiff_threshold in the given batch-pair
    write.table(snps_w_missdiff, paste0(names(dat_missdiff)[i],"_missRateDiff",missdiff_thresh,"_snplist"), quote=F, col.names=F, row.names=F)
    # Append these SNPs to the list of SNPs to be removed
    snps_to_remove <- c(snps_to_remove, snps_w_missdiff)
}

# Write out the union of SNPs that show differential missing rate in any given pair of batches
snps_to_remove <- unique(snps_to_remove)
write.table(snps_to_remove, paste0("overall_missRateDiff",missdiff_thresh,".snplist"), quote=F, col.names=F, row.names=F)