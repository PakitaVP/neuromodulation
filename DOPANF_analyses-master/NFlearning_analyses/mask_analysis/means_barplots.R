
library(dplyr)
library(tidyr)

mask_file <- read.csv("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/extract_from_cons/con_extractions_statsbasedSNVTA_task-NFTraining_wmcsf_confounder_restimplicit_summary.csv")

# UP/DOWN group means

TR_BL_singlesubject_withgroup <- mask_file %>%
  group_by(subject) %>%
  filter(run %in% c(5, 6), condition == "DOWN") %>% #UP
  select(subject, feedback_group, run, mean_thresh05, std_thresh05) %>%

pivot_wider(
  id_cols = c(subject, feedback_group),
  names_from = run,
  values_from = mean_thresh05,
  names_prefix = "run_"
) %>%
mutate(mean_diff = run_6 - run_5)


group_stats <- TR_BL_singlesubject_withgroup %>%
  group_by(feedback_group) %>%
  summarise(
    mean = mean(mean_diff, na.rm = TRUE),
    se   = sd(mean_diff, na.rm = TRUE) / sqrt(dplyr::n()))

group_stats