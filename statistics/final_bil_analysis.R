#!/usr/bin/env Rscript
shhh <- suppressPackageStartupMessages # It's a library, so shhh!


shhh(library(ggplot2))
shhh(library(distributions3))
shhh(library(data.table))


shhh(library(dplyr))

shhh(library(ggpubr))
shhh(library(rstatix))

shhh(library(BSDA))
shhh(library(coin))
library(reshape2)
library(forcats)



get_pvalue <- function(df, condA, condB, paired=FALSE){
  if (isTRUE(paired)){
    
    res = pvalue(oneway_test(score ~ cond | id , data=rbind(df[df$cond == condA,], df[df_FI$cond == condB,]),
                             distribution=approximate(nresample=999)))[1]
  }
  else {
    res = pvalue(oneway_test(score ~ cond , data=rbind(df[df$cond == condA,], df[df_FI$cond == condB,]),
                             distribution=approximate(nresample=999)))[1]
  }
  
  if (res>0.05) {sig="ns"}
  else if (res>0.005) {sig="*"}
  else {sig = "**"}
  
  return(list("score"=res, "sig" = sig))
  
}




#================================================================================================
#================================================================================================
#C. On UNFAMILIAR DatA. CommonVoice
#================================================================================================
#================================================================================================
path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe_cv/"
path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe_cv_highdim/"
numgauss=128
numgauss=2048
csv="data_on_spk_by_lang.csv"

# #------------------------------------------------------------------------------
# # Function bil df
# get_cv_bil_df_spec <- function(lang_B, lang_A, lang_C) {
#     mono_same_df <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'))
#     mono_diff_df_A <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_C,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'))
#     mono_diff_df_C <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'))
#     
#     #check which order in data path
#     if (file.exists(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""))) {
#       lang_a=lang_A
#       lang_b=lang_B
#     } else {
#       lang_a=lang_B
#       lang_b=lang_A
#     }
#     
#     bil_same_df <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_a,"+",lang_b,"_A_train-15h-60spk_ts-",lang_b,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_a,"+",lang_b,"_B_train-15h-60spk_ts-",lang_b,"_test-0h-20spk/", csv, sep=""), sep='\t'))
#     
#     if (file.exists(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""))) {
#       lang_a=lang_A
#       lang_c=lang_C
#     } else {
#       lang_a=lang_C
#       lang_c=lang_A
#     }
#     
#     
#     bil_diff_df <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_a,"+",lang_c,"_A_train-15h-60spk_ts-",lang_b,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_a,"+",lang_c,"_B_train-15h-60spk_ts-",lang_b,"_test-0h-20spk/", csv, sep=""), sep='\t'))
#     
#     
#     mono_same_df$lang =rep(lang_B,nrow(mono_same_df))
#     mono_diff_df_C$lang =rep(lang_C,nrow(mono_diff_df_C))
#     mono_diff_df_A$lang =rep(lang_A,nrow(mono_diff_df_A))
#     bil_same_df$lang =rep(paste(lang_A,"+",lang_B, sep=""),nrow(bil_same_df))
#     bil_diff_df$lang =rep(paste(lang_A,"+",lang_C, sep=""),nrow(bil_same_df))
#     
#     mono_same_df$cond =rep("mono familiar",nrow(mono_same_df))
#     mono_diff_df_C$cond =rep("mono unfamiliar",nrow(mono_diff_df_C))
#     mono_diff_df_A$cond =rep("mono unfamiliar",nrow(mono_diff_df_A))
#     # mono_same_df$cond =rep(lang_B,nrow(mono_same_df))
#     # mono_diff_df$cond =rep(lang_C,nrow(mono_diff_df))
#     bil_same_df$cond =rep("mix familiar",nrow(bil_same_df))
#     bil_diff_df$cond =rep("mix unfamiliar",nrow(bil_same_df))
#     
#     df = rbind(mono_same_df, mono_diff_df_A, mono_diff_df_C, bil_same_df, bil_diff_df)
#     df$lang = as_factor(df$lang)
#     df$cond = as_factor(df$cond)
#     df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
#     df$score_normalised = 100 - (df$score) * 100
#     
#     return(df)
# }
# #------------------------------------------------------------------------------
get_cv_bil_df <- function(lang_A, lang_B, lang_C) {
  mono_same_df <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_C,"_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  mono_diff_df <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_C,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_C,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'))

  
  bil_same_df_A <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_A_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_A_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  bil_same_df_B <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_B_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_B_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  bil_same_df <- rbind(bil_same_df_A, bil_same_df_B) 
  bil_diff_df_A <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  bil_diff_df_B <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  bil_diff_df <- rbind(bil_diff_df_A, bil_diff_df_B) 
  
  
  # mono_same_df$lang =rep(lang_B,nrow(mono_same_df))
  # mono_diff_df_C$lang =rep(lang_C,nrow(mono_diff_df_C))
  # mono_diff_df_A$lang =rep(lang_A,nrow(mono_diff_df_A))
  # bil_same_df$lang =rep(paste(lang_A,"+",lang_B, sep=""),nrow(bil_same_df))
  # bil_diff_df$lang =rep(paste(lang_A,"+",lang_C, sep=""),nrow(bil_same_df))
  # 
  
  mono_same_df$cond =rep("mono familiar",nrow(mono_same_df))
  mono_diff_df$cond =rep("mono unfamiliar",nrow(mono_diff_df))

  bil_same_df$cond =rep("mix familiar",nrow(bil_same_df))
  bil_diff_df$cond =rep("mix unfamiliar",nrow(bil_diff_df))
  
  df = rbind(mono_same_df, mono_diff_df,  bil_same_df, bil_diff_df)
  # df$lang = as_factor(df$lang)
  df$cond = as_factor(df$cond)
  df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
  df$score_normalised = 100 - (df$score) * 100
  
  return(df)
}
#------------------------------------------------------------------------------



