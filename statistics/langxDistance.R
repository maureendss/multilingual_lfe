library(ggplot2)
library(distributions3)
library(reshape2)
library(tidyverse)
library(ggpubr)
library(rstatix)

library(data.table)

#lfe_detailed <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_detailed.csv")
df <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_all.csv")
dataset="Librivox"

df <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_all_cv.csv")
dataset="CommonVoice"

#In this file, we do overall per langpair. Eg we compare multiple lang pairs. We don't care about Ns. '

same=df[,'same']
diff=df[,'different']

names(df)[names(df) == "synt" ] <- "syntaxic"
names(df)[names(df) == "phono" ] <- "phonological"
names(df)[names(df) == "inv" ] <- "inventory"


#Frol https://cran.r-project.org/web/packages/distributions3/vignettes/two-sample-z-test.html
qqnorm(same)
qqline(same)
qqnorm(diff)
qqline(diff)#use waiver() instead of title if no title but subtitle

ggplot(df, aes(x=av_dist, y=lfe)) +geom_point() + labs(x = "Average distance", y="LFE") + geom_text(label=df$langpair, nudge_y = +2.5) + ggtitle("Average distance vs LFE in function of language pair", subtitle = paste(dataset, "dataset"))
ggplot(df, aes(x=av_dist, y=lfe)) +geom_point() + labs(x = "Average distance", y="LFE") + geom_smooth(method=lm)
ggplot(df, aes(x=av_dist, y=lfe)) +geom_point() + labs(x = "Average distance", y="LFE") + geom_smooth(method=lm, se=FALSE)
ggplot(df, aes(x=av_dist, y=lfe)) +geom_point() + labs(x = "Average distance", y="LFE") +geom_smooth()


#per distance
d <- melt(df, id.vars=c("langpair","lfe","same","different"),measure.vars = c("phonological","syntaxic","inventory"))
ggplot(d, aes(x=value, y=lfe, color=variable)) + labs(x = "Average distance", y="LFE")+geom_point() + geom_smooth()
ggplot(d, aes(x=value, y=lfe, color=variable)) + labs(x = "Average distance", y="LFE")+geom_point() + geom_smooth(method=lm, se=FALSE)


#Maybe should do on Significant only?
d <- melt(df, id.vars=c("langpair","lfe","same","different","significant"),measure.vars = c("phono","synt","inv"))
#d <- melt(df, id.vars=c("langpair","lfe","same","different"),measure.vars = c("phono","synt","inv"))

d_sig=d[d$significant=="yes",]
ggplot(d_sig, aes(x=value, y=lfe, color=variable)) +geom_point() + geom_smooth()


  ggplot(d, aes(value,lfe,color=variable)) + labs(x = "Average distances", y="LFE") + 
  geom_point() +  ggtitle("Language pair distances vs LFE", subtitle = paste(dataset, "dataset")) +
  facet_wrap(~variable, scales = "free_x")  + stat_smooth(method="lm",aes(fill=variable)) #remove free if want same x acis dor all
  
  
  ggplot(d_sig, aes(value,lfe,color=variable)) + labs(x = "Average distances", y="LFE") + 
    geom_point() +
    facet_wrap(~variable, scales = "free_x")  + stat_smooth(method="lm",aes(fill=variable)) #remove free if want same x acis dor all
  
  #d2 <- melt(df, id.vars=c("langpair","lfe","significant"),measure.vars = c("same","different"))
  d2 <- melt(df, id.vars=c("langpair","lfe"),measure.vars = c("same","different"))
  
  res <- wilcox.test(value ~ variable, data = d2, paired = TRUE, alternative="less") #less because here we use the ABX error rate
  
  res <- wilcox.test(value ~ variable, data = d2, paired = TRUE, alternative="two.sided") #less because here we use the ABX error rate
  
  
  #--------- tests
  
  library(coin)

  #Just testing permutation
  #d_sd<- melt(df, id.vars=c("langpair","significant"),measure.vars = c("same","different"))
  d_sd<- melt(df, id.vars=c("langpair"),measure.vars = c("same","different"))
  
  d_sd_sample=d_sd[sample(nrow(d_sd), 40), ]
  coin::oneway_test(value ~ variable, data=d_sd_sample, distribution="exact")
  

  
  library(RVAideMemoire)
  res=perm.cor.test(df$lfe, df$synt, nperm = 999, progress = FALSE)
  print(paste('Syntactic Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
  res=perm.cor.test(df$lfe, df$phono, nperm = 999, progress = FALSE)
  print(paste('Phonological Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
  res=perm.cor.test(df$lfe, df$inv, nperm = 999, progress = FALSE)
  print(paste('Inventory Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
  res=perm.cor.test(df$lfe, df$av_dist, nperm = 999, progress = TRUE)
  print(paste('Average Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))


  
  