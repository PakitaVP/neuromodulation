main <- function() {

  library(dplyr)
  library(broom)
  library(tidyr)
  library(rlang)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  
  
  setwd("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/extract_from_cons/")
  file_path = "con_extractions_statsbasedSNVTA_task-NFTraining_wmcsf_confounder_restimplicit_summary.csv"
  mask_file <- read.csv(file_path)
  
  mean_variables <- c("mean_thresh05" #, "statistical_mean_q50" 
                      )
  
  for (mean_variable in mean_variables) {
    run_trainingrun_analysis(mean_variable, mask_file)
  }
}

run_trainingrun_analysis <- function(mean_variable, mask_file) {
  
  onlytrainingruns_file <- mask_file %>%
    filter(run %in% c(2, 3, 4, 7, 8))
  
  onlytrainingruns_file$feedback_group <- factor(onlytrainingruns_file$feedback_group)
  
  f <- as.formula(paste(mean_variable, "~ run * feedback_group + (1 | subject)"))
  
  # model_up <- lmer(f, data = subset(onlytrainingruns_file, condition == "UP"))
  # print(summary(model_up))
  # emtr <- emtrends(model_up, pairwise ~ feedback_group, var = "run")
  # print(summary(emtr$emtrends))
  # print(summary(emtr$contrasts))
  
  model_down <- lmer(f, data = subset(onlytrainingruns_file, condition == "DOWN"))
  print(summary(model_down))
  emtr <- emtrends(model_down, pairwise ~ feedback_group, var = "run")
  print(summary(emtr$emtrends))
  print(summary(emtr$contrasts))
  
 # model_updown <- lmer(f, data = subset(onlytrainingruns_file, condition == "UP-DOWN"))
 # print(summary(model_updown))
 # emtrends(model_updown, pairwise ~ feedback_group, var = "run")

}

main()