# Check data for normality

setwd("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/extract_from_cons/")
file_path = "con_extractions_probSNVTA_task-NFTraining_wmcsf_confounder_restimplicit_summary.csv"
mask_file <- read.csv(file_path)
 
 
hist(mask_file$mean_thresh05[mask_file$feedback_group == 1],
     breaks = 20,
     main = "Histogram (Group 1)",
     xlab = "Variable")

hist(mask_file$mean_thresh05[mask_file$feedback_group == 2],
     breaks = 20,
     main = "Histogram (Group 2)",
     xlab = "Variable")

hist(mask_file$mean_thresh05[mask_file$feedback_group == 3],
     breaks = 20,
     main = "Histogram (Group 3)",
     xlab = "Variable")
