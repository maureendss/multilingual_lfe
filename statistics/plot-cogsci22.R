library(ggplot2)
library(viridis)
library(hrbrthemes)
library(ggpubr)
library(envalysis) # Charger

langpair <- c("English-Finnish","English-Finnish",  "English-German",  "English-German")
condition <- c("accented", "native",   "accented", "native")
familiar <- c(1.54, 3.13, 2.15, 3.59)
unfamiliar <- c(1.41, 3.73, 2.12, 3.98)

df <- data.frame(langpair, condition, familiar, unfamiliar)

langpair <- c("English-Finnish","English-Finnish","English-Finnish","English-Finnish",  "English-German",  "English-German","English-German",  "English-German")
condition <- c("accented", "native",   "accented", "native", "accented", "native","accented", "native" )
#familiarity <- c("Native", "Native", "Non-native",  "Non-native","Native", "Native", "Non-native",  "Non-native")
familiarity <- c("Familiar", "Familiar", "Unfamiliar", "Unfamiliar","Familiar", "Familiar", "Unfamiliar", "Unfamiliar")

abx <- c(1.54, 3.13,1.41, 3.73,2.15, 3.59, 2.12, 3.98)
df <- data.frame(langpair, condition, familiarity, abx)


ggplot(df, aes(fill=familiarity, y=abx, x=condition)) + 
  geom_bar(position="dodge", stat="identity") +
  labs(x = "Condition", fill = "", y = "ABX speaker error rate (in %)") +
  scale_fill_grey() +
  facet_wrap(~langpair) +
  theme_bw() +
  theme(text = element_text(size=27)) 
  #  theme_publish() +

#     ylim(0,4.1) + geom_text(aes(label=abx), position=position_dodge(width=0.9), vjust=-0.25, size=8) +
  
  #theme(legend.position=c(.1,.85)) +
  
#more themes : https://ggplot2.tidyverse.org/reference/ggtheme.html

ggplot(df, aes(y=abx, x=condition)) + 
  geom_bar(
    aes(color = familiarity, fill = familiarity),
    stat = "identity", position = position_dodge(0.8),
    width = 0.7
  ) +
  theme_bw() +
  scale_fill_grey() 


  #  scale_fill_viridis(discrete = T, option = "E") +

  
  labs(x = "New x axis label", y = "New y axis label",
         title ="Add a title above the plot",
         subtitle = "Add a subtitle below title",
         caption = "Add a caption below plot",
         alt = "Add alt text to the plot",
         aes = "New <aes> legend title")

  
#theme(legend.position="none") +
    
#  ggtitle("LFE for the Engl") +

