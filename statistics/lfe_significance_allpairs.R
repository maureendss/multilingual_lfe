library(ggplot2)
library(distributions3)

library(tidyverse)
library(ggpubr)
library(rstatix)
library(BSDA)
library(data.table)
library(coin)


#do on all possible speaker pair. 
args = commandArgs(trailingOnly=TRUE)

if (length(args)<2) {
  stop("At least two languages must be supplied to create all possible combinations", call.=FALSE)
} 
args=list("French","English","German","Chinese","Dutch","Finnish","Italian", "Russian", "Spanish", "Portuguese")

#Below only if CV dataset
#----------------------------------------------------------------------------------
path="/home/maureen/work/projects/multilingual_lfe/local/abx/lfe_cv/"
csv="data_on_spk_by_lang.csv"
args=list("ca","cy","de","en","fa","fr","it", "kab", "rw")
#----------------------------------------------------------------------------------


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
  
    
  # same_a=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_A,"_10h_10spk_ts-test_",lang_A,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
  # same_b=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_B,"_10h_10spk_ts-test_",lang_B,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
  # diff_a=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_A,"_10h_10spk_ts-test_",lang_B,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
  # diff_b=paste("/home/maureen/work/projects/multilingual_lfe/local/abx/lfe/ivector_128_tr-train_",lang_B,"_10h_10spk_ts-test_",lang_A,"_0.5h_10spk/data_on_spk_by_lang.csv", sep="")
  # 
#if CV below -------------
  
  same_a=paste(path, "ivector_128_tr-",lang_A,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
  same_b=paste(path, "ivector_128_tr-",lang_B,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
  diff_a=paste(path, "ivector_128_tr-",lang_A,"_train-15h-60spk_ts-",lang_B,"_test-0h-20spk/", csv, sep="")
  diff_b=paste(path, "ivector_128_tr-",lang_B,"_train-15h-60spk_ts-",lang_A,"_test-0h-20spk/", csv, sep="")
  #---------------------------
  
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

res <- wilcox.test(df$score.same, df$score.different, paired = TRUE, alternative="greater") #less because here we use the ABX error rate


d2 <- reshape2::melt(df, id.vars=c("id", "n"),measure.vars = c("score.same","score.different"))
d2$variable = as_factor(d2$variable)
d2$id = as_factor(d2$id)


res=coin::oneway_test(value ~ variable | id,
                data = d2, alternative="greater", distribution="approximate"(nresample=9999))
print(paste('The p.value for the Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling is',pvalue(res)))

res=coin::oneway_test(value ~ variable | id,
                      data = d2, alternative="two.sided", distribution="approximate"(nresample=9999))
print(paste('The p.value for the twosided Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling is',pvalue(res)))

#with weights:
# res=oneway_test(value ~ variable | id,
#                 data = d2, alternative="greater", distribution="approximate"(nresample=9999), weigths=d2$n)
# print(paste('The p.value for the Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling is',pvalue(res)))
# 

#If want asymptotic : 
  res=oneway_test(value ~ variable | id,
                  data = d2, alternative="greater")
