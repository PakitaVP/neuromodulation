library(dplyr)
library(readr)
library(rlang)
library(rstudioapi)
library(purrr)
library(tidyr)
#library(broom)

rm(list=ls())

# read files
output_file_path <- "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/behavioral_data_analysis"
PostNFQ_data <- read.csv("/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/out_PostNFQ.csv")
BIDS_data <- read.csv("/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/out_data_questionnaires_merge.csv") %>%
  filter(!is.na(Feedbackgruppe), !is.na(Status_Note)) 

# add 2 new columns for sums of used strategies 
PostNFQ_data <- PostNFQ_data %>%
  mutate(
    StrategyUse_MOTIVATION_sum   = rowSums(across(12:18), na.rm = TRUE),
    StrategyUse_DEMOTIVATION_sum = rowSums(across(27:31), na.rm = TRUE)
  )
# add BIDS_subID to PostNFQ_file
PostNFQ_merged <- PostNFQ_data %>%
  left_join(BIDS_data %>% select(SubjectID, BIDS_subID, Feedbackgruppe), by = "SubjectID") %>%
  filter(!is.na(BIDS_subID))


# means and sds over all participants (ACHTUNG: nicht alle means machen Sinn zB: bei binären Items)
variables <- names(PostNFQ_merged)[12:62]

means <- PostNFQ_merged %>%
  summarise(across(all_of(variables), ~ mean(.x, na.rm = TRUE), .names = "{.col}_mean"))

# overall sds
sds <- PostNFQ_merged %>%
  summarise(across(all_of(variables), ~ sd(.x, na.rm = TRUE), .names = "{.col}_sd"))

# write to csv
write.csv(means, file.path(output_file_path, "PostNFQ_means.csv"), row.names = FALSE)
write.csv(sds, file.path(output_file_path,  "PostNFQ_sds.csv"), row.names = FALSE)



# group differences
columns_to_test <- c(19:26, 32:38, 40, 42, 45:56, 58:62)   
group_variable <- "Feedbackgruppe"
variables_to_test <- names(PostNFQ_merged)[columns_to_test]

results <- data.frame()

for (v in variables_to_test) {
  # raw p-values (no correction)
  res_raw <- pairwise.t.test(PostNFQ_merged[[v]],
                             PostNFQ_merged[[group_variable]],
                             p.adjust.method = "none")
  mat_raw <- as.data.frame(as.table(res_raw$p.value))
  names(mat_raw) <- c("group1", "group2", "p.value_raw")
  
  # adjusted p-values (Bonferroni)
  res_adj <- pairwise.t.test(PostNFQ_merged[[v]],
                             PostNFQ_merged[[group_variable]],
                             p.adjust.method = "bonferroni")
  mat_adj <- as.data.frame(as.table(res_adj$p.value))
  names(mat_adj) <- c("group1", "group2", "p.value_adj")
  
  # merge raw + adjusted
  mat <- merge(mat_raw, mat_adj, by = c("group1","group2"))
  mat <- mat[!is.na(mat$p.value_raw), ]   # keep only real comparisons
  mat$variable <- v
  
  results <- rbind(results, mat)
}



# save results
write.csv(results, file.path(output_file_path, "PostNFQ_ttest_results.csv"), row.names = FALSE)


# some other group differences with binary/categorical coding
# FUN
sum(PostNFQ_merged$Regulation_Condition_Fun == 0) # 23 Beide
sum(PostNFQ_merged$Regulation_Condition_Fun == 1) # 43 Mot
sum(PostNFQ_merged$Regulation_Condition_Fun == 2) # 8 Demot

# by group
PostNFQ_merged %>%
  group_by(Feedbackgruppe, Regulation_Condition_Fun) %>%
  summarise(n = n()) %>%
  mutate(percent = round(100 * n / sum(n), 1))

tab <- table(PostNFQ_merged$Feedbackgruppe, PostNFQ_merged$Regulation_Condition_Fun)
chisq.test(tab)
fisher.test(tab)
#--> keine signifikanten Gruppenunetrschiede


# HARDER
sum(PostNFQ_merged$Regulation_Condition_Harder == 0) # 10 Beide
sum(PostNFQ_merged$Regulation_Condition_Harder == 1) # 40 Mot
sum(PostNFQ_merged$Regulation_Condition_Harder == 2) # 24 Demot

# by group
PostNFQ_merged %>%
  group_by(Feedbackgruppe, Regulation_Condition_Harder) %>%
  summarise(n = n()) %>%
  mutate(percent = round(100 * n / sum(n), 1))

tab <- table(PostNFQ_merged$Feedbackgruppe, PostNFQ_merged$Regulation_Condition_Harder)
chisq.test(tab)
fisher.test(tab)
#--> keine signifikanten Gruppenunetrschiede

# Strategy Switching Used
sum(PostNFQ_merged$StrategySwitching_Used == 0) # 31 Nein
sum(PostNFQ_merged$StrategySwitching_Used == 1) # 43 Ja

