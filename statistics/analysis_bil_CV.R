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


path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe_cv/"
csv="data_on_spk_by_lang.csv"

#===================================================================================================
# First Look at LFE for MONO
# Only reporting data without monolingual. 



#-----------------------------------------------------------------------------------------------
#H
lang_A="en"
lang_B="fr"
langpair=paste(lang_A,"+",lang_B)
trA_tsA=paste(path, "ivector_128_tr-",lang_A,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
trB_tsB=paste(path, "ivector_128_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trA_tsB=paste(path, "ivector_128_tr-",lang_A,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trB_tsA=paste(path, "ivector_128_tr-",lang_B,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")

same_df <- rbind(read.csv(trA_tsA, sep='\t'), read.csv(trB_tsB, sep='\t'))
different_df<- rbind(read.csv(trA_tsB, sep='\t'), read.csv(trB_tsA, sep='\t'))
#mix_df <- rbind(read.csv(mix1_tsA, sep='\t'), read.csv(mix2_tsA, sep='\t'),read.csv(mix1_tsB, sep='\t'),read.csv(mix2_tsB, sep='\t') )

#-----------------------------------------------------------------------------------------------


df=merge(same_df, different_df, by=c("spk_1", "spk_2", "by", "n"), suffixes=c(".same",".different"))
df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
if (sum(same_df$n) != sum(different_df$n)) {
  stop("Same and different don't have the same total number of triplets. Different test sets?", call.=FALSE)
}
d2 <- reshape2::melt(df, id.vars=c("id", "n"),measure.vars = c("score.same","score.different"))
d2$variable = as_factor(d2$variable)
d2$id = as_factor(d2$id)
d2$value_normalised = 100- ( d2$value) * 100





res=oneway_test(value ~ variable | id,
                data = d2, distribution="approximate"(nresample=9999))
print(paste('The p.value for langpair', langpair, ' for the Two-Way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling is',pvalue(res)))
res=oneway_test(value ~ variable | id,
                data = d2,  distribution="approximate"(nresample=99), weights=~n)
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
  geom_jitter(colour="grey", size=0.5, shape=4) +
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
trA_tsA=paste(path, "ivector_128_tr-",lang_A,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
trB_tsB=paste(path, "ivector_128_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trA_tsB=paste(path, "ivector_128_tr-",lang_A,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
trB_tsA=paste(path, "ivector_128_tr-",lang_B,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")

mono_same_df <- rbind(read.csv(trA_tsA, sep='\t'), read.csv(trB_tsB, sep='\t'))
mono_same_df$cond =rep("mono_same",nrow(mono_same_df))

mono_different_df<- rbind(read.csv(trA_tsB, sep='\t'), read.csv(trB_tsA, sep='\t'))
mono_different_df$cond =rep("mono_different",nrow(mono_different_df))


mix1_tsA=paste(path, "ivector_128_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
mix2_tsA=paste(path, "ivector_128_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
mix1_tsB=paste(path, "ivector_128_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
mix2_tsB=paste(path, "ivector_128_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
mix_df <- rbind(read.csv(mix1_tsA, sep='\t'), read.csv(mix2_tsA, sep='\t'),read.csv(mix1_tsB, sep='\t'),read.csv(mix2_tsB, sep='\t') )
mix_df$cond =rep("mix",nrow(mix_df))

#-----------------------------------------------------------------------------------------------


df = rbind(mono_same_df, mono_different_df,  mix_df)
df$cond = as_factor(df$cond)
df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})
df$score_normalised = (df$score) * 100


# TODO SHOULD DO WEIGHTED PMEAN  ! ! !

means <- data.table(df)[,list(score = weighted.mean(score,n)),by=cond]
means$score_normalised = means$score*100

ggplot(df, aes(x =cond, y = score_normalised, fill=cond)) +
  geom_boxplot(outlier.colour="black", outlier.shape=16,
               outlier.size=2, notch=TRUE) +
  ggtitle (paste("Speaker Discrimination scores \nfor language pair", langpair)) +
  scale_fill_brewer(palette="Pastel1") +
  geom_text(data = means, aes(label = paste("M =",round(score_normalised, 2)), y = score_normalised + 6), color="darkred", fontface = "bold")
# If want gray colors :   scale_fill_grey(start=0.9, end=0.6) + theme_classic() +
  #stat_summary(fun=mean, geom="point", shape=20, size=6, color="darkred", fill="red") +
    

#================================================================================================================================
#Tests of comparisons (unpaired)

# Retrieve only mix and bil

condA="mix"
condB="mono_same"
d = rbind(df[df$cond == condA,], df[df$cond == condB,])
 #Should not do per id because not sameparticipants



#BELOW FOR UNPAIRED DATA
res2 = oneway_test(score ~ cond , data=d,
                   distribution=approximate(nresample=9999), weigts= n ~ cond)
print(paste('The p.value for langpair', langpair, 'between conditions',condA,"and",condB,'for the UNPAIRED two-way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling and weighted is',pvalue(res2)))



#BELOW FOR PAIRED DATA ONLY (So only SAME AND DIFF BASICALLY as same pp)
d$id=as_factor(d$id)
res = oneway_test(score ~ cond | id , data=d,
                  distribution=approximate(nresample=9999))

#TODO : ADD WEIGTHS
print(paste('The p.value for langpair', langpair, 'between conditions',condA,"and",condB,'for the PAIRED two-way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling  is',pvalue(res)))

#BELOW FOR PAIRED DATA ONLY (So only SAME AND DIFF BASICALLY as same pp)
d$id=as_factor(d$id)
res3 = oneway_test(score ~ cond | id , data=d,
                  distribution=approximate(nresample=99), weights= ~ n)

print(paste('The p.value for langpair', langpair, 'between conditions',condA,"and",condB,'for the PAIRED two-way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling and WEIGHTEDis',pvalue(res3)))

#------------------- TRIAL --------------------------------------------
#All test finnish

#--------------------------
lang_C="it"

mono_same_df <- rbind(read.csv(paste(path, "ivector_128_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'))
mono_diff_df <- rbind(read.csv(paste(path, "ivector_128_tr-",lang_C,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'))

paste(path, "ivector_128_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
bil_same_df <- rbind(read.csv(paste(path, "ivector_128_tr-",lang_A,"+",lang_B,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_128_tr-",lang_A,"+",lang_B,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'))
bil_diff_df <- rbind(read.csv(paste(path, "ivector_128_tr-",lang_A,"+",lang_C,"_A_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'), read.csv(paste(path, "ivector_128_tr-",lang_A,"+",lang_C,"_B_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep=""), sep='\t'))

mono_same_df$cond =rep(lang_B,nrow(mono_same_df))
mono_diff_df$cond =rep(lang_C,nrow(mono_diff_df))
bil_same_df$cond =rep(paste(lang_A,"+",lang_B," - mix", sep=""),nrow(bil_same_df))
bil_diff_df$cond =rep(paste(lang_A,"+",lang_C," - mix", sep=""),nrow(bil_same_df))
#----------


df = rbind(mono_same_df, mono_diff_df, bil_same_df, bil_diff_df)
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
  ggtitle (paste("Speaker Discrimination scores on test set ", lang_C)) +
  scale_fill_brewer(palette="Pastel1") +
  geom_text(data = means, aes(label = paste("M =",round(score_normalised, 2)), y = score_normalised + 6), color="darkred", fontface = "bold")
# If want gray colors :   scale_fill_grey(start=0.9, end=0.6) + theme_classic() +
#stat_summary(fun=mean, geom="point", shape=20, size=6, color="darkred", fill="red") +

