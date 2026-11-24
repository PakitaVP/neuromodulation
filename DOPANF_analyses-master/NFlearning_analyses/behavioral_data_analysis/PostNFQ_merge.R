
library(dplyr)
library(readr)
library(rlang)
library(rstudioapi)

# clear workspace
rm(list=ls())

# get data files
current_path = getActiveDocumentContext()$path
setwd(dirname(current_path))

path_to_PostNFQ_data_file <- "/Volumes/JustData/Projects/DOPANF/Data/BehavioralData/QuestionnairesResults"
#path_to_questionnaires_merge_file <- "/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync"
#path_to_questionnaires_merge_file <- "/Volumes/JustData/Projects/DOPANF/Data/BehavioralData/QuestionnairesResults"

PostNFQ_data <- read.csv(file.path(path_to_PostNFQ_data_file,"out_PostNFQ.csv"))
questionnaires_merge_data <- read.csv(file.path(path_to_questionnaires_merge_file,"out_data_questionnaires_merge.csv"))
PostNFQ_merged <- read.csv(file.path(path_to_questionnaires_merge_file,"PostNFQ_merged.csv"))


# create subsets of data that need to be included in new file
PostNFQ_data_subset <- PostNFQ_data %>% 
  select(c("SubjectID", "Regulation_MOTIVATION_Hardness", "Regulation_DEMOTIVATION_Hardness", "Regulation_Condition_Fun", "StrategySwitching_Used", "Feedback_Congruency", "Regulation_Condition_Fun_Degree", "Regulation_Condition_Harder", "Regulation_Condition_Harder_Degree",
          "StrategyRating_MOTIVATION_PersonalSuccess", "StrategyRating_MOTIVATION_FamilyFriends", "StrategyRating_MOTIVATION_GeneralMotivation", "StrategyRating_MOTIVATION_RomanticImagery", "StrategyRating_MOTIVATION_LeisureActivity", "StrategyRating_MOTIVATION_Food", 
          "StrategyRating_MOTIVATION_Others", "StrategyRating_DEMOTIVATION_PersonalFail", "StrategyRating_DEMOTIVATION_GeneralDemotivation", "StrategyRating_DEMOTIVATION_Nothing", "StrategyRating_DEMOTIVATION_Counting", "StrategyRating_DEMOTIVATION_Others", 
          "RegulationPerformance_Increase", "RegulationPerformance_Increase_WhichRun_Day1", "RegulationPerformance_Increase_WhichRun_Day2",  "RegulationPerformance_Decrease", "RegulationPerformance_Decrease_WhichRun_Day1", "RegulationPerformance_Decrease_WhichRun_Day2",
          "Feedback_ImprovementPossible", "Feedback_Concentration", "Feedback_Concentration_GettingWorse_Day1", "Feedback_Concentration_GettingWorse_Day2", "Feedback_Pause_Rating", "Strategy_MakingUp_Easiness")) 
PostNFQ_data_subset$SubjectID <- as.numeric(PostNFQ_data_subset$SubjectID)
questionnaires_merge_data_subset <- questionnaires_merge_data[, c("SubjectID", "Feedbackgruppe", "BIDS_subID")]


# merge and create new file
PostNFQ_merged <- PostNFQ_data_subset %>%
  full_join(questionnaires_merge_data_subset,  by = 'SubjectID', suffix = c("", ".X") ) %>%   
  select(-ends_with(".X"))

lines_to_remove <- which(is.na(PostNFQ_merged$BIDS_subID))
if (FALSE == is_empty(lines_to_remove)) {
  PostNFQ_merged<-PostNFQ_merged[-lines_to_remove, ]
}

lines_to_remove <- which(is.na(PostNFQ_merged$Feedbackgruppe))
if (FALSE == is_empty(lines_to_remove)) {
  PostNFQ_merged<-PostNFQ_merged[-lines_to_remove, ]
}
write_csv(PostNFQ_merged, file.path(path_to_questionnaires_merge_file, "PostNFQ_merged.csv"))



by_feedbackgroup <- PostNFQ_merged %>%
  group_by(Feedbackgruppe)