PostNFQ_merged %>%
  group_by(Feedbackgruppe, StrategySwitching_Used) %>%
  summarise(n = n()) %>%
  mutate(percent = round(100 * n / sum(n), 1))

tab <- table(PostNFQ_merged$Feedbackgruppe, PostNFQ_merged$StrategySwitching_Used)
chisq.test(tab)
fisher.test(tab)
#--> keine signifikanten Gruppenunetrschiede


#Regulation Performance INcrease which run Day1
PostNFQ_merged %>%
  group_by(Feedbackgruppe, RegulationPerformance_Increase_WhichRun_Day1) %>%
  summarise(n = n()) %>%
  mutate(percent = round(100 * n / sum(n), 1))

tab <- table(PostNFQ_merged$Feedbackgruppe, PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day1)
chisq.test(tab)
fisher.test(tab)

# Day 2
df <- PostNFQ_merged %>%
  mutate(
    Feedbackgruppe = factor(Feedbackgruppe),
    RegulationPerformance_Increase_WhichRun_Day2 = factor(RegulationPerformance_Increase_WhichRun_Day2, levels = 1:5)
  ) %>%
  count(Feedbackgruppe, RegulationPerformance_Increase_WhichRun_Day2) %>%
  complete(Feedbackgruppe, RegulationPerformance_Increase_WhichRun_Day2, fill = list(n = 0)) %>%
  group_by(Feedbackgruppe) %>%
  mutate(percent = round(100 * n / sum(n), 1)) %>%
  ungroup()
df

tab <- table(PostNFQ_merged$Feedbackgruppe, PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day2)
chisq.test(tab)
fisher.test(tab)


#Regulation Performance DEcrease which run Day1
PostNFQ_merged %>%
  group_by(Feedbackgruppe, RegulationPerformance_Decrease_WhichRun_Day1) %>%
  summarise(n = n()) %>%
  mutate(percent = round(100 * n / sum(n), 1))

tab <- table(PostNFQ_merged$Feedbackgruppe, PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day1)
chisq.test(tab)
fisher.test(tab)

#Day2
PostNFQ_merged %>%
  group_by(Feedbackgruppe, RegulationPerformance_Decrease_WhichRun_Day2) %>%
  summarise(n = n()) %>%
  mutate(percent = round(100 * n / sum(n), 1))

tab <- table(PostNFQ_merged$Feedbackgruppe, PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day2)
chisq.test(tab)
fisher.test(tab)


#Concentration getting worse which run Day1
df <- PostNFQ_merged %>%
  mutate(
    Feedbackgruppe = factor(Feedbackgruppe),
    Feedback_Concentration_GettingWorse_Day1 = factor(Feedback_Concentration_GettingWorse_Day1, levels = 1:5)
  ) %>%
  count(Feedbackgruppe, Feedback_Concentration_GettingWorse_Day1) %>%
  complete(Feedbackgruppe, Feedback_Concentration_GettingWorse_Day1, fill = list(n = 0)) %>%
  group_by(Feedbackgruppe) %>%
  mutate(percent = round(100 * n / sum(n), 1)) %>%
  ungroup()
df

tab <- table(PostNFQ_merged$Feedbackgruppe, PostNFQ_merged$Feedback_Concentration_GettingWorse_Day1)
chisq.test(tab)
fisher.test(tab)

#Concentration getting worse which run Day2
df <- PostNFQ_merged %>%
  mutate(
    Feedbackgruppe = factor(Feedbackgruppe),
    Feedback_Concentration_GettingWorse_Day2 = factor(Feedback_Concentration_GettingWorse_Day2, levels = 1:5)
  ) %>%
  count(Feedbackgruppe, Feedback_Concentration_GettingWorse_Day2) %>%
  complete(Feedbackgruppe, Feedback_Concentration_GettingWorse_Day2, fill = list(n = 0)) %>%
  group_by(Feedbackgruppe) %>%
  mutate(percent = round(100 * n / sum(n), 1)) %>%
  ungroup()
df

tab <- table(PostNFQ_merged$Feedbackgruppe, PostNFQ_merged$Feedback_Concentration_GettingWorse_Day2)
chisq.test(tab)
fisher.test(tab)

# Strategy Amount MOTIVATION
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_strat = mean(StrategyAmount_MOTIVATION, na.rm = TRUE),
    sd_strat   = sd(StrategyAmount_MOTIVATION, na.rm = TRUE))

kruskal.test(StrategyAmount_MOTIVATION ~ Feedbackgruppe, data = PostNFQ_merged)

# Strategy Amount DEMOTIVATION
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_strat = mean(StrategyAmount_DEMOTIVATION, na.rm = TRUE),
    sd_strat   = sd(StrategyAmount_DEMOTIVATION, na.rm = TRUE))

kruskal.test(StrategyAmount_DEMOTIVATION ~ Feedbackgruppe, data = PostNFQ_merged)

