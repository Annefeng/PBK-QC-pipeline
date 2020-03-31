#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
pop <- args[1]
pop_preqcdir <- args[2]

setwd(pop_preqcdir)
library(ggplot2)

# Read in data
imp_sex <- read.table(paste0(pop,"_pbk_btqc_mgqc-chrx.sexcheck"), header=T)

imp_sex$PEDSEX <- factor(imp_sex$PEDSEX)
levels(imp_sex$PEDSEX) <- c("Male","Female")
imp_sex$SNPSEX <- factor(imp_sex$SNPSEX)
levels(imp_sex$SNPSEX) <- c("Unknown","Male","Female")


# Plot F-stat distribution: histogram
p <- ggplot(imp_sex, aes(x=F, fill=SNPSEX)) +
  geom_histogram(alpha=0.6, binwidth=0.02, color="black") +
  geom_vline(xintercept=0.8, linetype="dashed") + #default cutoff: >0.8: male
  geom_vline(xintercept=0.2, linetype="dashed") + #default cutoff: <0.2: female
  theme_bw() +
  labs(x='F-statistic',y='Frequency',
       title=paste0(toupper(pop),' sample QC'),
       fill='Imputed sex') +
  scale_fill_manual(values = c("grey30","#56B4E9","#FD8D3C"),labels=c("Unknown","Male","Female"))
ggsave(paste0(pop,"_pbk_sexcheck_fstat_F02_M08.pdf"), p, width=7.5, height=4)


# Plot: imputed vs. reported gender
pdf(paste0(pop,"_pbk_sexcheck_fstat_F02_M08_ped.vs.snpsex.pdf"), width=7.5, height=5)
ggplot(imp_sex, aes(y=F,x=factor(SNPSEX), color=factor(SNPSEX))) +
  geom_jitter(alpha=0.7) +
  labs(x='Imputed gender',y='chrX F-statistic',
       title=paste0(toupper(pop),' sample QC'),
       color='Imputed gender') +
  scale_color_manual(values = c("#7F7F7FFF","#56B4E9","#FD8D3C")) +
  theme_bw()
ggplot(imp_sex, aes(y=F,x=factor(SNPSEX), color=factor(PEDSEX))) +
  geom_jitter(alpha=0.7) +
  labs(x='Imputed gender',y='chrX F-statistic',
       title=paste0(toupper(pop),' sample QC'),
       color='Reported gender') +
  scale_color_manual(values = c("#56B4E9","#FD8D3C")) +
  theme_bw()
dev.off()


# Write out a list of sex discordant samples for removal: given a few differnet thresholds
sex_mismatch_F02_M08_inds <- imp_sex[(imp_sex$STATUS=="PROBLEM"), c("FID","IID")]

imp_sex$PEDSEX <- as.character(imp_sex$PEDSEX)
imp_sex$SNPSEX <- as.character(imp_sex$SNPSEX)
imp_sex$SNPSEX <- ifelse(imp_sex$F > 0.75, "Male", imp_sex$SNPSEX)
imp_sex$SNPSEX <- ifelse(imp_sex$F < 0.25, "Female", imp_sex$SNPSEX)
sex_mismatch_F025_M075_inds <- imp_sex[imp_sex$SNPSEX != imp_sex$PEDSEX, c("FID","IID")]
# dim(sex_mismatch_F025_M075_inds)

imp_sex$SNPSEX <- ifelse(imp_sex$F > 0.7, "Male", imp_sex$SNPSEX)
imp_sex$SNPSEX <- ifelse(imp_sex$F < 0.3, "Female", imp_sex$SNPSEX)
sex_mismatch_F03_M07_inds <- imp_sex[imp_sex$SNPSEX != imp_sex$PEDSEX, c("FID","IID")]
# dim(sex_mismatch_F03_M07_inds)

imp_sex$SNPSEX <- ifelse(imp_sex$F > 0.6, "Male", imp_sex$SNPSEX)
imp_sex$SNPSEX <- ifelse(imp_sex$F < 0.4, "Female", imp_sex$SNPSEX)
sex_mismatch_F04_M06_inds <- imp_sex[imp_sex$SNPSEX != imp_sex$PEDSEX, c("FID","IID")]
# dim(sex_mismatch_F06_M04_inds)

imp_sex$SNPSEX <- ifelse(imp_sex$F > 0.5, "Male", imp_sex$SNPSEX)
imp_sex$SNPSEX <- ifelse(imp_sex$F < 0.5, "Female", imp_sex$SNPSEX)
sex_mismatch_F05_M05_inds <- imp_sex[imp_sex$SNPSEX != imp_sex$PEDSEX, c("FID","IID")]
# dim(sex_mismatch_F05_M05_inds)


write.table(sex_mismatch_F02_M08_inds, paste0(pop,"_pbk_sex_mismatch_F02_M08.indlist"), quote=F, col.names=F, row.names=F)
write.table(sex_mismatch_F025_M075_inds, paste0(pop,"_pbk_sex_mismatch_F025_M075.indlist"), quote=F, col.names=F, row.names=F)
write.table(sex_mismatch_F03_M07_inds, paste0(pop,"_pbk_sex_mismatch_F03_M07.indlist"), quote=F, col.names=F, row.names=F)
write.table(sex_mismatch_F04_M06_inds, paste0(pop,"_pbk_sex_mismatch_F04_M06.indlist"), quote=F, col.names=F, row.names=F)
write.table(sex_mismatch_F05_M05_inds, paste0(pop,"_pbk_sex_mismatch_F05_M05.indlist"), quote=F, col.names=F, row.names=F)

