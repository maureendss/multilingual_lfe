library(ggplot2)
library(distributions3)

library(tidyverse)
library(ggpubr)
library(rstatix)

library(data.table)

lfe_detailed <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_detailed.csv")
lfe_all <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_all.csv")
#In this file, we do overall per langpair. Eg we compare multiple lang pairs. We don't care about Ns. '

same=lfe_all[,'same']
different=lfe_all[,'different']

#Frol https://cran.r-project.org/web/packages/distributions3/vignettes/two-sample-z-test.html
qqnorm(same)
qqline(same)

test_results <- data.frame(
  score = c(same, different),
  condition = c(
    rep("same", length(same)),
    rep("different", length(different))
  )
)

# ggplot(test_results, aes(x = factor(condition, level=c('same','different')), y = score, color = condition)) +
#   geom_boxplot() +
#   geom_jitter() +
#   stat_summary(fun.y="mean", color='black') +
#   stat_summary(fun.y=mean, colour="red", geom="text", 
#                  vjust=-0.7, aes( label=round(..y.., digits=1)))
#   scale_color_brewer(type = "qual", palette = 2) +
#   theme_minimal() +
#   theme(legend.position = "none")

  ggplot(test_results, aes(x = factor(condition, level=c('same','different')), y = score, color = condition)) +
    geom_boxplot() +
    geom_jitter() +
    stat_summary(fun.y="mean", color='black') +
  scale_color_brewer(type = "qual", palette = 2) +
    theme_minimal() +
    theme(legend.position = "none")


  
df=data.frame(same,different)
ggpaired(df, cond1="same", cond2= "different",
         ylab = "ABX score (in %)", xlab = "Condition", line.size=0.05)


#do on all possible speaker pair. 
args = commandArgs(trailingOnly=TRUE)

if (length(args)<22) {
  stop("At least two languages must be supplied to create all possible combinations", call.=FALSE)
} 
args=list("French","English","German","Chinese","Dutch","Finnish","Italian")


langpairs=combn(args,2,simplify=FALSE)

df <- data.frame(spk1=character(),
                      spk2=character(), 
                      by=character(), 
                      n=integer(),
                      score.same=double(),
                      score.different=double(),
                      stringsAsFactors=FALSE) 

for (x in langpairs){
  lang_A=x[1]
  lang_B=x[2]
  print(x[[1]][1])
  
    
  same_a=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_A,"_10h_10spk_ts-test_",lang_A,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
  same_b=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_B,"_10h_10spk_ts-test_",lang_B,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
  diff_a=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_A,"_10h_10spk_ts-test_",lang_B,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
  diff_b=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_B,"_10h_10spk_ts-test_",lang_A,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
  
  same_df <- rbind(read.csv(same_a, sep='\t'), read.csv(same_b, sep='\t'))
  different_df <- rbind(read.csv(diff_a, sep='\t'), read.csv(diff_b, sep='\t'))
  df_tmp=merge(same_df, different_df, by=c("spk_1", "spk_2", "by", "n"), suffixes=c(".same",".different"))
  
  df=rbind(df,df_tmp)
  # if(!(lang_A  %in% langs_done)){
  #   ...
  # }
  # langs_done=append(langs_done, lang_A)
  # langs_done=append(langs_done, lang_B)
}

df$id=apply(df[,1:2],1,function(x){paste(x,collapse = "-")})




if (sum(same_df$n) != sum(different_df$n)) {
  stop("Same and different don't have the same total number of triplets. Different test sets?", call.=FALSE)
}



#Z TEST
#--------------------------------------------
#zresult=z.test(df$x.same, df$x.different,sigma.x=sd(df$x.same), sigma.y=sd(df$x.different))
zresult=z.test(df$score.same, df$score.different,sigma.x=sd(df$score.same), sigma.y=sd(df$score.different))

print(paste('The p.value for the z-test is',zresult$p.value))


#--------------------------------------------

#pairwise paired t test
x=c(df$score.same, df$score.different)
y=c(replicate(length(df$score.same), 'same'), replicate(length(df$score.different), 'different'))


# ggplot(df, aes(x =y, y = x, color = condition)) +
#   geom_boxplot() +
#   geom_jitter() +
#   scale_color_brewer(type = "qual", palette = 2) +
#   theme_minimal() +
#   theme(legend.position = "none")
# 



pwc = pairwise.t.test(
  x,y, paired=TRUE,
  p.adjust.method = "bonferroni", alternative="greater")

print(paste('The p.value for the one-tailed pairwise paired t-test is',pwc$p.value))

#--------------------------------------------

#paired t-test
ttestresult=t.test(df$score.same, df$score.different, paired = TRUE, alternative = "two.sided")

# THis is the one that makes most sense? Same as pairwise?
print(paste('The p.value for the two-tailed paired t-test is',ttestresult$p.value))

ttestresult_onetailed=t.test(df$score.same, df$score.different, paired = TRUE, alternative = "greater")
print(paste('The p.value for the one-tailed paired t-test is',ttestresult_onetailed$p.value))

#--------------------------------------------

#Create paired boxplot
ggpaired(df, cond1="score.same", cond2= "score.different",
         ylab = "ABX score (in %)", xlab = "Condition", line.size=0.05)

