library(ggplot2)
library(distributions3)
library(reshape2)
library(tidyverse)
library(ggpubr)
library(rstatix)

library(data.table)

lfe_detailed <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_detailed.csv")
df <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_all.csv")
#In this file, we do overall per langpair. Eg we compare multiple lang pairs. We don't care about Ns. '

same=df[,'same']
diff=df[,'different']

#Frol https://cran.r-project.org/web/packages/distributions3/vignettes/two-sample-z-test.html
qqnorm(same)
qqline(same)
qqnorm(diff)
qqline(diff)

ggplot(df, aes(x=lfe, y=av_dist)) +geom_point() +  geom_text(label=df$langpair)
ggplot(df, aes(x=lfe, y=av_dist)) +geom_point() + geom_smooth(method=lm)
ggplot(df, aes(x=lfe, y=av_dist)) +geom_point() + geom_smooth(method=lm, se=FALSE)
ggplot(df, aes(x=lfe, y=av_dist)) +geom_point() + geom_smooth()


#per distance
d <- melt(df, id.vars=c("langpair","lfe","same","different"),measure.vars = c("phono","synt","inv"))
ggplot(d, aes(x=lfe, y=value, color=variable)) +geom_point() + geom_smooth()

#Maybe should do on Significant only?
d <- melt(df, id.vars=c("langpair","lfe","same","different","significant"),measure.vars = c("phono","synt","inv"))
d_sig=d[d$significant=="yes",]
ggplot(d_sig, aes(x=lfe, y=value, color=variable)) +geom_point() + geom_smooth()


  ggplot(d, aes(lfe,value,color=variable)) + 
  geom_point() +
  facet_wrap(~variable)  + stat_smooth(method="lm",aes(fill=variable)) 
  
  
  ggplot(d_sig, aes(lfe,value,color=variable)) + 
    geom_point() +
    facet_wrap(~variable)  + stat_smooth(method="lm",aes(fill=variable)) 
  
  d2 <- melt(df, id.vars=c("langpair","lfe","significant"),measure.vars = c("same","different"))
  res <- wilcox.test(value ~ variable, data = d2, paired = TRUE, alternative="less") #less because here we use the ABX error rate
  
  
  
  #--------- tests
  
  library(coin)

  #Just testing permutation
  d_sd<- melt(df, id.vars=c("langpair","significant"),measure.vars = c("same","different"))
  
  d_sd_sample=d_sd[sample(nrow(d_sd), 40), ]
  coin::oneway_test(value ~ variable, data=d_sd_sample, distribution="exact")
  

  
  library(RVAideMemoire)
  res=perm.cor.test(df$lfe, df$synt, nperm = 9999, progress = FALSE)
  print(paste('Syntactic Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
  res=perm.cor.test(df$lfe, df$phono, nperm = 9999, progress = FALSE)
  print(paste('Phonological Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
  res=perm.cor.test(df$lfe, df$inv, nperm = 9999, progress = FALSE)
  print(paste('Inventory Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))
  res=perm.cor.test(df$lfe, df$av_dist, nperm = 9999, progress = FALSE)
  print(paste('Average Distance: Permuted Pearson correlation (999 permutations) has  p value of ',res$p.value, 'for an R score of ', res$estimate))


  
  