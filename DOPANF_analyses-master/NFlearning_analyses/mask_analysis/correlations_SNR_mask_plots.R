library(dplyr)
library(tidyr)
library(ggplot2)

rm(list = ls())

mask_file_path = ("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/extract_from_cons/con_extractions_probSNVTA_task-NFTraining_summary.csv")
SNR_file_path = ("/Users/malimaurer/Documents/Development/DOPANF_analyses/NFTraining_only_firstlevel_subjects.csv")

mask_file <- read.csv(mask_file_path)
SNR_file <- read.csv(SNR_file_path)


# neuen df in dem TR2-BL1 für jeden Probanden berechent wird
mask_file_merged_BL1TR2 <- mask_file %>%
  group_by(subject) %>%
  filter(row_number() %in% c(1, 9)) %>%
  arrange(subject, row_number()) %>%  
  mutate(mean_BL1TR2 = mean_thresh05[2] - mean_thresh05[1]) %>%
  ungroup() %>%
  select(subject, feedback_group, mean_thresh05, std_thresh05, run, mean_BL1TR2)

# neue SNR file, in der alle runs untereinander sind & nur SNR_brain Variable & framewise displacements drin ist
# SNRs
SNR_file_brain <- SNR_file %>%
  pivot_longer(
    cols = starts_with("tSNR_brain_"),      
    names_to = "run",               
    values_to = "tSNR_brain"             
  ) %>%
  group_by(subjectID_BIDS) %>%
  arrange(subjectID_BIDS) %>%
  mutate(run = row_number()) %>%
  ungroup() %>%
  filter(run != 10) %>%
  select(subjectID_BIDS, run, tSNR_brain)

# FDs
SNR_file_motion <- SNR_file %>% 
  pivot_longer(
    cols = starts_with("percent_motion_FDs_"),      
    names_to = "run",               
    values_to = "percent_motion_FDs"             
  ) %>%
  group_by(subjectID_BIDS) %>%
  arrange(subjectID_BIDS) %>%
  mutate(run = row_number()) %>%
  ungroup() %>%
  filter(run != 10) %>%
  select(subjectID_BIDS, run, percent_motion_FDs)

# beide zusammen
SNR_file_merged <- left_join(SNR_file_brain, SNR_file_motion, by = c("subjectID_BIDS", "run"))


# Merge File mit mask Werten & SNR Werten für jeden Subject & jedne Run
merge_file <- SNR_file_merged %>%
  left_join(
    mask_file %>% select(subject, run, mean_thresh05),  
    by = c("subjectID_BIDS" = "subject", "run" = "run")   
  ) 


# Korrelation MEAN & SNR
cor(merge_file$tSNR_brain, merge_file$mean_thresh05, use = "complete.obs", method = "pearson")

ggplot(merge_file, aes(x = mean_thresh05, y = tSNR_brain)) +
  geom_point() +
 # geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "correlation",
    x = "mean_thresh05",
    y = "tSNR_brain"
  ) +
  theme_minimal()

# Korrelation SNR & FDs
cor(merge_file$tSNR_brain, merge_file$percent_motion_FDs, use = "complete.obs", method = "pearson")

ggplot(merge_file, aes(x = percent_motion_FDs, y = tSNR_brain)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "correlation",
    x = "percent_motion_FDs",
    y = "tSNR_brain"
  ) +
  theme_minimal()

# Korrelation MEAN & FDs
cor(merge_file$mean_thresh05, merge_file$percent_motion_FDs, use = "complete.obs", method = "pearson")

ggplot(merge_file, aes(x = mean_thresh05, y = percent_motion_FDs)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "correlation",
    x = "mean_thresh05",
    y = "percent_motion_FDs"
  ) +
  theme_minimal()
