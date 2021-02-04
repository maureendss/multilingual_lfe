library(ggplot2)
library(distributions3)

library(tidyverse)
library(ggpubr)
library(rstatix)

lfe_detailed <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_detailed.csv")
View(lfe_detailed)
lfe_all <- read.csv("~/work/projects/multilingual_lfe/statistics/lfe_all.csv")
View(lfe_all)


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

ggplot(test_results, aes(x = condition, y = score, color = condition)) +
  geom_boxplot() +
  geom_jitter() +
  scale_color_brewer(type = "qual", palette = 2) +
  theme_minimal() +
  theme(legend.position = "none")


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
