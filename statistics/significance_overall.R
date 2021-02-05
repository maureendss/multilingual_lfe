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



delta_0 <- 0

# by assumption
sigma_sq_1 <- 3
sigma_sq_2 <- 2

n_1 <- length(same)
n_2 <- length(different)

# calculate the z-statistic
z_stat <- (mean(same) - mean(different) - delta_0) / 
  sqrt(sigma_sq_1 / n_1 + sigma_sq_2 / n_2)

z_stat
#> [1] -0.9721333




Z <- Normal(0, 1)  # make a standard normal r.v.
1 - cdf(Z, abs(z_stat)) + cdf(Z, -abs(z_stat))
#> [1] 0.3309842


#Not statistically different.


x=c(same, different)
y=c(replicate(length(same), 'same'), replicate(length(different), 'different'))

#pool_sd=True means PAIRED
pwc = pairwise.t.test(
  x,y, 
  p.adjust.method = "bonferroni")


df<-expand.grid(same,different)




