main <- function() {
  
  library(dplyr)
  library(ggplot2)
  library(broom)
  library(tidyr)
  library(rlang)
  library(car)
  
  mask_file <- read.csv("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/extract_from_cons/con_extractions_statsbasedSNVTA_task-NFTraining_wmcsf_confounder_restimplicit_summary.csv")
  confounders_file <- read.csv("/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/behavioral_data_analysis/out_data_questionnaires_merge.csv")
  
  # merge files 
  confounders_file <- confounders_file %>%
    rename(subject = BIDS_subID) %>%
    mutate(subject = as.character(subject)) %>%
    select(subject, BDI_score, TICS_score_all, BIS11_score_all)
  
  mask_file <- mask_file %>%
    mutate(subject = as.character(subject))
  
  mask_file <- mask_file %>%
    left_join(confounders_file, by = "subject") %>%   
    mutate(
      BDI_score = as.numeric(BDI_score),
      TICS_score_all = as.numeric(TICS_score_all)   
    )
  
  mean_variables <- c("mean_thresh05") #, "statistical_mean_q50")
  std_variables  <- c("std_thresh05") #, "statistical_std_q50")
  conditions <- c("UP", "DOWN") #, "UP-DOWN", "UP+DOWN")
  
  for (i in seq_along(mean_variables)) {
    mean_variable <- mean_variables[i]
    std_variable  <- std_variables[i] 
    
    for (condition in conditions) {
      
      run_TRBL_analysis("TR2-BL1", 1, 9, condition, mean_variable, std_variable, mask_file)
      run_TRBL_analysis("TR1-BL1", 1, 5, condition, mean_variable, std_variable, mask_file)
      run_TRBL_analysis("TR2-BL2", 6, 9, condition, mean_variable, std_variable, mask_file)
      run_TRBL_analysis("BL2-TR1", 6, 5, condition, mean_variable, std_variable, mask_file)
      run_TRBL_analysis("BL2-BL1", 6, 1, condition, mean_variable, std_variable, mask_file)
      
    }
  }
}

# confounders
adjust_by_confounders <- function(df, y_col) {
  
  df$BDI_score <- suppressWarnings(as.numeric(df$BDI_score))
  df$TICS_score_all <- suppressWarnings(as.numeric(df$TICS_score_all))
  
  ok <- stats::complete.cases(df[, c(y_col, "BDI_score", "TICS_score_all", "BIS11_score_all")])
  df[[paste0(y_col, "_adj")]] <- NA_real_
  if (sum(ok) >= 3) {
    df_sub <- df[ok, , drop = FALSE]
    fml <- stats::reformulate(c("BDI_score", "TICS_score_all", "BIS11_score_all"), response = y_col)
    fit <- stats::lm(fml, data = df_sub)
    df[[paste0(y_col, "_adj")]][ok] <- stats::residuals(fit)
  }
  df
}


run_TRBL_analysis <- function(title, run_number_a, run_number_b, target_condition, mean_variable, std_variable, mask_file) {
  
  old <- options(contrasts = c("contr.sum","contr.poly"))
  on.exit(options(old), add = TRUE)
  
  full_title <- paste0(title, "_", target_condition)
  
  TR_BL_summary <- mask_file %>%
    filter(run %in% c(run_number_a, run_number_b), condition == target_condition) %>%
    select(subject, feedback_group, !!sym(mean_variable), !!sym(std_variable), run) %>%
    tidyr::pivot_wider(
      names_from = run,
      values_from = c(!!sym(mean_variable), !!sym(std_variable)),
      names_glue = "{.value}_run{run}"
    ) %>%
    mutate(
      mean_TR_BL = !!sym(paste0(mean_variable, "_run", run_number_b)) -
        !!sym(paste0(mean_variable, "_run", run_number_a))
    ) %>%
    left_join(
      mask_file %>% select(subject, BDI_score, TICS_score_all, BIS11_score_all) %>% distinct(),
      by = "subject"
    ) %>%
    mutate(
      feedback_group = factor(feedback_group, levels = c(1,2,3),
                              labels = c("Reward","Punishment","Control")),
      BDI_score = as.numeric(BDI_score),
      TICS_score_all = as.numeric(TICS_score_all),
      BIS11_score_all = as.numeric(BIS11_score_all)
    )
  
  # ANCOVA (Type III)
  fit <- lm(mean_TR_BL ~ feedback_group + BDI_score + TICS_score_all + BIS11_score_all,
            data = TR_BL_summary)
  
  anova_df <- as.data.frame(car::Anova(fit, type = 3))  
  anova_df$term <- rownames(anova_df); rownames(anova_df) <- NULL
  cat("\n[ANCOVA] ", full_title, " | ", mean_variable, "\n", sep = "")
  print(subset(anova_df, term == "feedback_group", select = c(Df, `F value`, `Pr(>F)`)))
  
  # Pairwise comparisons 
  emm <- emmeans::emmeans(fit, ~ feedback_group)
  cat("[EMMs]\n"); print(summary(emm))
  contr <- pairs(emm, adjust = "holm")
  cat("[Pairs]  ", full_title, " | ", mean_variable, "\n", sep = "")
  print(contr)
}


main()
