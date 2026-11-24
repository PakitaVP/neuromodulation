# VAS means & p-values

library(dplyr)

out_data <- read.csv("/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/behavioral_data_analysis/out_data_questionnaires_merge.csv")

out_data <- out_data %>%
  select(Feedbackgruppe, BIDS_subID, starts_with("VAS"))

# means
out_data_means <- out_data %>%
  rowwise() %>%
  mutate(
    VAS_pre_rested_mean  = mean(c(VAS_score_Day1_PreExp_Ausgeruht, VAS_score_Day2_PreExp_Ausgeruht),  na.rm = TRUE),
    VAS_post_rested_mean = mean(c(VAS_score_Day1_PostExp_Ausgeruht, VAS_score_Day2_PostExp_Ausgeruht), na.rm = TRUE),
    
    VAS_pre_motivated_mean  = mean(c(VAS_score_Day1_PreExp_Motiviert, VAS_score_Day2_PreExp_Motiviert),  na.rm = TRUE),
    VAS_post_motivated_mean = mean(c(VAS_score_Day1_PostExp_Motiviert, VAS_score_Day2_PostExp_Motiviert), na.rm = TRUE),
    
    VAS_pre_bored_mean  = mean(c(VAS_score_Day1_PreExp_Gelangweilt, VAS_score_Day2_PreExp_Gelangweilt),  na.rm = TRUE),
    VAS_post_bored_mean = mean(c(VAS_score_Day1_PostExp_Gelangweilt, VAS_score_Day2_PostExp_Gelangweilt), na.rm = TRUE),
    
    VAS_pre_stressed_mean  = mean(c(VAS_score_Day1_PreExp_Gestresst, VAS_score_Day2_PreExp_Gestresst),  na.rm = TRUE),
    VAS_post_stressed_mean = mean(c(VAS_score_Day1_PostExp_Gestresst, VAS_score_Day2_PostExp_Gestresst), na.rm = TRUE),
    
    VAS_pre_interested_mean  = mean(c(VAS_score_Day1_PreExp_Interessiert, VAS_score_Day2_PreExp_Interessiert),  na.rm = TRUE),
    VAS_post_interested_mean = mean(c(VAS_score_Day1_PostExp_Interessiert, VAS_score_Day2_PostExp_Interessiert), na.rm = TRUE),
    
    VAS_pre_tired_mean  = mean(c(VAS_score_Day1_PreExp_Muede, VAS_score_Day2_PreExp_Muede),  na.rm = TRUE),
    VAS_post_tired_mean = mean(c(VAS_score_Day1_PostExp_Muede, VAS_score_Day2_PostExp_Muede), na.rm = TRUE),
    
    VAS_pre_frustrated_mean  = mean(c(VAS_score_Day1_PreExp_Frustriert, VAS_score_Day2_PreExp_Frustriert),  na.rm = TRUE),
    VAS_post_frustrated_mean = mean(c(VAS_score_Day1_PostExp_Frustriert, VAS_score_Day2_PostExp_Frustriert), na.rm = TRUE),
    
  ) %>%
  ungroup()


# group means + t-test 
out_data_means %>%
  group_by(Feedbackgruppe) %>%
  summarise(
    mean_pre  = mean(VAS_pre_frustrated_mean,  na.rm = TRUE),
    sd_pre    = round(sd(VAS_pre_frustrated_mean,    na.rm = TRUE), 2),
    mean_post = mean(VAS_post_frustrated_mean, na.rm = TRUE),
    sd_post   = round(sd(VAS_post_frustrated_mean,   na.rm = TRUE), 2),
    n = dplyr::n(),
    t_value = t.test(VAS_pre_frustrated_mean, VAS_post_frustrated_mean, paired = TRUE)$statistic,
    p_value = t.test(VAS_pre_frustrated_mean, VAS_post_frustrated_mean, paired = TRUE)$p.value
  )

