#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
pop <- args[1]
pop_preqcdir <- args[2]

setwd(pop_preqcdir)
library(ggplot2)

# Read in data
het <- read.table(paste0(pop,"_pbk_btqc_mgqc-inbr.hetrate"), header=T)


# Plot F-stat distribution
ggplot(het, aes(F)) +
  geom_histogram(alpha=0.6, binwidth=0.01, color="black", fill="#4DBBD5B2") +
  xlab("Inbreeding coefficient (F-stat)") +
  ylab("Frequency") +
  ggtitle(paste0(toupper(pop)," sample QC")) +
  geom_vline(xintercept=-0.2, linetype="dashed") +
  geom_vline(xintercept=0.2, linetype="dashed") +
  theme_bw()
ggsave(paste0(pop,"_pbk_hetcheck_fstat_thresh02.pdf"), width=7, height=4)

# Plot heterozygosity rate distribution
cutoff1 <- c(mean(het$HetRate) - 3*sd(het$HetRate),
			 mean(het$HetRate) + 3*sd(het$HetRate))
cutoff2 <- c(mean(het$HetRate) - 5*sd(het$HetRate),
			 mean(het$HetRate) + 5*sd(het$HetRate))

ggplot(het, aes(HetRate)) +
  geom_histogram(alpha=0.6, binwidth=0.001, color="black", fill="#4DBBD5B2") +
  xlab("Heterozygosity rate") +
  ylab("Frequency") +
  ggtitle(paste0(toupper(pop)," sample QC")) +
  geom_vline(xintercept=cutoff1[1], linetype="dashed") +
  geom_vline(xintercept=cutoff1[2], linetype="dashed") +
  geom_vline(xintercept=cutoff2[1], linetype="dashed") +
  geom_vline(xintercept=cutoff2[2], linetype="dashed") +
  annotate('text', label="mean - 3SD", x=cutoff1[1], y=4000, angle=90, size=2.5, vjust=-0.5) +
  annotate('text', label="mean + 3SD", x=cutoff1[2], y=4000, angle=90, size=2.5, vjust=-0.5) +
  annotate('text', label="mean - 5SD", x=cutoff2[1], y=4000, angle=90, size=2.5, vjust=-0.5) +
  annotate('text', label="mean + 5SD", x=cutoff2[2], y=4000, angle=90, size=2.5, vjust=-0.5) +
  theme_bw()
ggsave(paste0(pop,"_pbk_hetcheck_hetrate_dev_from_mean.pdf"), width=7, height=4)



# Write out a list of het outlier samples for removal: given a few different thresholds
het_fstat_outliers <- het[(het$F < -0.2 | het$F > 0.2), c("FID","IID")]
write.table(het_fstat_outliers, paste0(pop,"_pbk_het_outlier_f02.indlist"), quote=F, col.names=F, row.names=F)

hetrate_cutoff1_outliers <- het[(het$HetRate < cutoff1[1] | het$HetRate > cutoff1[2]), c("FID","IID")]
hetrate_cutoff2_outliers <- het[(het$HetRate < cutoff2[1] | het$HetRate > cutoff2[2]), c("FID","IID")]
write.table(hetrate_cutoff1_outliers, paste0(pop,"_pbk_het_outlier_3sd.indlist"), quote=F, col.names=F, row.names=F)
write.table(hetrate_cutoff2_outliers, paste0(pop,"_pbk_het_outlier_5sd.indlist"), quote=F, col.names=F, row.names=F)