group_overview_means<- by_feedbackgroup %>%
  summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE)))
group_overview_sd<-by_feedbackgroup %>%
  summarise(across(where(is.numeric), ~ sd(.x, na.rm = TRUE)))

# alle Subjects rausschreiben, die zu Feedbackgruppe 1, 2 oder 3 gehören
group1 <- PostNFQ_merged$BIDS_subID[PostNFQ_merged$Feedbackgruppe == 1]
group2 <- PostNFQ_merged$BIDS_subID[PostNFQ_merged$Feedbackgruppe == 2]
group3 <- PostNFQ_merged$BIDS_subID[PostNFQ_merged$Feedbackgruppe == 3]


# Hardness 
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_score_MOTIVATION_Hardness = mean(Regulation_MOTIVATION_Hardness, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$Regulation_MOTIVATION_Hardness, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_score_DEMOTIVATION_Hardness = mean(Regulation_DEMOTIVATION_Hardness, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$Regulation_DEMOTIVATION_Hardness, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede


# Anzahl genutzter Strategien berechnen & als neue Variable speichern (zuerst neuen Dataframe mit gleicher Anzahl Zeilen erstellen)

PostNFQ_data_74subs <- semi_join(PostNFQ_data, PostNFQ_merged, by = "SubjectID")

PostNFQ_merged$StrategyUse_MOTIVATION_sum <- rowSums(PostNFQ_data_74subs[ , c(12, 13, 14, 15, 16, 17, 18)], na.rm=TRUE) # mit "others"?
PostNFQ_merged$StrategyUse_DEMOTIVATION_sum <- rowSums(PostNFQ_data_74subs[ , c(27, 28, 29, 30, 31)], na.rm=TRUE)

# Gruppenunterschiede berechnen
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_score_MOTIVATION = mean(StrategyUse_MOTIVATION_sum, na.rm = TRUE))

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_score_DEMOTIVATION = mean(StrategyUse_DEMOTIVATION_sum, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$StrategyUse_MOTIVATION_sum, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
pairwise.t.test(PostNFQ_merged$StrategyUse_DEMOTIVATION_sum, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede


# Mittleres Rating für jede Strategie (nicht benutzt = 0)
  
mean_StrategyRating_Motivation_PersonalSuccess <- mean(PostNFQ_data$StrategyRating_MOTIVATION_PersonalSuccess[PostNFQ_data$StrategyRating_MOTIVATION_PersonalSuccess !=0], na.rm = TRUE)
mean_StrategyRating_Motivation_PersonalSuccess
# 3.27027
PostNFQ_merged %>%
  filter(StrategyRating_MOTIVATION_PersonalSuccess != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Motivation_PersonalSuccess = mean(StrategyRating_MOTIVATION_PersonalSuccess, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_MOTIVATION_PersonalSuccess, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede


PostNFQ_merged$mean_StrategyRating_Motivation_FamilyFriends <- mean(PostNFQ_data$StrategyRating_MOTIVATION_FamilyFriends[PostNFQ_data$StrategyRating_MOTIVATION_FamilyFriends !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Motivation_FamilyFriends
# 3.774648
PostNFQ_merged %>%
  filter(StrategyRating_MOTIVATION_FamilyFriends != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Motivation_FamilyFriends = mean(StrategyRating_MOTIVATION_FamilyFriends, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_MOTIVATION_FamilyFriends, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede


PostNFQ_merged$mean_StrategyRating_Motivation_GeneralMotivation <- mean(PostNFQ_data$StrategyRating_MOTIVATION_GeneralMotivation[PostNFQ_data$StrategyRating_MOTIVATION_GeneralMotivation !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Motivation_GeneralMotivation
# 3.391892
PostNFQ_merged %>%
  filter(StrategyRating_MOTIVATION_GeneralMotivation != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Motivation_GeneralMotivation = mean(StrategyRating_MOTIVATION_GeneralMotivation, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_MOTIVATION_GeneralMotivation, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede

PostNFQ_merged$mean_StrategyRating_Motivation_RomanticImagery <- mean(PostNFQ_data$StrategyRating_MOTIVATION_RomanticImagery[PostNFQ_data$StrategyRating_MOTIVATION_RomanticImagery !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Motivation_RomanticImagery
# 3.677966
PostNFQ_merged %>%
  filter(StrategyRating_MOTIVATION_RomanticImagery != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Motivation_RomanticImagery = mean(StrategyRating_MOTIVATION_RomanticImagery, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_MOTIVATION_RomanticImagery, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede

PostNFQ_merged$mean_StrategyRating_Motivation_LeisureActivity <- mean(PostNFQ_data$StrategyRating_MOTIVATION_LeisureActivity [PostNFQ_data$StrategyRating_MOTIVATION_LeisureActivity!=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Motivation_LeisureActivity
# 3.6875
PostNFQ_merged %>%
  filter(StrategyRating_MOTIVATION_LeisureActivity != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Motivation_LeisureActivity = mean(StrategyRating_MOTIVATION_LeisureActivity, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_MOTIVATION_LeisureActivity, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede

PostNFQ_merged$mean_StrategyRating_Motivation_Food <- mean(PostNFQ_data$StrategyRating_MOTIVATION_Food[PostNFQ_data$StrategyRating_MOTIVATION_Food !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Motivation_Food
# 2.8
PostNFQ_merged %>%
  filter(StrategyRating_MOTIVATION_Food != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Motivation_Food = mean(StrategyRating_MOTIVATION_Food, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_MOTIVATION_Food, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede

PostNFQ_merged$mean_StrategyRating_Motivation_Others <- mean(PostNFQ_data$StrategyRating_MOTIVATION_Others [PostNFQ_data$StrategyRating_MOTIVATION_Others !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Motivation_Others
# 2.930233
PostNFQ_merged %>%
  filter(StrategyRating_MOTIVATION_Others != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Motivation_Others = mean(StrategyRating_MOTIVATION_Others, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_MOTIVATION_Others, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede


PostNFQ_merged$mean_StrategyRating_Demotivation_PersonalFail <- mean(PostNFQ_data$StrategyRating_DEMOTIVATION_PersonalFail [PostNFQ_data$StrategyRating_DEMOTIVATION_PersonalFail !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Demotivation_PersonalFail
# 3.411765
PostNFQ_merged %>%
  filter(StrategyRating_DEMOTIVATION_PersonalFail != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Demotivation_PersonalFail = mean(StrategyRating_DEMOTIVATION_PersonalFail, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_DEMOTIVATION_PersonalFail, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede

PostNFQ_merged$mean_StrategyRating_Demotivation_GeneralDemotivation <- mean(PostNFQ_data$StrategyRating_DEMOTIVATION_GeneralDemotivation [PostNFQ_data$StrategyRating_DEMOTIVATION_GeneralDemotivation !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Demotivation_GeneralDemotivation
# 3.76
PostNFQ_merged %>%
  filter(StrategyRating_DEMOTIVATION_GeneralDemotivation != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Demotivation_GeneralDemotivation = mean(StrategyRating_DEMOTIVATION_GeneralDemotivation, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_DEMOTIVATION_GeneralDemotivation, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede

PostNFQ_merged$mean_StrategyRating_Demotivation_Nothing <- mean(PostNFQ_data$StrategyRating_DEMOTIVATION_Nothing [PostNFQ_data$StrategyRating_DEMOTIVATION_Nothing !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Demotivation_Nothing
# 3.285714
PostNFQ_merged %>%
  filter(StrategyRating_DEMOTIVATION_Nothing != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Demotivation_Nothing = mean(StrategyRating_DEMOTIVATION_Nothing, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_DEMOTIVATION_Nothing, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede

PostNFQ_merged$mean_StrategyRating_Demotivation_Counting <- mean(PostNFQ_data$StrategyRating_DEMOTIVATION_Counting [PostNFQ_data$StrategyRating_DEMOTIVATION_Counting !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Demotivation_Counting
# 2.214286
PostNFQ_merged %>%
  filter(StrategyRating_DEMOTIVATION_Counting != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Demotivation_Counting = mean(StrategyRating_DEMOTIVATION_Counting, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_DEMOTIVATION_Counting, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede


PostNFQ_merged$mean_StrategyRating_Demotivation_Others <- mean(PostNFQ_data$StrategyRating_DEMOTIVATION_Others [PostNFQ_data$StrategyRating_DEMOTIVATION_Others !=0], na.rm = TRUE)
PostNFQ_merged$mean_StrategyRating_Demotivation_Others
# 3.4375
PostNFQ_merged %>%
  filter(StrategyRating_DEMOTIVATION_Others != 0) %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_StrategyRating_Demotivation_Others = mean(StrategyRating_DEMOTIVATION_Others, na.rm = TRUE),
    n = n()
  )
pairwise.t.test(PostNFQ_merged$StrategyRating_DEMOTIVATION_Others, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# --> keine Gruppenunterschiede

# Fun (+Degree)

sum(PostNFQ_merged$Regulation_Condition_Fun == 0, na.rm = TRUE) # 23 Beide gleich
sum(PostNFQ_merged$Regulation_Condition_Fun == 1, na.rm = TRUE) # 43 Motivation
sum(PostNFQ_merged$Regulation_Condition_Fun == 2, na.rm = TRUE) # 8 Demotivation 

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_Regulation_Condition_Fun = mean(Regulation_Condition_Fun, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$Regulation_Condition_Fun, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede
mean_fun_degree <- mean(PostNFQ_merged$Regulation_Condition_Fun_Degree, na.rm = TRUE)
mean_fun_degree
# 5.116327


# Harder (+Degree)
sum(PostNFQ_merged$Regulation_Condition_Harder == 0, na.rm = TRUE) # 10 Beide gleich
sum(PostNFQ_merged$Regulation_Condition_Harder == 1, na.rm = TRUE) # 40 Motivation
sum(PostNFQ_merged$Regulation_Condition_Harder == 2, na.rm = TRUE) # 24 Demotivation 

pairwise.t.test(PostNFQ_merged$Regulation_Condition_Harder, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)  
# keine Gruppenunterschiede

mean_harder_degree <- mean(PostNFQ_merged$Regulation_Condition_Harder_Degree, na.rm = TRUE)
mean_harder_degree
# 5.212698


# Strategy Switching
sum(PostNFQ_merged$StrategySwitching_Used == 1, na.rm = TRUE) # --> 43
sum(PostNFQ_merged$StrategySwitching_Used == 0, na.rm = TRUE) # --> 31

# Feedback Congruency
PostNFQ_merged$mean_Feedback_Congruency <- mean(PostNFQ_merged$Feedback_Congruency, na.rm = TRUE)
PostNFQ_merged$mean_Feedback_Congruency
# 3.377027
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_Feedback_Congruency = mean(Feedback_Congruency, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$Feedback_Congruency, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede: wieso?


# Performance Increase 

mean_performance_increase <- mean(PostNFQ_merged$RegulationPerformance_Increase, na.rm = TRUE)
mean_performance_increase
# 3.109459 (Skala 0-8)
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_performance_increase = mean(RegulationPerformance_Increase, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$RegulationPerformance_Increase, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede


# Day 1
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day1 == 1, na.rm = TRUE) # 5
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day1 == 2, na.rm = TRUE) # 21
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day1 == 3, na.rm = TRUE) # 33 
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day1 == 4, na.rm = TRUE) # 8
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day1 == 5, na.rm = TRUE) # 7

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_regulationPerformance_Increase_WhichRun_Day1 = mean(RegulationPerformance_Increase_WhichRun_Day1, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day1, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede

# Day 2
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day2 == 1, na.rm = TRUE) # 11
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day2 == 2, na.rm = TRUE) # 39
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day2 == 3, na.rm = TRUE) # 19 
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day2 == 4, na.rm = TRUE) # 1
sum(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day2 == 5, na.rm = TRUE) # 4

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_regulationPerformance_Increase_WhichRun_Day2 = mean(RegulationPerformance_Increase_WhichRun_Day2, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$RegulationPerformance_Increase_WhichRun_Day2, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede


# Performance Decrease 

mean_performance_decrease <- mean(PostNFQ_merged$RegulationPerformance_Decrease, na.rm = TRUE)
mean_performance_decrease
# 4.048649 (Skala 0-8)
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_performance_decrease = mean(RegulationPerformance_Decrease, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$RegulationPerformance_Decrease, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede


# Day 1
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day1 == 1, na.rm = TRUE) # 11
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day1 == 2, na.rm = TRUE) # 7
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day1 == 3, na.rm = TRUE) # 8
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day1 == 4, na.rm = TRUE) # 30
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day1 == 5, na.rm = TRUE) # 18

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_regulationPerformance_Decrease_WhichRun_Day1 = mean(RegulationPerformance_Decrease_WhichRun_Day1, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day1, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede

# Day 2
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day2 == 1, na.rm = TRUE) # 10
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day2 == 2, na.rm = TRUE) # 8
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day2 == 3, na.rm = TRUE) # 16 
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day2 == 4, na.rm = TRUE) # 27
sum(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day2 == 5, na.rm = TRUE) # 13

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_regulationPerformance_Decrease_WhichRun_Day2 = mean(RegulationPerformance_Decrease_WhichRun_Day2, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$RegulationPerformance_Decrease_WhichRun_Day2, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede

# Feedback Improvemet
  
mean_Feedback_ImprovementPossible <- mean(PostNFQ_merged$Feedback_ImprovementPossible, na.rm = TRUE)
mean_Feedback_ImprovementPossible
# 3.608108 (Skala 0-10)
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_Feedback_ImprovementPossible = mean(Feedback_ImprovementPossible, na.rm = TRUE))
  
pairwise.t.test(PostNFQ_merged$Feedback_ImprovementPossible, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
  

# Concentration
mean_concentration <- mean(PostNFQ_merged$Feedback_Concentration, na.rm = TRUE)
mean_concentration
# 5.643243 (Skala 1-10)
PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_concentration = mean(Feedback_Concentration, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$Feedback_Concentration, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# Gruppe 1 sign. von 3 unterschiedlich, Gruppe 2 sign. von Gruppe 3 unterschiedlich

# Day 1
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day1 == 1, na.rm = TRUE) # 2
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day1 == 2, na.rm = TRUE) # 5
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day1 == 3, na.rm = TRUE) # 9 
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day1 == 4, na.rm = TRUE) # 36
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day1 == 5, na.rm = TRUE) # 22

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_Feedback_Concentration_GettingWorse_Day1 = mean(Feedback_Concentration_GettingWorse_Day1, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day1, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede

# Day 2
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day2 == 1, na.rm = TRUE) # 1
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day2 == 2, na.rm = TRUE) # 5
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day2 == 3, na.rm = TRUE) # 14 
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day2 == 4, na.rm = TRUE) # 35
sum(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day2 == 5, na.rm = TRUE) # 19

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_Feedback_Concentration_GettingWorse_Day2 = mean(Feedback_Concentration_GettingWorse_Day2, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$Feedback_Concentration_GettingWorse_Day2, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)
# keine Gruppenunterschiede

  
# Pause Rating

mean_pause_rating <- mean(PostNFQ_merged$Feedback_Pause_Rating, na.rm = TRUE)
mean_concentration
# 5.643243

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_Feedback_Pause_Rating = mean(Feedback_Pause_Rating, na.rm = TRUE))
  
pairwise.t.test(PostNFQ_merged$Feedback_Pause_Rating, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)  


# Stratgey Making Up Easiness
mean_strategy_makingup_easiness <- mean(PostNFQ_merged$Strategy_MakingUp_Easiness, na.rm = TRUE)
mean_strategy_makingup_easiness
# 4.47027

PostNFQ_merged %>%
  group_by(Feedbackgruppe) %>%
  summarise(mean_Strategy_MakingUp_Easiness = mean(Strategy_MakingUp_Easiness, na.rm = TRUE))

pairwise.t.test(PostNFQ_merged$Strategy_MakingUp_Easiness, PostNFQ_merged$Feedbackgruppe, p.adj = "none", paired = FALSE, alternative = c("two.sided"), na.rm = FALSE)  


