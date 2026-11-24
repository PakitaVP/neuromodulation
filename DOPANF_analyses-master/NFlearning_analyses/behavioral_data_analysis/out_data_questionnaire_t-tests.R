library(dplyr)
library(purrr)
#library(tidyr)

out_data_questionnaires_merge_file <-read.csv("/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/out_data_questionnaires_merge.csv")

out_data_questionnaires_merge_file  <- out_data_questionnaires_merge_file  %>% filter(!is.na(Status_Note))
write.csv(out_data_questionnaires_merge_file, "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/behavioral_data_analysis/out_data_questionnaires_merge.csv", row.names = FALSE)


# Run t-tests for all variables 
variables_to_include <- 13:73 #without demographics
  

out_data_questionnaire_results <- map_dfr(variables_to_include, function(var_index) {
  variable_name <- colnames(out_data_questionnaires_merge_file)[var_index]
  
  x <- out_data_questionnaires_merge_file[[var_index]]
  g <- out_data_questionnaires_merge_file$Feedbackgruppe
  
  
  test <- pairwise.t.test(x, g,
                          p.adj = "none",
                          paired = FALSE,
                          alternative = "two.sided",
                          na.rm = TRUE)
  
  #make results table
  as.data.frame(as.table(test$p.value)) %>%
    rename(group1 = Var1, group2 = Var2, p_value = Freq) %>%
    filter(!is.na(p_value)) %>%
    mutate(variable = variable_name)
})  


write.csv(out_data_questionnaire_results, "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/behavioral_data_analysis/out_data_ttest_results.csv", row.names = FALSE)

