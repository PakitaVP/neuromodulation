# new demographics script (with 74 subs)

library(dplyr)

out_data_questionnaires_merge_file <- read.csv("/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/out_data_questionnaires_merge.csv")
output_file_path <- "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/behavioral_data_analysis/"


# clean (74 subs) and only relevant columns for demographics
out_data_questionnaires_merge_file <-  out_data_questionnaires_merge_file %>%
  filter(!is.na(Status_Note), !is.na(Feedbackgruppe)) %>%
  #select(BIDS_subID, Feedbackgruppe, Age, Gender, Height, Weight, Income, Income_bin)  



# calculate means and sds & write new files

# choose the variables to summarize
variables_to_calculate <- c("Age", "Income")

# calculate means
means <- out_data_questionnaires_merge_file %>%
  summarise(across(all_of(variables_to_calculate), ~ mean(.x, na.rm = TRUE), .names = "{.col}_mean"))

# calculate sds
sds <- out_data_questionnaires_merge_file %>%
  summarise(across(all_of(variables_to_calculate), ~ sd(.x, na.rm = TRUE), .names = "{.col}_sd"))

# save 
write.csv(means, file.path(output_file_path, "demographics_means.csv"), row.names = FALSE)
write.csv(sds,  file.path(output_file_path, "demographics_sds.csv"), row.names = FALSE)


sum(out_data_questionnaires_merge_file$Gender == "f") # 35 = f, 39 = m



# group differences --> no significant group differences in demographics

# Age
pairwise.t.test(out_data_questionnaires_merge_file$Age, out_data_questionnaires_merge_file$Feedbackgruppe, p.adjust.method = "bonferroni")
#   1    2   
#   2 0.17 -   
#   3 0.13 1.00

# Gender
tab <- table(out_data_questionnaires_merge_file$Feedbackgruppe, out_data_questionnaires_merge_file$Gender)
print(tab)
print(prop.table(tab, margin = 1))

chi_result <- chisq.test(tab)
print(chi_result)
# X-squared = 0.532, df = 2, p-value = 0.7664
