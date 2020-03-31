#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
pop <- args[1]
pop_preqcdir <- args[2]

setwd(pop_preqcdir)
library(ggplot2)
library(dplyr)
library(RColorBrewer)


# Read in data
ibd <- read.table(gzfile(paste0(pop,"_pbk_btqc_mgqc-ibd-min0.125.genome.gz")), header=T)

# Plot relatedness among pop-specific samples: Z0 vs. Z1 by inferred relationship
ibd$inferred_rel <- "Other relatedness"
ibd$inferred_rel <- ifelse(ibd$PI_HAT <= 0.2,
                          "Unrelated", ibd$inferred_rel)
ibd$inferred_rel <- ifelse(ibd$Z0<0.1 & ibd$Z1<0.1,
                          "Duplicates/MZ-twins", ibd$inferred_rel)
ibd$inferred_rel <- ifelse(ibd$Z0<0.1 & ibd$Z1>0.9,
                          "Parent-offspring", ibd$inferred_rel)
ibd$inferred_rel <- ifelse(ibd$Z0>0.125 & ibd$Z0<0.375,
                          "Siblings", ibd$inferred_rel)

ibd$inferred_rel <- factor(ibd$inferred_rel, levels=c("Duplicates/MZ-twins",
                                                      "Parent-offspring",
                                                      "Siblings",
                                                      "Other relatedness",
                                                      "Unrelated"))

table(ibd$inferred_rel)
# pop="eur":
# Duplicates/MZ-twins    Parent-offspring            Siblings   Other relatedness
#                  19                 349                 295                 341
#           Unrelated
#                 404

thresh <- 0.2
p <- ggplot(ibd, aes(Z0, Z1,color=inferred_rel)) +
  geom_point(alpha=0.8) +
  geom_abline(intercept=(2-2*thresh), slope=-2, linetype='dashed') +
  labs(x="\nProportion of loci with 0 allele shared by descent",
       y="Proportion of loci with 1 allele shared by descent\n",
       title="Pairwise relatedness with IBD > 0.125",
       color="Inferred relationship") +
  coord_cartesian(xlim=c(0,1), ylim=c(0,1)) +
  scale_color_manual(values = brewer.pal(9,"Set1")[1:5]) +
  theme_bw()
ggsave(paste0(pop,"_pbk_ibd_Z0.vs.Z1.pdf"), p, width=6.8, height=5)


# Remove one from each pair of related individuals
ibd_rel <- subset(ibd, PI_HAT > 0.2)
dim(ibd_rel) # pop="eur":1804
samples <- names(sort(table(unlist(ibd_rel[,c('IID1', 'IID2')])), decreasing=TRUE))
removed <- character()

k=0
for (row in 1:dim(ibd_rel)[1]) {
  
  i_sample = as.character(ibd_rel[row, 'IID1'])
  j_sample = as.character(ibd_rel[row, 'IID2'])
  
  i_index = match(i_sample, samples)
  j_index = match(j_sample, samples)
  
  if (is.na(i_index) | is.na(j_index)) { next }
  
  if (i_index <= j_index) {
    removed = c(removed, i_sample)
    samples = samples[!samples == i_sample]
  } else {
    removed = c(removed, j_sample)
    samples = samples[!samples == j_sample]
  }
  k=k+1
  print(k)
}
length(removed) # pop="eur":908
length(samples) # pop="eur":896


# Merge IID with FID for export
tmp1 <- ibd_rel[, c('FID1','IID1')]
names(tmp1) <- c('FID', 'IID')
tmp2 <- ibd_rel[, c('FID2','IID2')]
names(tmp2) <- c('FID', 'IID')
ibd_rel_inds <- rbind(tmp1, tmp2)
ibd_rel_inds <- ibd_rel_inds %>% distinct()  # pop="eur":1804
ibd_rel_inds_remove <- subset(ibd_rel_inds, IID %in% removed)

# Write out a list of relatedness individuals for removal
write.table(ibd_rel_inds_remove, paste0(pop,"_pbk_ibd_pihat02.indlist"), quote=F, col.names=F, row.names=F)


