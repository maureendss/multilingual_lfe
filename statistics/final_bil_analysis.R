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
#A. LIBRIVOX DATA. 
#================================================================================================
#================================================================================================


path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe_bil/"
csv="data_on_spk_by_lang.csv"

#===================================================================================================
# Then Look at LFE for condition on oboth tests
# Only reporting data without monolingual. 

#-----------------------------------------------------------------------------------------------
#HERE ENG-FIN - mono native
langpair="Eng-Fin"
trFin_tsEng=paste(path, "ivector_128_tr-train_mono_fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trFin_tsFin=paste(path, "ivector_128_tr-train_mono_fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
trEng_tsEng=paste(path, "ivector_128_tr-train_mono_eng_native_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trEng_tsFin=paste(path, "ivector_128_tr-train_mono_eng_native_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
lang_A="English"
lang_B="Finnish"
mono_same_df <- rbind(read.csv(trFin_tsFin, sep='\t'), read.csv(trEng_tsEng, sep='\t'))
mono_same_df$cond =rep("mono_same",nrow(mono_same_df))

mono_different_df<- rbind(read.csv(trFin_tsEng, sep='\t'), read.csv(trEng_tsFin, sep='\t'))
mono_different_df$cond =rep("mono_different",nrow(mono_same_df))


bil1_tsEng=paste(path, "ivector_128_tr-train_bil_1_eng-fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
bil2_tsEng=paste(path, "ivector_128_tr-train_bil_2_eng-fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
bil1_tsFin=paste(path, "ivector_128_tr-train_bil_1_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
bil2_tsFin=paste(path, "ivector_128_tr-train_bil_2_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
bil_df <- rbind(read.csv(bil1_tsEng, sep='\t'), read.csv(bil2_tsEng, sep='\t'),read.csv(bil1_tsFin, sep='\t'),read.csv(bil2_tsFin, sep='\t') )
bil_df$cond =rep("bil",nrow(bil_df))

mix1_tsEng=paste(path, "ivector_128_tr-train_mix_1_eng-fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
mix2_tsEng=paste(path, "ivector_128_tr-train_mix_2_eng-fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
mix1_tsFin=paste(path, "ivector_128_tr-train_mix_1_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
mix2_tsFin=paste(path, "ivector_128_tr-train_mix_2_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
mix_df <- rbind(read.csv(mix1_tsEng, sep='\t'), read.csv(mix2_tsEng, sep='\t'),read.csv(mix1_tsFin, sep='\t'),read.csv(mix2_tsFin, sep='\t') )
mix_df$cond =rep("mix",nrow(mix_df))


df_EF_nat = rbind(mono_same_df, mono_different_df, bil_df, mix_df)
df_EF_nat$cond = as_factor(df$cond)
df_EF_nat$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
df_EF_nat$score_normalised = (df$score) * 100


#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
#HERE ENG-FIN - mono original
langpair="Eng-Fin"
trFin_tsEng=paste(path, "ivector_128_tr-train_mono_fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trFin_tsFin=paste(path, "ivector_128_tr-train_mono_fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
trEng_tsEng=paste(path, "ivector_128_tr-train_mono_eng_finspk_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trEng_tsFin=paste(path, "ivector_128_tr-train_mono_eng_finspk_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
lang_A="English"
lang_B="Finnish"
mono_same_df <- rbind(read.csv(trFin_tsFin, sep='\t'), read.csv(trEng_tsEng, sep='\t'))
mono_same_df$cond =rep("mono_same",nrow(mono_same_df))

mono_different_df<- rbind(read.csv(trFin_tsEng, sep='\t'), read.csv(trEng_tsFin, sep='\t'))
mono_different_df$cond =rep("mono_different",nrow(mono_same_df))


bil1_tsEng=paste(path, "ivector_128_tr-train_bil_1_eng-fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
bil2_tsEng=paste(path, "ivector_128_tr-train_bil_2_eng-fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
bil1_tsFin=paste(path, "ivector_128_tr-train_bil_1_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
bil2_tsFin=paste(path, "ivector_128_tr-train_bil_2_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
bil_df <- rbind(read.csv(bil1_tsEng, sep='\t'), read.csv(bil2_tsEng, sep='\t'),read.csv(bil1_tsFin, sep='\t'),read.csv(bil2_tsFin, sep='\t') )
bil_df$cond =rep("bil",nrow(bil_df))

mix1_tsEng=paste(path, "ivector_128_tr-train_mix_1_eng-fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
mix2_tsEng=paste(path, "ivector_128_tr-train_mix_2_eng-fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
mix1_tsFin=paste(path, "ivector_128_tr-train_mix_1_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
mix2_tsFin=paste(path, "ivector_128_tr-train_mix_2_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
mix_df <- rbind(read.csv(mix1_tsEng, sep='\t'), read.csv(mix2_tsEng, sep='\t'),read.csv(mix1_tsFin, sep='\t'),read.csv(mix2_tsFin, sep='\t') )
mix_df$cond =rep("mix",nrow(mix_df))

df_EF_acc = rbind(mono_same_df, mono_different_df, bil_df, mix_df)
df_EF_acc$cond = as_factor(df$cond)
df_EF_acc$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
df_EF_acc$score_normalised = (df$score) * 100



#-----------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------
#HERE ENG-FGer- mono native
langpair="Eng-Ger"
trGer_tsEng=paste(path, "ivector_128_tr-train_mono_ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trGer_tsGer=paste(path, "ivector_128_tr-train_mono_ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
trEng_tsEng=paste(path, "ivector_128_tr-train_mono_eng_native_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trEng_tsGer=paste(path, "ivector_128_tr-train_mono_eng_native_ts-test_German_lb_0.5h_10spk/", csv, sep="")
lang_A="English"
lang_B="German"
mono_same_df <- rbind(read.csv(trGer_tsGer, sep='\t'), read.csv(trEng_tsEng, sep='\t'))
mono_same_df$cond =rep("mono_same",nrow(mono_same_df))

mono_different_df<- rbind(read.csv(trGer_tsEng, sep='\t'), read.csv(trEng_tsGer, sep='\t'))
mono_different_df$cond =rep("mono_different",nrow(mono_same_df))


bil1_tsEng=paste(path, "ivector_128_tr-train_bil_1_eng-ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
bil2_tsEng=paste(path, "ivector_128_tr-train_bil_2_eng-ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
bil1_tsGer=paste(path, "ivector_128_tr-train_bil_1_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
bil2_tsGer=paste(path, "ivector_128_tr-train_bil_2_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
bil_df <- rbind(read.csv(bil1_tsEng, sep='\t'), read.csv(bil2_tsEng, sep='\t'),read.csv(bil1_tsGer, sep='\t'),read.csv(bil2_tsGer, sep='\t') )
bil_df$cond =rep("bil",nrow(bil_df))

mix1_tsEng=paste(path, "ivector_128_tr-train_mix_1_eng-ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
mix2_tsEng=paste(path, "ivector_128_tr-train_mix_2_eng-ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
mix1_tsGer=paste(path, "ivector_128_tr-train_mix_1_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
mix2_tsGer=paste(path, "ivector_128_tr-train_mix_2_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
mix_df <- rbind(read.csv(mix1_tsEng, sep='\t'), read.csv(mix2_tsEng, sep='\t'),read.csv(mix1_tsGer, sep='\t'),read.csv(mix2_tsGer, sep='\t') )
mix_df$cond =rep("mix",nrow(mix_df))

df_EG_nat = rbind(mono_same_df, mono_different_df, bil_df, mix_df)
df_EG_nat$cond = as_factor(df$cond)
df_EG_nat$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
df_EG_nat$score_normalised = (df$score) * 100
#-----------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------
#HERE ENG-FGer- mono native
langpair="Eng-Ger"
trGer_tsEng=paste(path, "ivector_128_tr-train_mono_ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trGer_tsGer=paste(path, "ivector_128_tr-train_mono_ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
trEng_tsEng=paste(path, "ivector_128_tr-train_mono_eng_gerspk_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trEng_tsGer=paste(path, "ivector_128_tr-train_mono_eng_gerspk_ts-test_German_lb_0.5h_10spk/", csv, sep="")
lang_A="English"
lang_B="German"
mono_same_df <- rbind(read.csv(trGer_tsGer, sep='\t'), read.csv(trEng_tsEng, sep='\t'))
mono_same_df$cond =rep("mono_same",nrow(mono_same_df))

mono_different_df<- rbind(read.csv(trGer_tsEng, sep='\t'), read.csv(trEng_tsGer, sep='\t'))
mono_different_df$cond =rep("mono_different",nrow(mono_same_df))


bil1_tsEng=paste(path, "ivector_128_tr-train_bil_1_eng-ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
bil2_tsEng=paste(path, "ivector_128_tr-train_bil_2_eng-ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
bil1_tsGer=paste(path, "ivector_128_tr-train_bil_1_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
bil2_tsGer=paste(path, "ivector_128_tr-train_bil_2_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
bil_df <- rbind(read.csv(bil1_tsEng, sep='\t'), read.csv(bil2_tsEng, sep='\t'),read.csv(bil1_tsGer, sep='\t'),read.csv(bil2_tsGer, sep='\t') )
bil_df$cond =rep("bil",nrow(bil_df))

mix1_tsEng=paste(path, "ivector_128_tr-train_mix_1_eng-ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
mix2_tsEng=paste(path, "ivector_128_tr-train_mix_2_eng-ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
mix1_tsGer=paste(path, "ivector_128_tr-train_mix_1_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
mix2_tsGer=paste(path, "ivector_128_tr-train_mix_2_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
mix_df <- rbind(read.csv(mix1_tsEng, sep='\t'), read.csv(mix2_tsEng, sep='\t'),read.csv(mix1_tsGer, sep='\t'),read.csv(mix2_tsGer, sep='\t') )
mix_df$cond =rep("mix",nrow(mix_df))

df_EG_acc = rbind(mono_same_df, mono_different_df, bil_df, mix_df)
df_EG_acc$cond = as_factor(df$cond)
df_EG_acc$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
df_EG_acc$score_normalised = (df$score) * 100

#-----------------------------------------------------------------------------------------------



# TODO SHOULD DO WEIGHTED PMEAN  ! ! !

# means <- data.table(df)[,list(score = weighted.mean(score,n)),by=cond]
# means$score_normalised = means$score*100
# 
# ggplot(df, aes(x =cond, y = score_normalised, fill=cond)) +
#   geom_boxplot(outlier.colour="black", outlier.shape=16,
#                outlier.size=2, notch=TRUE) +
#   geom_jitter(colour="grey", size=0.5, shape=4) +
#   ggtitle (paste("Speaker Discrimination scores \nfor language pair", langpair)) +
#   scale_fill_brewer(palette="Pastel1") +
#   geom_text(data = means, aes(label = paste("M =",round(score_normalised, 2)), y = score_normalised + 6), color="darkred", fontface = "bold")
# # If want gray colors :   scale_fill_grey(start=0.9, end=0.6) + theme_classic() +
# #stat_summary(fun=mean, geom="point", shape=20, size=6, color="darkred", fill="red") +


# ------------ HERE IS COOL ONE ----------------------------------
compare_means(score_normalised ~ cond, data = df, paired = FALSE, method = "t.test" )
my_comparisons <- list( c("mono_same", "mono_different"), c("mono_different", "bil"), c("mono_different", "mix") )

# my_comparisons <- list( c("mono_same", "mono_different"), c("mono_different", "bil"), c("mono_different", "mix"), c("mono_same", "mix") ,c("mono_same", "bil") )




#Create_4 graphs

bp_EF_nat <- ggboxplot(df_EF_nat, x = "cond", y = "score_normalised", notch=TRUE,
          color = "cond", line.color = "gray", line.size = 0.02,
          palette = "jco", legend="none",
          ylab="ABX score (in %)", xlab="")+
          stat_compare_means(paired = FALSE,  method = "wilcox.test", comparisons=my_comparisons, label =  "p.signif", label.x = 1.5, size=5)

bp_EF_acc <- ggboxplot(df_EF_acc, x = "cond", y = "score_normalised", notch=TRUE,
                       color = "cond", line.color = "gray", line.size = 0.02,
                       palette = "jco", legend="none",
                       ylab="ABX score (in %)", xlab="")+
  stat_compare_means(paired = FALSE,  method = "wilcox.test", comparisons=my_comparisons, label =  "p.signif", label.x = 1.5, size=5)

bp_EG_nat <- ggboxplot(df_EG_nat, x = "cond", y = "score_normalised", notch=TRUE,
                       color = "cond", line.color = "gray", line.size = 0.02,
                       palette = "jco", legend="none",
                       ylab="ABX score (in %)", xlab="")+
  stat_compare_means(paired = FALSE,  method = "wilcox.test", comparisons=my_comparisons, label =  "p.signif", label.x = 1.5, size=5)

bp_EG_acc <- ggboxplot(df_EG_acc, x = "cond", y = "score_normalised", notch=TRUE,
                       color = "cond", line.color = "gray", line.size = 0.02,
                       palette = "jco", legend="none",
                       ylab="ABX score (in %)", xlab="")+
  stat_compare_means(paired = FALSE,  method = "wilcox.test", comparisons=my_comparisons, label =  "p.signif", label.x = 1.5, size=5)


ggarrange(bp_EF_nat, bp_EG_nat, bp_EF_acc, bp_EG_acc + rremove("x.text"), 
          labels = c("English-Finnish (native Eng spk)","English-German (native Eng spk)", "English-Finnish (L2 Eng spk)",  "English-German (L2 Eng spk)"),
          ncol = 2, nrow = 2)

#To save pdf, do A3 size : 11.7 x 16.5 in in Landscape mode.

#================================================================================================================================
# #Tests of comparisons (unpaired)
# 
# # Retrieve only mix and bil
# condA="mono_different"
# condB="mono_same"
# d = rbind(df_EG_nat[df_EG_nat$cond == condA,], df_EG_nat[df_EG_nat$cond == condB,])
# #Should not do per id because not sameparticipants
# 
# #BELOW FOR UNPAIRED DATA
# res2 = oneway_test(score ~ cond , data=d,
#                    distribution=approximate(nresample=9999), weigts= n ~ cond)
# print(paste('The p.value for langpair', langpair, 'between conditions',condA,"and",condB,'for the two-way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling and weighted is',pvalue(res2)))
# 
# #BELOW FOR PAIRED DATA ONLY (So only SAME AND DIFF BASICALLY as same pp)
# d$id=as_factor(d$id)
# res = oneway_test(score ~ cond | id , data=d,
#                   distribution=approximate(nresample=9999))



#================================================================================================
#================================================================================================
#B. COMMON VOICE DATA. 
#================================================================================================
#================================================================================================

path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe_cv/"
path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe_cv_highdim/"

csv="data_on_spk_by_lang.csv"
ivec_dim=128
ivec_dim=2048


#-----------------------------------------------------------------------------------------------
#HERE ENG-FRENCH
lang_A="en"
lang_B="fr"
trA_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
trB_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trA_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trB_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_B,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")

mono_same_df <- rbind(read.csv(trA_tsA, sep='\t'), read.csv(trB_tsB, sep='\t'))
mono_same_df$cond =rep("mono_same",nrow(mono_same_df))

mono_different_df<- rbind(read.csv(trA_tsB, sep='\t'), read.csv(trB_tsA, sep='\t'))
mono_different_df$cond =rep("mono_different",nrow(mono_different_df))


mix1_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
mix2_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
mix1_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
mix2_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
mix_df <- rbind(read.csv(mix1_tsA, sep='\t'), read.csv(mix2_tsA, sep='\t'),read.csv(mix1_tsB, sep='\t'),read.csv(mix2_tsB, sep='\t') )
mix_df$cond =rep("mix",nrow(mix_df))


df_EF = rbind(mono_same_df, mono_different_df,  mix_df)
df_EF$cond = as_factor(df_EF$cond)
df_EF$id=apply(df_EF[,1:2],1,function(x){paste(x,collapse = "-")})
df_EF$score_normalised = 100-(df_EF$score) * 100
df_EF$id=as_factor(df_EF$id)


#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
#HERE ENG-FIN - mono native
lang_A="en"
lang_B="it"
trA_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
trB_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trA_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trB_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_B,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")

mono_same_df <- rbind(read.csv(trA_tsA, sep='\t'), read.csv(trB_tsB, sep='\t'))
mono_same_df$cond =rep("mono_same",nrow(mono_same_df))

mono_different_df<- rbind(read.csv(trA_tsB, sep='\t'), read.csv(trB_tsA, sep='\t'))
mono_different_df$cond =rep("mono_different",nrow(mono_different_df))


mix1_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
mix2_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
mix1_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
mix2_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
mix_df <- rbind(read.csv(mix1_tsA, sep='\t'), read.csv(mix2_tsA, sep='\t'),read.csv(mix1_tsB, sep='\t'),read.csv(mix2_tsB, sep='\t') )
mix_df$cond =rep("mix",nrow(mix_df))

df=merge(same_df, different_df, by=c("spk_1", "spk_2", "by", "n"), suffixes=c(".same",".different"))
df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
if (sum(same_df$n) != sum(different_df$n)) {
  stop("Same and different don't have the same total number of triplets. Different test sets?", call.=FALSE)
}
df_EI = rbind(mono_same_df, mono_different_df,  mix_df)
df_EI$cond = as_factor(df_EI$cond)
df_EI$id=apply(df_EI[,1:2],1,function(x){paste(x,collapse = "-")})
df_EI$score_normalised = 100-(df_EI$score) * 100
df_EI$id=as_factor(df_EI$id)

#-----------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------
#HERE ENG-FIN - mono native
lang_A="fr"
lang_B="it"
trA_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
trB_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trA_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trB_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_B,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")

mono_same_df <- rbind(read.csv(trA_tsA, sep='\t'), read.csv(trB_tsB, sep='\t'))
mono_same_df$cond =rep("mono_same",nrow(mono_same_df))

mono_different_df<- rbind(read.csv(trA_tsB, sep='\t'), read.csv(trB_tsA, sep='\t'))
mono_different_df$cond =rep("mono_different",nrow(mono_different_df))


mix1_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
mix2_tsA=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
mix1_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
mix2_tsB=paste(path, "ivector_",ivec_dim, "_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
mix_df <- rbind(read.csv(mix1_tsA, sep='\t'), read.csv(mix2_tsA, sep='\t'),read.csv(mix1_tsB, sep='\t'),read.csv(mix2_tsB, sep='\t') )
mix_df$cond =rep("mix",nrow(mix_df))
df_FI=merge(same_df, different_df, by=c("spk_1", "spk_2", "by", "n"), suffixes=c(".same",".different"))
df_FI$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
if (sum(same_df$n) != sum(different_df$n)) {
  stop("Same and different don't have the same total number of triplets. Different test sets?", call.=FALSE)
}

df=merge(same_df, different_df, by=c("spk_1", "spk_2", "by", "n"), suffixes=c(".same",".different"))
df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
if (sum(same_df$n) != sum(different_df$n)) {
  stop("Same and different don't have the same total number of triplets. Different test sets?", call.=FALSE)
}
df_FI = rbind(mono_same_df, mono_different_df,  mix_df)
df_FI$cond = as_factor(df_FI$cond)
df_FI$id=apply(df_FI[,1:2],1,function(x){paste(x,collapse = "-")})
df_FI$score_normalised = 100 - (df_FI$score) * 100
df_FI$id=as_factor(df_FI$id)

#-----------------------------------------------------------------------------------------------
my_comparisons <- list( c("mono_same", "mono_different"), c("mono_same", "mix"), c("mono_different", "mix") )
compare_means(score_normalised ~ cond, data = df_EI, paired = FALSE, method = "t.test" )
 
#

condA="mono_different"
condB="mono_same"
condC="mix"







get_stats <- function(df, condA="mono_different",condB="mono_same", condC="mix" ){
stat.test <- tibble::tribble(
   ~group1, ~group2,   ~p.value, ~p.sig,
   condA,     condB, round(get_pvalue(df, condA, condB)$score, 3),  get_pvalue(df, condA, condB)$sig, 
   condA,     condC, round(get_pvalue(df, condA, condC)$score, 3),  get_pvalue(df, condA, condC)$sig,  
   condB,     condC, round(get_pvalue(df, condB, condC)$score, 3),  get_pvalue(df, condB, condC)$sig, 
 )

stat.test.paired <- tibble::tribble(
  ~group1, ~group2,   ~p.value, ~p.sig,
  condA,     condB, round(get_pvalue(df, condA, condB, paired=TRUE)$score, 3),  get_pvalue(df, condA, condB, paired=TRUE)$sig, 
  condA,     condC, round(get_pvalue(df, condA, condC, paired=TRUE)$score, 3),  get_pvalue(df, condA, condC, paired=TRUE)$sig,  
  condB,     condC, round(get_pvalue(df, condB, condC, paired=TRUE)$score, 3),  get_pvalue(df, condB, condC, paired=TRUE)$sig, 
)
return(list("stat.test"=stat.test, "stat.test.paired" = stat.test.paired))
}


bp_FI <- ggboxplot(df_FI, x = "cond", y = "score_normalised", notch=FALSE,
          color = "cond", line.color = "gray", line.size = 0.02,
          palette = "jco", legend="none",
          ylab="ABX score (in %)", xlab="")+
  stat_pvalue_manual(get_stats(df_FI)$stat.test, 
    y.position = 35, step.increase = 0.1, label = "p.sig",size=5
  )

bp_EF<- ggboxplot(df_EF, x = "cond", y = "score_normalised", notch=FALSE,
                   color = "cond", line.color = "gray", line.size = 0.02,
                   palette = "jco", legend="none",
                   ylab="ABX score (in %)", xlab="")+
  stat_pvalue_manual(get_stats(df_EF)$stat.test, 
    y.position = 35, step.increase = 0.1, label = "p.sig",size=5
  )

bp_EI<- ggboxplot(df_EI, x = "cond", y = "score_normalised", notch=FALSE,
                  color = "cond", line.color = "gray", line.size = 0.02,
                  palette = "jco", legend="none",
                  ylab="ABX score (in %)", xlab="")+
  stat_pvalue_manual(get_stats(df_EI)$stat.test, 
                     y.position = 35, step.increase = 0.1, label = "p.sig",size=5
  )

bp_FI_paired <- ggboxplot(df_FI, x = "cond", y = "score_normalised", notch=FALSE,
                   color = "cond", line.color = "gray", line.size = 0.02,
                   palette = "jco", legend="none",
                   ylab="ABX score (in %)", xlab="")+
  stat_pvalue_manual(get_stats(df_FI)$stat.test.paired, 
                     y.position = 35, step.increase = 0.1, label = "p.sig",size=5
  )

bp_EF_paired<- ggboxplot(df_EF, x = "cond", y = "score_normalised", notch=FALSE,
                  color = "cond", line.color = "gray", line.size = 0.02,
                  palette = "jco", legend="none",
                  ylab="ABX score (in %)", xlab="")+
  stat_pvalue_manual(get_stats(df_EF)$stat.test.paired, 
                     y.position = 35, step.increase = 0.1, label = "p.sig" ,size=5
  )

bp_EI_paired<- ggboxplot(df_EI, x = "cond", y = "score_normalised", notch=FALSE,
                  color = "cond", line.color = "gray", line.size = 0.02,
                  palette = "jco", legend="none",
                  ylab="ABX score (in %)", xlab="")+
  stat_pvalue_manual(get_stats(df_EI)$stat.test.paired, 
                     y.position = 35, step.increase = 0.1, label = "p.sig", size=5
  )



ggarrange(bp_EF, bp_EI, bp_FI, bp_EF_paired, bp_EI_paired, bp_FI_paired , 
          labels = c("English-French","English-Italian", "French-Italian", "English-French (paired test)","English-Italian (paired test)", "French-Italian (paired test)"),
          ncol = 3, nrow = 2)

#save as 16x20



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


df_filtered = df[df$cond != 'mix familiar',]
ggboxplot(df_filtered, x = "cond", y = "score_normalised", notch=FALSE,
          color = "cond", line.color = "gray", line.size = 0.02,
          palette = "jco", legend="none",
          ylab="ABX score (in %)", xlab="")+
  stat_compare_means(paired = FALSE, comparisons=my_comparisons, label =  "p.signif", label.x = 1.5, size=5) +
  ggtitle ("Speaker Discrimination scores on different averaged conditions", subtitle="EN, FR and IT (and all mix combinations)") 
  

ggbarplot(df_filtered, x = "cond", y = "score_normalised", merge=TRUE,
          color = "cond", line.color = "gray", line.size = 0.02,
          palette = "jco", legend="none",
          ylab="ABX score (in %)", xlab="")+
  stat_compare_means(paired = FALSE, comparisons=my_comparisons, label =  "p.signif", label.x = 1.5, size=5)



my_comparisons <- list( c("mono_same", "mono_different"), c("mono_same", "mix"), c("mono_different", "mix") )
compare_means(score_normalised ~ cond, data = df_filtered, paired = FALSE, method = "t.test" )
