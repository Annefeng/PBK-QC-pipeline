#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
pop <- args[1]
pop_pcadir <- args[2]

###
setwd(pop_pcadir)
library(ggplot2)
library(ggsci)


# Read in data: pop-specific pbk samples PCA
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
    labs(x=paste0('PC',i), y=paste0('PC',i+1), title=paste0("pbk ",toupper(pop)," samples"),
         color="Study sample    ")
  # print(p)
  ggsave(paste0(pop,"_pbk_unrel.PC",i,"_PC",i+1,".pdf"), p, width=7.5, height=6)
}



######
# Read in data: pop-specific pbk samples + ref data PCA
pca_w_ref <- read.table(paste0(pop,"_pbk_ref.pca.eigenvec"), header=T, sep="\t", stringsAsFactors=F)
pca_w_ref$pop <- pca_w_ref$FID
if (pop == "eur") {
  pca_w_ref$pop <- ifelse(pca_w_ref$FID!="CEU" & pca_w_ref$FID!="TSI" & pca_w_ref$FID!="FIN" & pca_w_ref$pop!="GBR" & pca_w_ref$pop!="IBS", "pbk", pca_w_ref$pop)
  pca_w_ref$pop = factor(pca_w_ref$pop,levels=c("pbk","CEU","FIN","GBR","IBS","TSI"))
} else if (pop == "afr") {
  pca_w_ref$pop <- ifelse(pca_w_ref$FID!="YRI" & pca_w_ref$FID!="LWK" & pca_w_ref$FID!="GWD" & pca_w_ref$pop!="MSL" & pca_w_ref$pop!="ESN" & pca_w_ref$pop!="ASW" & pca_w_ref$pop!="ACB", "pbk", pca_w_ref$pop)
  pca_w_ref$pop = factor(pca_w_ref$pop,levels=c("pbk","YRI","LWK","GWD","MSL","ESN","ASW","ACB"))
} else if (pop == "eas") {
  pca_w_ref$pop <- ifelse(pca_w_ref$FID!="CHB" & pca_w_ref$FID!="JPT" & pca_w_ref$FID!="CHS" & pca_w_ref$pop!="CDX" & pca_w_ref$pop!="KHV", "pbk", pca_w_ref$pop)
  pca_w_ref$pop = factor(pca_w_ref$pop,levels=c("pbk","CHB","JPT","CHS","CDX","KHV"))
} else if (pop == "amr") {
  pca_w_ref$pop <- ifelse(pca_w_ref$FID!="MXL" & pca_w_ref$FID!="PUR" & pca_w_ref$pop!="CLM" & pca_w_ref$pop!="PEL", "pbk", pca_w_ref$pop)
  pca_w_ref$pop = factor(pca_w_ref$pop,levels=c("pbk","MXL","PUR","CLM","PEL"))
} else if (pop == "sas") {
  pca_w_ref$pop <- ifelse(pca_w_ref$FID!="GIH" & pca_w_ref$FID!="PJL" & pca_w_ref$FID!="BEB" & pca_w_ref$pop!="STU" & pca_w_ref$pop!="ITU", "pbk", pca_w_ref$pop)
  pca_w_ref$pop = factor(pca_w_ref$pop,levels=c("pbk","GIH","PJL","BEB","STU","ITU"))

}
table(pca_w_ref$pop)


# PC plots: pop-specific pbk + ref samples, colored by 1kg population
for(i in 1:5){
  p = ggplot(pca_w_ref, aes_string(x=paste0('PC',i), y=paste0('PC',i+1))) +
    geom_point(aes(color=pop), alpha=0.55) +
    scale_color_manual(values = c("grey25",pal_d3("category20")(20)[c(1:nlevels(pca_w_ref$pop))])) + 
    theme_bw() +
    guides(color = guide_legend(override.aes = list(size=2))) +
    labs(x=paste0('PC',i), y=paste0('PC',i+1), title=paste0(toupper(pop)," pbk + 1KG samples"),
         color="1KG populations")
  # print(p)
  ggsave(paste0(pop,"_pbk_unrel_ref.PC",i,"_PC",i+1,"_by_pop.pdf"), p, width=7.5, height=6)
}

