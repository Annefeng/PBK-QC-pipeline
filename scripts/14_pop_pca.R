#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
pop <- args[1]
pop_pcadir <- args[2]

###
setwd(pop_pcadir)
library(ggplot2)
library(ggsci)


# Read in data: EUR pbk samples PCA
pca <- read.table(paste0(pop,"_pbk_unrel.pca.eigenvec"), header=T, sep="\t", stringsAsFactors=F)
dim(pca)
pca$pop <- "pbk"


# PC plots: pop-specific pbk samples
for(i in 1:5){
  p = ggplot(pca, aes_string(x=paste0('PC',i), y=paste0('PC',i+1))) +
    geom_point(aes(color=pop), alpha=0.57, size=0.97) +
    scale_color_manual(values = pal_d3("category20")(20)[1]) + 
    theme_bw() +
    guides(color = guide_legend(override.aes = list(size=2))) +
    labs(x=paste0('PC',i), y=paste0('PC',i+1), title="pbk EUR samples",
         color="Study sample    ")
  # print(p)
  ggsave(paste0(pop,"_pbk_unrel.PC",i,"_PC",i+1,".pdf"), p, width=7.5, height=6)
}



######
# Read in data: pop-specific pbk samples + ref data PCA
pca_w_ref <- read.table(paste0(pop,"_pbk_ref.pca.eigenvec"), header=T, sep="\t", stringsAsFactors=F)
pca_w_ref$pop <- pca_w_ref$FID
pca_w_ref$pop <- ifelse(pca_w_ref$FID!="CEU" & pca_w_ref$FID!="TSI" & pca_w_ref$FID!="FIN" & pca_w_ref$pop!="GBR" & pca_w_ref$pop!="IBS", "pbk", pca_w_ref$pop)
table(pca_w_ref$pop)


# PC plots: pop-specific pbk + ref samples, colored by 1kg population
pca_w_ref$pop = factor(pca_w_ref$pop,levels=c("pbk","CEU","FIN","GBR","IBS","TSI"))

for(i in 1:5){
  p = ggplot(pca_w_ref, aes_string(x=paste0('PC',i), y=paste0('PC',i+1))) +
    geom_point(aes(color=pop), alpha=0.55) +
    scale_color_manual(values = c("grey25",pal_d3("category20")(20)[c(1:5)])) + 
    theme_bw() +
    guides(color = guide_legend(override.aes = list(size=2))) +
    labs(x=paste0('PC',i), y=paste0('PC',i+1), title="EUR pbk + 1KG samples",
         color="1KG populations")
  # print(p)
  ggsave(paste0(pop,"_pbk_unrel_ref.PC",i,"_PC",i+1,"_by_pop.pdf"), p, width=7.5, height=6)
}

