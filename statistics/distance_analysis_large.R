library(ggplot2)
library(distributions3)
library(reshape2)
library(tidyverse)
library(ggpubr)
library(rstatix)
library(dplyr)
library(data.table)


df <- read.csv("~/work/projects/multilingual_lfe/statistics/cv_distances_large.csv")
df <- read.csv("~/work/projects/multilingual_lfe/statistics/cv_distances_large_newonly.csv")


dataset="CommonVoice"

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



#1. Remove outliers.... Replace them by NA
df$syntactic = na_if(df$syntactic, 0) #replace by NA the 0 in syntactc
df$inventory = na_if(df$inventory, 0) 


df[c( "hd_lda_euclidean_norm")] <- lapply(df[c("hd_lda_euclidean" )],normalize)




#Frol https://cran.r-project.org/web/packages/distributions3/vignettes/two-sample-z-test.html
qqnorm(df$hd_lda_euclidean)
qqline(df$hd_lda_euclidean)


ggplot(df, aes(x=hd_lda_euclidean_norm, y=syntactic)) +geom_point() + labs(x = "Euclidean Distance", y="syntactic") +  stat_smooth(method="lm",aes(fill=hd_lda_euclidean_norm))+ ggtitle("Euclidean distance (lda) vs syntax in function of language pair", subtitle = "CV - HD")

ggplot(df, aes(x=hd_lda_euclidean_norm, y=jaccard_phoible)) +geom_point() + labs(x = "Euclidean Distance", y="Phoible Jaccard") +  stat_smooth(method="lm",aes(fill=hd_lda_euclidean_norm))+ ggtitle("Euclidean distance (lda) vs syntax in function of language pair", subtitle = "CV - HD")


#per distance
d_feat_hd_dist <- reshape2::melt(df, id.vars=c("langpair","hd_lda_euclidean_norm"),measure.vars = c("phono","syntactic","inventory", "genetic"))

ggplot(d_feat_hd_dist, aes(value,hd_lda_euclidean_norm,color=variable)) + labs(x = "Ling distances", y="Euclidean dist (+LDA)") + 
  geom_point() +  ggtitle(NULL, subtitle =  paste(dataset, "dataset - high-dimension")) + 
  facet_wrap(~variable, scales = "free_x")  + stat_smooth(method="lm",aes(fill=variable)) #remove free if want same x acis dor all




library(RVAideMemoire)

#Inital distances
res=perm.cor.test(df$hd_lda_euclidean, df$syntactic, nperm = 999, progress = TRUE)
print(paste('Syntactic Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
res=perm.cor.test(df$hd_lda_euclidean, df$phono, nperm = 999, progress = FALSE)
print(paste('Phonological Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
res=perm.cor.test(df$hd_lda_euclidean, df$inventory, nperm = 999, progress = FALSE)
print(paste('Inventory Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
res=perm.cor.test(df$hd_lda_euclidean, df$genetic, nperm = 999, progress = FALSE)
print(paste('Genetic Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))


res=perm.cor.test(df$hd_lda_euclidean, df$jaccard_phoible, nperm = 999, progress = FALSE)
print(paste('Phoible Jaccard Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))


y="hd_lda_euclidean"

for (x in names(df[,2:6])){
  
  print(x)
  

  A=df[[y]]
  B=df[[x]]

  
  res=perm.cor.test(A, B, nperm = 9999, progress = FALSE)
  print(paste(dataset,' Dataset - ',y,' vs ',x,': Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
  print("--------------------")
  
  
}

df <- df_original[sample(nrow(df), 50), ]



# Below : all of them


comb_col=combn(names(df[,2:17]),2,simplify=FALSE)

for (x in comb_col){
  
  A=x[1]
  B=x[2]
  df_A=df[[A]]
  df_B=df[[B]]

  res=perm.cor.test(df_A, df_B, nperm = 9999, progress = FALSE)
  print(paste(dataset,' Dataset - ',A,' vs ',B,': Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
  print("--------------------")
  
  
  }
