#!/usr/bin/env Rscript
shhh <- suppressPackageStartupMessages # It's a library, so shhh!


shhh(library(ggplot2))
shhh(library(distributions3))


shhh(library(dplyr))

shhh(library(ggpubr))
shhh(library(rstatix))

shhh(library(BSDA))
shhh(library(coin))
library(reshape2)
library(forcats)


#do on all possible speaker pair. 
args = commandArgs(trailingOnly=TRUE)

if (length(args)!=2) {
  stop("Two arguments must be supplied, the same CSV and the different CSV", call.=FALSE)
} 

lang_A=args[1]
lang_B=args[2]
print(args)

#lang_A="French"
#lang_B="Finnish"

path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/"
numgauss=128

#path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe_highdim/"
#numgauss=2048


same_a=paste(path, "ivector_", numgauss,"_tr-train_",lang_A,"_10h_10spk_ts-test_",lang_A,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
same_b=paste(path, "ivector_", numgauss,"_tr-train_",lang_B,"_10h_10spk_ts-test_",lang_B,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
diff_a=paste(path, "ivector_", numgauss,"_tr-train_",lang_A,"_10h_10spk_ts-test_",lang_B,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
diff_b=paste(path, "ivector_", numgauss,"_tr-train_",lang_B,"_10h_10spk_ts-test_",lang_A,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")

same_csv <- rbind(read.csv(same_a, sep='\t'), read.csv(same_b, sep='\t'))
different_csv<- rbind(read.csv(diff_a, sep='\t'), read.csv(diff_b, sep='\t'))


#---------------------------------------------------------------------------

same_df=same_csv
different_df=different_csv


df=merge(same_df, different_df, by=c("spk_1", "spk_2", "by", "n"), suffixes=c(".same",".different"))
df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})

#---------------------------------------------------------------------------
#If we want to have speaker pair rather than asymmetric. But shouldn't do it to get same scores as in aBX.
# same_csv$id=apply(same_csv[,1:2],1,function(x){paste(sort(x),collapse = ",")})
# same_df = same_csv %>% group_by(id,by)%>% summarize(across(n,sum),across(score,mean))
# 
# 
# different_csv$id=apply(different_csv[,1:2],1,function(x){paste(sort(x),collapse = ",")})
# different_df = different_csv %>% group_by(id,by)%>% summarize(across(n,sum),across(score,mean))

# Below if have done merge.
# df=merge(same_df, different_df, by=c("id", "by", "n"), suffixes=c(".same",".different"))
#---------------------------------------------------------------------------


if (sum(same_df$n) != sum(different_df$n)) {
  stop("Same and different don't have the same total number of triplets. Different test sets?", call.=FALSE)
}



#Z TEST
#--------------------------------------------
#zresult=z.test(df$x.same, df$x.different,sigma.x=sd(df$x.same), sigma.y=sd(df$x.different))
zresult=z.test(df$score.same, df$score.different,sigma.x=sd(df$score.same), sigma.y=sd(df$score.different))

print(paste('The p.value for the z-test is',zresult$p.value))


#--------------------------------------------

#paired t-test
ttestresult=t.test(df$score.same, df$score.different, paired = TRUE, alternative = "two.sided")

# THis is the one that makes most sense? Same as pairwise?
print(paste('The p.value for the two-tailed paired t-test is',ttestresult$p.value))

ttestresult_onetailed=t.test(df$score.same, df$score.different, paired = TRUE, alternative = "greater")
print(paste('The p.value for the one-tailed paired t-test is',ttestresult_onetailed$p.value))


# PERMUTATION TEST : Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling

d2 <- reshape2::melt(df, id.vars=c("id", "n"),measure.vars = c("score.same","score.different"))
d2$variable = as_factor(d2$variable)
d2$id = as_factor(d2$id)


res=oneway_test(value ~ variable | id,
                data = d2, alternative="two.sided", distribution="approximate"(nresample=9999))
print(paste('The p.value for the two tailed one-way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling is',pvalue(res)))

res=oneway_test(value ~ variable | id,
                data = d2, alternative="two.sided", distribution="approximate"(nresample=9999))
print(paste('The p.value for the two tailed  one-way Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling and weighted is',pvalue(res)))


#If want asymptotic : 
res=oneway_test(value ~ variable | id,
                data = d2, alternative="two.sided")

#Can weigh per weight

#--------------------------------------------

#Create paired boxplot
ggpaired(df, cond1="score.same", cond2= "score.different",
         ylab = "ABX score (in %)", xlab = "Condition", line.size=0.05)


#On ne fait quer pondéré par langue 
diff=100-mean(df$score.different)*100
same=100-mean(df$score.same)*100
lfe=(diff-same)/same*100

diff=mean(c(100-mean(df[df$by==lang_A,"score.different"])*100, 100-mean(df[df$by==lang_B,"score.different"])*100))
same=mean(c(100-mean(df[df$by==lang_A,"score.same"])*100, 100-mean(df[df$by==lang_B,"score.same"])*100))


diff=mean(c(100-weighted.mean(df[df$by==lang_A,"score.different"],df[df$by==lang_A,"n"])*100, 100-weighted.mean(df[df$by==lang_B,"score.different"],df[df$by==lang_B,"n"])*100))
same=mean(c(100-weighted.mean(df[df$by==lang_A,"score.same"],df[df$by==lang_A,"n"])*100, 100-weighted.mean(df[df$by==lang_B,"score.same"],df[df$by==lang_B,"n"])*100))


lfe=(diff-same)/same*100

print(paste("Mean for same is",round(same,3), "Mean for different is", round(diff,3)))
print(paste("LFE is", lfe))


