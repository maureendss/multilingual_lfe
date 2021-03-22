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


df <- read.csv("~/work/projects/multilingual_lfe/statistics/LFE_Librivox_consistency - raw_data.csv")
df2 <- read.csv("~/work/projects/multilingual_lfe/statistics/LFE_Librivox_consistency - raw_data_highdim.csv")


df_tsEng = filter(df, test == "eng")

df_tsFr = filter(df, test == "fra")

df_tsEngHD = filter(df2, test == "eng")

df_tsFrHD = filter(df2, test == "fra")



bp_tsEn<- ggplot(df_tsEng, aes(x =factor(0), y = LFE)) +
  scale_x_discrete(breaks = NULL) +
  xlab(NULL) +
  geom_boxplot() +
  geom_jitter() +
  scale_color_brewer(type = "qual", palette = 2) +
  theme(legend.position = "none") + ylim(-20, 35)+ geom_hline(yintercept=0, linetype="dashed", color = "red", size=0.5)


bp_tsFr <- ggplot(df_tsFr, aes(x =factor(0), y = LFE)) +
  scale_x_discrete(breaks = NULL) +
  xlab(NULL) +
  geom_boxplot() +
  geom_jitter() +
  scale_color_brewer(type = "qual", palette = 2) +
  theme(legend.position = "none")+ ylim(-20, 35)+ geom_hline(yintercept=0, linetype="dashed", color = "red", size=0.5)


bp_tsEnHD<- ggplot(df_tsEngHD, aes(x =factor(0), y = LFE)) +
  scale_x_discrete(breaks = NULL) +
  xlab(NULL) +
  geom_boxplot() +
  geom_jitter() +
  scale_color_brewer(type = "qual", palette = 2) +
  theme(legend.position = "none") + ylim(-50, 120) + geom_hline(yintercept=0, linetype="dashed", color = "red", size=0.5)


bp_tsFrHD <- ggplot(df_tsFrHD, aes(x =factor(0), y = LFE)) +
  scale_x_discrete(breaks = NULL) +
  xlab(NULL) +
  geom_boxplot() +
  geom_jitter() +
  scale_color_brewer(type = "qual", palette = 2) +
  theme(legend.position = "none")+ ylim(-50, 120) + geom_hline(yintercept=0, linetype="dashed", color = "red", size=0.5)



ggarrange(bp_tsEn, bp_tsFr,bp_tsEnHD, bp_tsFrHD,  
          labels = c("English test","French test", "English test (HighDim)","French test (HighDim)"),
          ncol = 2, nrow = 2, align="hv")  


library(patchwork)


#below tips from https://stackoverflow.com/questions/60347583/add-row-and-column-titles-with-ggarrange
#plot1<-plot2<-plot3<-plot4<- ggplot() + geom_point(aes(x=1, y=1, col="a"))
row1 <- ggplot() + annotate(geom = 'text', x=1, y=1, label="Low dimensions", angle = 90) + theme_void()
row2 <- ggplot()  + annotate(geom = 'text', x=1, y=1, label="High dimensions", angle = 90) + theme_void() 
col1 <- ggplot() + annotate(geom = 'text', x=1, y=1, label="English test") + theme_void() 
col2 <- ggplot() + annotate(geom = 'text', x=1, y=1, label="French test") + theme_void() 

layoutplot <- "
#cccddd
aeeefff
aeeefff
bggghhh
bggghhh
"
plotlist <- list(a = row1, b = row2, c = col1, d = col2, e= bp_tsEn, f=bp_tsFr +ylab(NULL) , g=bp_tsEnHD, h=bp_tsFrHD+ylab(NULL))
wrap_plots(plotlist, guides = 'collect', design = layoutplot)


#------------------------------------------------------------------------------------------------------------------

