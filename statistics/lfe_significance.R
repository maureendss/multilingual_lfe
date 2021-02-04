#!/usr/bin/env Rscript

library(ggplot2)
library(distributions3)



library(ggpubr)
library(rstatix)

library(BSDA)

#do on all possible speaker pair. 
args = commandArgs(trailingOnly=TRUE)

if (length(args)!=2) {
  stop("Two arguments must be supplied, the same CSV and the different CSV", call.=FALSE)
} 

lang_A=args[1]
lang_B=args[2]


#lang_A="French"
#lang_B="Chinese"

same_a=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_A,"_10h_10spk_ts-test_",lang_A,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
same_b=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_B,"_10h_10spk_ts-test_",lang_B,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
diff_a=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_A,"_10h_10spk_ts-test_",lang_B,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
diff_b=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_B,"_10h_10spk_ts-test_",lang_A,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")

same_csv <- rbind(read.csv(same_a, sep='\t'), read.csv(same_b, sep='\t'))
different_csv<- rbind(read.csv(diff_a, sep='\t'), read.csv(diff_b, sep='\t'))

#Here we create a speaker id based on the two speakers.
same_csv$id=apply(same_csv[,1:2],1,function(x){paste(sort(x),collapse = ",")})
same_df=aggregate(same_csv$score, by=list(ID=same_csv$id,Lang=same_csv$by, N=same_csv$n), FUN=mean)

different_csv$id=apply(different_csv[,1:2],1,function(x){paste(sort(x),collapse = ",")})
different_df=aggregate(different_csv$score, by=list(ID=different_csv$id,Lang=different_csv$by, N=different_csv$n), FUN=mean)

#Check all same numbers
#if (var(same_csv[,'n']) != 0) {
#  stop("Not same N", call.=FALSE)
#}
#if (var(different_csv[,'n']) != 0) {
#  stop("Not same N", call.=FALSE)
#}

#NOT SAME N 

#same=same_df[,'x']
#different=different_df[,'x']
#qqnorm(same)
#qqline(same)
#qqnorm(different)
#qqline(different)
#NOT GAUSSIAN

df=merge(same_df, different_df, by=c("ID", "Lang", "N"), suffixes=c(".same",".different"))





#Z TEST
#--------------------------------------------
zresult=z.test(df$x.same, df$x.different,sigma.x=sd(df$x.same), sigma.y=sd(df$x.different))
print(paste('The p.value for the z-test is',zresult$p.value))


#--------------------------------------------

#pairwise paired t test
x=c(df$x.same, df$x.different)
y=c(replicate(length(df$x.same), 'same'), replicate(length(df$x.different), 'different'))


# ggplot(df, aes(x =y, y = x, color = condition)) +
#   geom_boxplot() +
#   geom_jitter() +
#   scale_color_brewer(type = "qual", palette = 2) +
#   theme_minimal() +
#   theme(legend.position = "none")




pwc = pairwise.t.test(
  x,y, paired=TRUE,
  p.adjust.method = "bonferroni")

print(paste('The p.value for the pairwise paired t-test is',pwc$p.value))

#--------------------------------------------

#paired t-test
ttestresult=t.test(df$x.same, df$x.different, paired = TRUE, alternative = "two.sided")
# THis is the one that makes most sense? Same as pairwise?
print(paste('The p.value for the paired t-test is',ttestresult$p.value))

#--------------------------------------------

#Create paired boxplot
ggpaired(df, cond1="x.same", cond2= "x.different",
         ylab = "ABX score (in %)", xlab = "Condition", line.size=0.05)

diff=100-mean(df$x.diff)*100
same=100-mean(df$x.same)*100
lfe=(diff-same)/same*100
  
print(paste("Mean for same is",round(same,3), "Mean for different is", round(diff,3)))
print(paste("LFE is", lfe))
