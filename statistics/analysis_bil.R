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


path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe_bil/"
csv="data_on_spk_by_lang.csv"

#===================================================================================================
# First Look at LFE for MONO
# Only reporting data without monolingual. 



#-----------------------------------------------------------------------------------------------
#HERE ENG-FIN - mono non native
langpair="Eng-Fin"
trFin_tsEng=paste(path, "ivector_128_tr-train_mono_fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trFin_tsFin=paste(path, "ivector_128_tr-train_mono_fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
trEng_tsEng=paste(path, "ivector_128_tr-train_mono_eng_finspk_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trEng_tsFin=paste(path, "ivector_128_tr-train_mono_eng_finspk_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
lang_A="English"
lang_B="Finnish"
same_df <- rbind(read.csv(trFin_tsFin, sep='\t'), read.csv(trEng_tsEng, sep='\t'))
different_df<- rbind(read.csv(trFin_tsEng, sep='\t'), read.csv(trEng_tsFin, sep='\t'))
#-----------------------------------------------------------------------------------------------



#-----------------------------------------------------------------------------------------------
#HERE ENG-FIN - mono native
langpair="Eng-Fin"
trFin_tsEng=paste(path, "ivector_128_tr-train_mono_fin_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trFin_tsFin=paste(path, "ivector_128_tr-train_mono_fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
trEng_tsEng=paste(path, "ivector_128_tr-train_mono_eng_native_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trEng_tsFin=paste(path, "ivector_128_tr-train_mono_eng_native_ts-test_Finnish_lb_0.5h_10spk/", csv, sep="")
lang_A="English"
lang_B="Finnish"
same_df <- rbind(read.csv(trFin_tsFin, sep='\t'), read.csv(trEng_tsEng, sep='\t'))
different_df<- rbind(read.csv(trFin_tsEng, sep='\t'), read.csv(trEng_tsFin, sep='\t'))
#-----------------------------------------------------------------------------------------------


#HERE ENG-GER
#-----------------------------------------------------------------------------------------------
langpair="Eng-Ger"
trGer_tsEng=paste(path, "ivector_128_tr-train_mono_ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trGer_tsGer=paste(path, "ivector_128_tr-train_mono_ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
trEng_tsEng=paste(path, "ivector_128_tr-train_mono_eng_gerspk_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trEng_tsGer=paste(path, "ivector_128_tr-train_mono_eng_gerspk_ts-test_German_lb_0.5h_10spk/", csv, sep="")
lang_A="English"
lang_B="German"
same_df <- rbind(read.csv(trGer_tsGer, sep='\t'), read.csv(trEng_tsEng, sep='\t'))
different_df<- rbind(read.csv(trGer_tsEng, sep='\t'), read.csv(trEng_tsGer, sep='\t'))
#-----------------------------------------------------------------------------------------------


#HERE ENG-GER NATIVE 
#-----------------------------------------------------------------------------------------------
langpair="Eng-Ger"
trGer_tsEng=paste(path, "ivector_128_tr-train_mono_ger_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trGer_tsGer=paste(path, "ivector_128_tr-train_mono_ger_ts-test_German_lb_0.5h_10spk/", csv, sep="")
trEng_tsEng=paste(path, "ivector_128_tr-train_mono_eng_native_ts-test_English_lb_0.5h_10spk/", csv, sep="")
trEng_tsGer=paste(path, "ivector_128_tr-train_mono_eng_native_ts-test_German_lb_0.5h_10spk/", csv, sep="")
lang_A="English"
lang_B="German"
same_df <- rbind(read.csv(trGer_tsGer, sep='\t'), read.csv(trEng_tsEng, sep='\t'))
different_df<- rbind(read.csv(trGer_tsEng, sep='\t'), read.csv(trEng_tsGer, sep='\t'))
#-----------------------------------------------------------------------------------------------


df=merge(same_df, different_df, by=c("spk_1", "spk_2", "by", "n"), suffixes=c(".same",".different"))
df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
if (sum(same_df$n) != sum(different_df$n)) {
  stop("Same and different don't have the same total number of triplets. Different test sets?", call.=FALSE)
}
d2 <- reshape2::melt(df, id.vars=c("id", "n"),measure.vars = c("score.same","score.different"))
d2$variable = as_factor(d2$variable)
d2$id = as_factor(d2$id)
d2$value_normalised = ( d2$value) * 100





res=oneway_test(value ~ variable | id,
                data = d2, distribution="approximate"(nresample=9999))
print(paste('The p.value for langpair', langpair, ' for the Two-Way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling is',pvalue(res)))
res=oneway_test(value ~ variable | id,
                data = d2,  distribution="approximate"(nresample=9999), weigts= n ~ cond)
print(paste('The p.value for langpair', langpair, ' for the two-way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling and weighted is',pvalue(res)))

diff=mean(c(100-weighted.mean(df[df$by==lang_A,"score.different"],df[df$by==lang_A,"n"])*100, 100-weighted.mean(df[df$by==lang_B,"score.different"],df[df$by==lang_B,"n"])*100))
same=mean(c(100-weighted.mean(df[df$by==lang_A,"score.same"],df[df$by==lang_A,"n"])*100, 100-weighted.mean(df[df$by==lang_B,"score.same"],df[df$by==lang_B,"n"])*100))


lfe=(diff-same)/same*100
print(paste("Mean for same is",round(same,3), "Mean for different is", round(diff,3), "LFE is", round(lfe, 3)))



means <- aggregate(value ~ variable, d2, mean)
#weighted below
means <- data.table(d2)[,list(value = weighted.mean(value_normalised,n)),by=variable]


ggplot(d2, aes(x =variable, y = value_normalised, fill=variable)) +
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=FALSE) +
  geom_jitter(colour="black", size=0.5, shape=4) +
  ggtitle (paste("Speaker Discrimination score in function of the same vs different condition \nfor language pair", langpair)) +
  scale_fill_brewer(palette="Pastel1") +
 geom_text(data = means, aes(label = round(value, 2), y = value - 2), color="red", fontface = "bold")
# If want gray colors :   scale_fill_grey(start=0.9, end=0.6) + theme_classic() +

#stat_summary(fun=mean, geom="point", shape=20, size=6, color="darkred", fill="red") +
  


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

#-----------------------------------------------------------------------------------------------



df = rbind(mono_same_df, mono_different_df, bil_df, mix_df)
df$cond = as_factor(df$cond)
df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
df$score_normalised = (df$score) * 100


# TODO SHOULD DO WEIGHTED PMEAN  ! ! !

means <- data.table(df)[,list(score = weighted.mean(score,n)),by=cond]
means$score_normalised = means$score*100

ggplot(df, aes(x =cond, y = score_normalised, fill=cond)) +
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=TRUE) +
  geom_jitter(colour="grey", size=0.5, shape=4) +
  ggtitle (paste("Speaker Discrimination scores \nfor language pair", langpair)) +
  scale_fill_brewer(palette="Pastel1") +
  geom_text(data = means, aes(label = paste("M =",round(score_normalised, 2)), y = score_normalised + 6), color="darkred", fontface = "bold")
# If want gray colors :   scale_fill_grey(start=0.9, end=0.6) + theme_classic() +
  #stat_summary(fun=mean, geom="point", shape=20, size=6, color="darkred", fill="red") +
    

#================================================================================================================================
#Tests of comparisons (unpaired)

# Retrieve only mix and bil

condA="bil"
condB="mono_same"
d = rbind(df[df$cond == condA,], df[df$cond == condB,])
 #Should not do per id because not sameparticipants



#BELOW FOR UNPAIRED DATA
res2 = oneway_test(score ~ cond , data=d,
                   distribution=approximate(nresample=9999), weigts= n ~ cond)
print(paste('The p.value for langpair', langpair, 'between conditions',condA,"and",condB,'for the two-way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling and weighted is',pvalue(res2)))



#BELOW FOR PAIRED DATA ONLY (So only SAME AND DIFF BASICALLY as same pp)
d$id=as_factor(d$id)
res = oneway_test(score ~ cond | id , data=d,
                  distribution=approximate(nresample=9999))

#TODO : ADD WEIGTHS
print(paste('The p.value for langpair', langpair, 'between conditions',condA,"and",condB,'for the two-way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling and weighted is',pvalue(res)))



#------------------- TRIAL --------------------------------------------
#All test finnish

#--------------------------
test="Finnish"
mono_same_df <- rbind(read.csv(paste(path, "ivector_128_tr-train_mono_fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep=""), sep='\t'))
mono_diff_df <- rbind(read.csv(paste(path, "ivector_128_tr-train_mono_ger_ts-test_Finnish_lb_0.5h_10spk/", csv, sep=""), sep='\t'))

bil_same_df <- rbind(read.csv(paste(path, "ivector_128_tr-train_bil_1_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_128_tr-train_bil_2_eng-fin_ts-test_Finnish_lb_0.5h_10spk/", csv, sep=""), sep='\t'))
bil_diff_df <- rbind(read.csv(paste(path, "ivector_128_tr-train_bil_1_eng-ger_ts-test_Finnish_lb_0.5h_10spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_128_tr-train_bil_2_eng-ger_ts-test_Finnish_lb_0.5h_10spk/", csv, sep=""), sep='\t'))

mono_same_df$cond =rep("Finnish",nrow(mono_same_df))
mono_diff_df$cond =rep("German",nrow(mono_diff_df))
bil_same_df$cond =rep("English-Finnish (bil)",nrow(bil_same_df))
bil_diff_df$cond =rep("English-German (bil)",nrow(bil_diff_df))
#--------------------------
#--------------------------
test="German"
mono_same_df <- rbind(read.csv(paste(path, "ivector_128_tr-train_mono_ger_ts-test_German_lb_0.5h_10spk/", csv, sep=""), sep='\t'))
mono_diff_df <- rbind(read.csv(paste(path, "ivector_128_tr-train_mono_fin_ts-test_German_lb_0.5h_10spk/", csv, sep=""), sep='\t'))

bil_same_df <- rbind(read.csv(paste(path, "ivector_128_tr-train_bil_1_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_128_tr-train_bil_2_eng-ger_ts-test_German_lb_0.5h_10spk/", csv, sep=""), sep='\t'))
bil_diff_df <- rbind(read.csv(paste(path, "ivector_128_tr-train_bil_1_eng-fin_ts-test_German_lb_0.5h_10spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_128_tr-train_bil_2_eng-fin_ts-test_German_lb_0.5h_10spk/", csv, sep=""), sep='\t'))

mono_same_df$cond =rep("German",nrow(mono_same_df))
mono_diff_df$cond =rep("Finnish",nrow(mono_diff_df))
bil_same_df$cond =rep("English-German (bil)",nrow(bil_same_df))
bil_diff_df$cond =rep("English-Finnish (bil)",nrow(bil_diff_df))
#--------------------------




df = rbind(mono_same_df, mono_diff_df, bil_same_df, bil_diff_df)
df$cond = as_factor(df$cond)
df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
df$score_normalised = (df$score) * 100


# TODO SHOULD DO WEIGHTED PMEAN  ! ! !

means <- data.table(df)[,list(score = weighted.mean(score,n)),by=cond]
means$score_normalised = means$score*100

ggplot(df, aes(x =cond, y = score_normalised, fill=cond)) +
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=FALSE) +
  geom_jitter(colour="grey", size=0.5, shape=4) +
  ggtitle (paste("Speaker Discrimination scores on test set ", test)) +
  scale_fill_brewer(palette="Pastel1") +
  geom_text(data = means, aes(label = paste("M =",round(score_normalised, 2)), y = score_normalised + 6), color="darkred", fontface = "bold")
# If want gray colors :   scale_fill_grey(start=0.9, end=0.6) + theme_classic() +
#stat_summary(fun=mean, geom="point", shape=20, size=6, color="darkred", fill="red") +

