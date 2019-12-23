#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
preqcdir <- args[1]
fbatchpr <- args[2]

library(data.table)
library(ggplot2)

setwd(preqcdir)


# Read in overlapping SNP list
snplist <- fread("pbk_geno05_mind02_geno02.lmiss.common.snplist", colClasses=c("character"), h=F, sep="\t")
snplist <- snplist$V1


# # Find unique, pairwise batch combinations
# # batches <- c("MEGA", "MEG_A1_A", "MEG_A1_B", "MEGAEX", "MEG_C", "MEG_D", "MEG_E", "MEG_X1")
# batches <- strsplit(batches,"[,]")[[1]]
# # print(batches)
# uniq_batch_pair <- t(combn(batches, 2))
# write.table(uniq_batch_pair, paste0(miscdir,"/uniq_batch_pairs.tsv"), quote=F, col.names=F, row.names=F)

# Read in the possible comb. of batch pairs
uniq_batch_pair <- read.table(fbatchpr, h=F)


# Create an empty matirx for saving missing rate diff btw pairs of batches
dat_misdiff <- as.data.frame(matrix(nrow=length(snplist), ncol=nrow(uniq_batch_pair)))
names(dat_misdiff) <- paste0(uniq_batch_pair[,1],".",uniq_batch_pair[,2])
dat_misdiff <- cbind(snplist, dat_misdiff)


pdf("snp_missRateDiff_btw_batch.pdf", width=7, height=5)
for ( i in 1:nrow(uniq_batch_pair) ) {

    print(i)
    # print(c(x, y))
    x <- uniq_batch_pair[i, 1]
    y <- uniq_batch_pair[i, 2]

    dat1 <- fread(paste0(x,"/pbk_geno05_mind02_geno02.lmiss"), h=T)
    dat2 <- fread(paste0(y,"/pbk_geno05_mind02_geno02.lmiss"), h=T)

    # Keep only overlapping SNPs across batches
    dat1 <- dat1[dat1$SNP %in% snplist, ]
    dat2 <- dat2[dat2$SNP %in% snplist, ]


    # Merge every two batches based on SNP id and calculate missing rate difference
    comb <- merge(dat1[,c(2,5)], dat2[,c(2,5)], by="SNP")
    comb$F_MISS.diff <- comb$F_MISS.x - comb$F_MISS.y
    dat_misdiff[,paste0(x,".",y)] <- comb$F_MISS.diff


    # Plot the distribution of pairwise missing call rate difference
    p <- ggplot(comb, aes(F_MISS.diff)) +
        geom_histogram(aes(y=..count../sum(..count..)), alpha=0.6, binwidth=0.0005, color="black", fill="#4DBBD5B2", size=0.4) +
        xlab("Variant missing rate difference between a pair of batches") +
        ylab("Proportion of variants") +
        scale_x_continuous(breaks=scales::pretty_breaks(n=10)) +
        scale_y_continuous(breaks=scales::pretty_breaks(n=10)) +
        ggtitle(paste0(x," vs. ", y)) +
        theme_bw()
    print(p)

}
dev.off()


# Save the missing rate diff matrix for later use
fwrite(dat_misdiff, "snp_missRateDiff_btw_batch.tsv", quote=F, col.names=T, row.names=F, 
    sep="\t")

