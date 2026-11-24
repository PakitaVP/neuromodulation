# Group means & SDs
library(dplyr)

#out_data_questionnaires_merge_file <- read.csv("/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/out_data_questionnaires_merge.csv")
PostNFQ_merge_file <- read.csv("/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/PostNFQ_merged.csv")
output_file_path <- "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/behavioral_data_analysis/"


# clean (74 subs) and only relevant columns for demographics
# out_data_questionnaires_merge_file <-  out_data_questionnaires_merge_file %>%
#   filter(!is.na(Status_Note), !is.na(Feedbackgruppe)) 



variables_to_calculate <- c(2:33)

# calculate means and sds by group
group_stats <- PostNFQ_merge_file %>%
  group_by(Feedbackgruppe) %>%  
  summarise(
    across(all_of(variables_to_calculate),
           list(mean = ~ round(mean(.x, na.rm = TRUE), 2),
                sd   = ~ round(sd(.x, na.rm = TRUE), 2)),
           .names = "{.col}_{.fn}")
  )

# save as CSV
write.csv(group_stats, file.path(output_file_path, "PostNFQ_means_sds_by_group.csv"), row.names = FALSE)