lang_A="en"
lang_B="fr"
lang_C="it"


df=get_cv_bil_df(lang_A, lang_B, lang_C)


my_comparisons <- list( c("mono familiar", "mono unfamiliar"), c("mix unfamiliar", "mono familiar"), c("mix unfamiliar", "mono unfamiliar"), c("mix familiar", "mono unfamiliar"))
my_comparisons <- list( c("mono familiar", "mono unfamiliar"), c("mix unfamiliar", "mono familiar"), c("mix unfamiliar", "mono unfamiliar"))

compare_means(score_normalised ~ cond, data = df_filtered, paired = FALSE, method = "t.test" )


df_filtered = df[df$cond != 'mix familiar',]
ggboxplot(df_filtered, x = "cond", y = "score_normalised", notch=FALSE,
          color = "cond", line.color = "gray", line.size = 0.02,
          palette = "jco", legend="none",
          ylab="ABX score (in %)", xlab="")+
  stat_compare_means(paired = FALSE, comparisons=my_comparisons, label =  "p.signif", label.x = 1.5, size=5) +
  ggtitle ("Speaker Discrimination scores on different averaged conditions", subtitle="EN, FR and IT (and all mix combinations)") 
  

ggbarplot(df, x = "cond", y = "score_normalised", merge=TRUE,
          color = "cond", line.color = "gray", line.size = 0.02,
          palette = "jco", legend="none",
          ylab="ABX score (in %)", xlab="")+
  stat_compare_means(paired = FALSE, comparisons=my_comparisons, label =  "p.signif", label.x = 1.5, size=5)



my_comparisons <- list( c("mono_same", "mono_different"), c("mono_same", "mix"), c("mono_different", "mix") )
# compare_means(score_normalised ~ cond, data = df_filtered, paired = FALSE, method = "t.test" )




#================================================================================================
#================================================================================================
#C. On UNFAMILIAR DatA. Librivox
#================================================================================================
#================================================================================================

get_cv_bil_df <- function(lang_A, lang_B, lang_C) {
  mono_same_df <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_C,"_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  mono_diff_df <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_C,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_C,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  
  
  bil_same_df_A <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_A_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_A_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  bil_same_df_B <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_B_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_B_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  bil_same_df <- rbind(bil_same_df_A, bil_same_df_B) 
  bil_diff_df_A <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  bil_diff_df_B <- rbind(read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_C,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_A,"+",lang_C,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_",numgauss,"_tr-",lang_B,"+",lang_C,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep=""), sep='\t'))
  bil_diff_df <- rbind(bil_diff_df_A, bil_diff_df_B) 
  
  
  # mono_same_df$lang =rep(lang_B,nrow(mono_same_df))
  # mono_diff_df_C$lang =rep(lang_C,nrow(mono_diff_df_C))
  # mono_diff_df_A$lang =rep(lang_A,nrow(mono_diff_df_A))
  # bil_same_df$lang =rep(paste(lang_A,"+",lang_B, sep=""),nrow(bil_same_df))
  # bil_diff_df$lang =rep(paste(lang_A,"+",lang_C, sep=""),nrow(bil_same_df))
  # 
  
  mono_same_df$cond =rep("mono familiar",nrow(mono_same_df))
  mono_diff_df$cond =rep("mono unfamiliar",nrow(mono_diff_df))
  
  bil_same_df$cond =rep("mix familiar",nrow(bil_same_df))
  bil_diff_df$cond =rep("mix unfamiliar",nrow(bil_diff_df))
  
  df = rbind(mono_same_df, mono_diff_df,  bil_same_df, bil_diff_df)
  # df$lang = as_factor(df$lang)
  df$cond = as_factor(df$cond)
  df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
  df$score_normalised = 100 - (df$score) * 100
  
  return(df)
}