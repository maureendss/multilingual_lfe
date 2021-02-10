#!/usr/bin/env Rscript
shhh <- suppressPackageStartupMessages # It's a library, so shhh!


shhh(library(ggplot2))
shhh(library(distributions3))

shhh(library(tidyverse))
shhh(library(ggpubr))
shhh(library(rstatix))
shhh(library(exactRankTests))
shhh(library(coin))

shhh(library(data.table))

#In this file, we do overall per langpair. Eg we compare multiple lang pairs. We don't care about Ns. '
args = commandArgs(trailingOnly=TRUE)

if (length(args)>1) {
  stop("You can supply one argument max, the CODE of the language you want to investigate. ", call.=FALSE)
} 

if (length(args)==1) {
  lang=args[1]
  print(paste("Filtering on language: ", lang))
} else {lang=""}

lang="spa"


df <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_all.csv")
df <- df[grep(lang, df$langpair),]

same=df[,'same']
different=df[,'different']

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

ggplot(test_results, aes(x = factor(condition, level=c('same','different')), y = score, color = condition)) +
  geom_boxplot() +
  geom_jitter() +
  stat_summary(fun.y="mean", color='black') +
  scale_color_brewer(type = "qual", palette = 2) +
  theme_minimal() +
  theme(legend.position = "none")


ggpaired(df, cond1="same", cond2= "different",
         ylab = "ABX score (in %)", xlab = "Condition", line.size=0.05)

res <- wilcox.test(df$same, df$different, paired = TRUE, alternative="less") #less because here we use the ABX error rate
print(paste('The p.value for the Wilcoxon signed rank exact test is',res$p.value))



res <- wilcox.exact(df$same,df$different, paired=TRUE, conf.int=TRUE, exact=TRUE, alternative="less")
print(paste('The p.value for the EXACT Wilcoxon signed rank exact test is',res$p.value))


#Approximative Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling )
d2 <- reshape2::melt(df, id.vars=c("langpair","lfe","significant"),measure.vars = c("same","different"))
d2$variable = as_factor(d2$variable)
d2$langpair = as_factor(d2$langpair)


res=oneway_test(value ~ variable | langpair,
            data = d2, alternative="less", distribution="approximate"(nresample=99999))

print(paste('The p.value for the Two-Sample Fisher-Pitman Permutation Test with Monte-Carlo sampling is',pvalue(res)))

# symmetry_test(value ~ variable | langpair,
              # data = d2, alternative="less", distribution="approximate"(nresample=99999))

