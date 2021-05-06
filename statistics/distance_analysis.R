library(ggplot2)
library(distributions3)
library(reshape2)
library(tidyverse)
library(ggpubr)
library(rstatix)

library(data.table)

lb_df <- read.csv("~/work/projects/multilingual_lfe/statistics/lb_distances.csv")
cv_df <- read.csv("~/work/projects/multilingual_lfe/statistics/cv_distances.csv")



df=cv_df
dataset="CommonVoice"

df=lb_df
dataset="LibriVox"

#if significant only:
df = subset(df, hd_sig==1)
df = subset(df, ld_sig==1)


normalize<-function(y) {
  
  x<-y[!is.na(y)]
  
  x<-(x - min(x)) / (max(x) - min(x))
  
  y[!is.na(y)]<-x
  
  return(y)
}

normalize_and_invert<-function(y) {
  
  x<--1*y[!is.na(y)]
  
  x<-(x - min(x)) / (max(x) - min(x))
  
  y[!is.na(y)]<-x
  
  return(y)
}



df[c("hd_euclidean_norm", "ld_euclidean_norm")] <- lapply(df[c("hd_euclidean", "ld_euclidean" )],normalize)
df[c("hd_cosine_norm", "ld_cosine_norm" )] <- lapply(df[c("hd_cosine", "ld_cosine" )],normalize_and_invert)


#Frol https://cran.r-project.org/web/packages/distributions3/vignettes/two-sample-z-test.html
qqnorm(df$hd_lfe)
qqline(df$hd_lfe)

qqnorm(df$hd_cosine_norm)
qqline(df$hd_cosine_norm)


ggplot(df, aes(x=hd_euclidean_norm, y=hd_lfe)) +geom_point() + labs(x = "Euclidean Distance", y="LFE") + geom_text(label=cv_df$langpair, nudge_y = +2.5) + ggtitle("Average distance vs LFE in function of language pair", subtitle = "CV - HD")
ggplot(df, aes(x=hd_lfe, y=hd_euclidean_norm)) +geom_point() + labs(x ="LFE" , y="Euclidean Distance") + geom_text(label=cv_df$langpair, nudge_x = +2.5) + ggtitle("Average distance vs LFE in function of language pair", subtitle = "CV - HD")

# ggplot(df, aes(x=av_dist, y=lfe)) +geom_point() + labs(x = "Average distance", y="LFE") + geom_smooth(method=lm)
# ggplot(df, aes(x=av_dist, y=lfe)) +geom_point() + labs(x = "Average distance", y="LFE") + geom_smooth(method=lm, se=FALSE)
# ggplot(df, aes(x=av_dist, y=lfe)) +geom_point() + labs(x = "Average distance", y="LFE") +geom_smooth()


#per distance
d_feat_hd <- reshape2::melt(df, id.vars=c("langpair","hd_lfe"),measure.vars = c("phono","syntactic","inventory"))
d_centroid_hd <- reshape2::melt(df, id.vars=c("langpair","hd_lfe"),measure.vars = c("hd_euclidean_norm","hd_cosine_norm"))
d_feat_ld <- reshape2::melt(df, id.vars=c("langpair","ld_lfe"),measure.vars = c("phono","syntactic","inventory"))
d_centroid_ld <- reshape2::melt(df, id.vars=c("langpair","ld_lfe"),measure.vars = c("hd_euclidean_norm","hd_cosine_norm"))

ggplot(d_feat_hd, aes(value,hd_lfe,color=variable)) + labs(x = "Average distances", y="LFE") + 
  geom_point() +  ggtitle(NULL, subtitle =  paste(dataset, "dataset - high-dimension")) + 
  facet_wrap(~variable, scales = "free_x")  + stat_smooth(method="lm",aes(fill=variable)) #remove free if want same x acis dor all

ggplot(d_centroid_hd, aes(value,hd_lfe,color=variable)) + labs(x = "Average distances", y="LFE") + 
  geom_point() +  ggtitle(NULL, subtitle =  paste(dataset, "dataset - high-dimension")) + 
  facet_wrap(~variable, scales = "free_x")  + stat_smooth(method="lm",aes(fill=variable)) #remove free if want same x acis dor all

ggplot(d_centroid_hd, aes(hd_lfe,value,color=variable)) + labs(x = "Average distances", y="LFE") + 
  geom_point() +  ggtitle(NULL, subtitle =  paste(dataset, "dataset - high-dimension")) + 
  facet_wrap(~variable, scales = "free_x")  + stat_smooth(method="lm",aes(fill=variable)) #remove free if want same x acis dor all




ggplot(d_feat_ld, aes(value,ld_lfe,color=variable)) + labs(x = "Average distances", y="LFE") + 
  geom_point() +  ggtitle(NULL, subtitle =  paste(dataset, "dataset - low-dimension")) + 
  facet_wrap(~variable, scales = "free_x")  + stat_smooth(method="lm",aes(fill=variable)) #remove free if want same x acis dor all

ggplot(d_centroid_ld, aes(value,ld_lfe,color=variable)) + labs(x = "Average distances", y="LFE") + 
  geom_point() +  ggtitle(NULL, subtitle =  paste(dataset, "dataset - low-dimension")) + 
  facet_wrap(~variable, scales = "free_x")  + stat_smooth(method="lm",aes(fill=variable)) #remove free if want same x acis dor all





library(RVAideMemoire)

#Inital distances
res=perm.cor.test(df$hd_lfe, df$syntactic, nperm = 999, progress = TRUE)
print(paste('Syntactic Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
res=perm.cor.test(df$hd_lfe, df$phono, nperm = 999, progress = FALSE)
print(paste('Phonological Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
res=perm.cor.test(df$hd_lfe, df$inventory, nperm = 999, progress = FALSE)
print(paste('Inventory Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))


#Centroid distances
res=perm.cor.test(df$hd_lfe, df$hd_euclidean_norm, nperm = 999, progress = TRUE)
print(paste(dataset,' Dataset - HD - Euclidean Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
res=perm.cor.test(df$hd_lfe, df$hd_cosine_norm, nperm = 999, progress = TRUE)
print(paste(dataset,' Dataset - HD - Cosine Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))

res=perm.cor.test(df$ld_lfe, df$ld_euclidean_norm, nperm = 999, progress = TRUE)
print(paste(dataset,' Dataset - LD - Euclidean Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
res=perm.cor.test(df$ld_lfe, df$ld_cosine_norm, nperm = 999, progress = TRUE)
print(paste(dataset,' Dataset - LD - Cosine Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))


#Euclidean feat dist
res=perm.cor.test(df$ld_lfe, df$ld_euclidean_norm, nperm = 999, progress = TRUE)


comb_col=combn(names(df[,6:15]),2,simplify=FALSE)

for (x in comb_col){
  
  A=x[1]
  B=x[2]
  df_A=df[[A]]
  df_B=df[[B]]

  res=perm.cor.test(df_A, df_B, nperm = 9999, progress = FALSE)
  print(paste(dataset,' Dataset - ',A,' vs ',B,': Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
  print("--------------------")
  
  
  }
