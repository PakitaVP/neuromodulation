library(car)
library(ggedit)
library(rstudioapi)
library(plyr)
library(readr)
library(dplyr)
library(ggplot2)
library(ggpubr)

# for Intervention group
data<-read.csv("Z:/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/extract_from_cons/DRTslope_ses-all_condition_UP-DOWN_mask-probSNVTA_task-NFTraining_wmcsf_confounder_rest-down_statmean.csv", header=TRUE, dec=".")

#todo: output path

drt_reward <- data$DRT12[data$group==1]

slope_reward <- data$slope[data$group==1]

drt_pun <- data$DRT12[data$group==2]

slope_pun <- data$slope[data$group==2]

drt_control <- data$DRT12[data$group==3]

slope_control <- data$slope[data$group==3]

df1 = data.frame(drt_reward, slope_reward)
df2 = data.frame(drt_pun, slope_pun)
df3 = data.frame(drt_control, slope_control)

my_graph1 <- ggplot(df1, aes(x = drt_reward, y = slope_reward)) +
  geom_point() + xlab("midbrain degree of regulation transfer") + ylab("slope during training") + 
  ggtitle("Reward feedback group") + 
  theme(text = element_text(size = 12)) +
  stat_smooth(method = "lm",
              col = "#C42126",
              se = TRUE,
              size = 1)
my_graph1
ggsave("corr_drt_slope_cond_up-down_statmean_group_reward.png")

my_graph2 <- ggplot(df2, aes(x = drt_pun, y = slope_pun)) +
  geom_point()  + xlab("midbrain degree of regulation transfer") + ylab("slope during training") + 
  ggtitle("Punishment feedback group") + 
  theme(text = element_text(size = 12)) +
  stat_smooth(method = "lm",
              col = "#C42126",
              se = TRUE,
              size = 1)
my_graph2
ggsave("corr_drt_slope_cond_up-down_statmean_group_punishment.png")

my_graph3 <- ggplot(df3, aes(x = drt_control, y = slope_control)) +
  geom_point()  + xlab("midbrain degree of regulation transfer") + ylab("slope during training") + 
  ggtitle("Control group") + 
  theme(text = element_text(size = 12)) +
  stat_smooth(method = "lm",
              col = "#C42126",
              se = TRUE,
              size = 1)
my_graph3
ggsave("corr_drt_slope_cond_up-down_statmean_group_control.png")

data$group<-factor(data$group)
violins<-ggplot(data, aes(x = factor(group,levels=c('1','2','3')) , y = DRT12)) +
  geom_violin(aes(fill = group))+
  geom_jitter()+
  scale_fill_brewer(palette="Blues")+
  theme_minimal() + 
  theme(legend.position = "none")+
  labs(title="",x="", y = "degree of \n regulation transfer (DRT)")+
  theme(axis.text = element_text(colour="grey20",size=20,hjust=.5,vjust=.5,face="plain"), 
        axis.title = element_text(colour="grey40",size=20,hjust=.5,vjust=.5,face="plain")) + 
  scale_x_discrete(breaks=c("1","2","3"),labels=c("Reward","Punishment", "Control"))



violins
ggsave("violins_drt_cond_up-down_statmean_group_control.png")
