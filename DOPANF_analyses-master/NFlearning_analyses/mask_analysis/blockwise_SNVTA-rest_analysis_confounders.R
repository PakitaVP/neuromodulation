main <- function() {
  
  library(dplyr)
  library(tidyverse)
  library(rstatix)
  library(tidyr)
  library(ggplot2)
  library(stringr)
  
  setwd("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/timeseries_analysis/")
  merge_file_path = "blockwiseValues_statsbasedSNVTA_task-NFTraining_summary.csv"
  confounders_file_path = "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/behavioral_data_analysis/out_data_questionnaires_merge.csv"
  
  blockwise_values_file <- read.csv(merge_file_path)
  confounders_file <- read.csv(confounders_file_path)

  blockwise_values_file <- blockwise_values_file %>%
    mutate(subject = as.character(subject))
  
  confounders_file <- confounders_file %>%
    rename(subject = BIDS_subID) %>%
    mutate(subject = as.character(subject)) %>%
    select(subject, BDI_score, TICS_score_all)
  
  # create new merge file with only relevant columns
  merge_file <- blockwise_values_file %>%
    select(subject, run, feedback_group, matches("_trwise_meanblocks_\\d+$")) %>%
    pivot_longer(
      cols = matches("_trwise_meanblocks_\\d+$"),
      names_to = "trwise_meanblocks",
      values_to = "value"
    ) %>%
    left_join(confounders_file, by = "subject") %>%
    mutate(
      BDI_score = as.numeric(BDI_score),
      TICS_score_all = as.numeric(TICS_score_all)   
    )
  
  adjust_by_conf <<- function(df, y_col = "rest_corrected_value") {
    ok <- complete.cases(df[, c(y_col, "BDI_score", "TICS_score_all")])
    if (sum(ok) < 3) {
      df$rest_adj <- df[[y_col]]
      return(df)
    }
    fml <- as.formula(sprintf("%s ~ BDI_score + TICS_score_all", y_col))
    fit <- lm(fml, data = df[ok, , drop = FALSE])
    df$rest_adj <- NA_real_
    df$rest_adj[ok] <- resid(fit)
    df
  }
  
  run_BL_TR_rest_analysis(1, "up_", "Baseline (run 1) TRs UP-REST", "SNVTA_blockwise_baseline_UP-REST", merge_file)
  run_BL_TR_rest_analysis(1, "down_", "Baseline (run 1) TRs DOWN-REST", "SNVTA_blockwise_baseline_DOWN-REST", merge_file)
  run_BL_TR_rest_analysis(9, "up_", "Transfer (run 9) TRs UP-REST", "SNVTA_blockwise_transfer_UP-REST", merge_file)
  run_BL_TR_rest_analysis(9, "down_", "Transfer (run 9) TRs DOWN-REST", "SNVTA_blockwise_transfer_DOWN-REST", merge_file)

  run_trainingrun_analysis("up_", "Trainingrun TRs UP-REST", "SNVTA_blockwise_trainingruns_UP-REST", merge_file)
  run_trainingrun_analysis("down_", "Trainingrun TRs DOWN-REST", "SNVTA_blockwise_trainingruns_DOWN-REST", merge_file)

 # DOWN-REST analyses
  run_BL_TR_rest_analysis(1, "down_", "Baseline (run 1) TRs REST-DOWN", "SNVTA_blockwise_baseline_REST-DOWN", merge_file, TRUE)
  run_BL_TR_rest_analysis(9, "down_", "Transfer (run 9) TRs REST-DOWN", "SNVTA_blockwise_transfer_REST-DOWN", merge_file, TRUE)

  run_trainingrun_analysis("down_", "Trainingrun TRs REST-DOWN", "SNVTA_blockwise_trainingruns_REST-DOWN", merge_file, TRUE)
}

run_BL_TR_rest_analysis <- function(target_run, target_condition, plot_title, pdf_title, merge_file, rest_minus_down = FALSE) {  
  
  single_run_df <- merge_file %>%
    group_by(subject) %>%
    filter(run == target_run)
  
  # individual mean von REST
  rest_means <- single_run_df %>%
    filter(str_starts(trwise_meanblocks, "rest_")) %>%
    group_by(subject) %>%
    summarise(rest_mean = mean(value, na.rm = TRUE))
  
  
  if (rest_minus_down) {
    # UP-rest & down-rest neue Variable (oder DOWN-REST)
    single_run_df_new <- single_run_df %>%
      group_by(subject) %>%
      mutate(
        rest_corrected_value = mean(
          value[startsWith(trwise_meanblocks, "rest_")],
          na.rm = TRUE
        ) - value
      ) %>%
      ungroup()
  } else {
    single_run_df_new <- single_run_df %>%
      group_by(subject) %>%
      mutate(
        rest_corrected_value = value - mean(
          value[startsWith(trwise_meanblocks, "rest_")],
          na.rm = TRUE
        )
      ) %>%
      ungroup()
  }
  
  single_run_df_new <- adjust_by_conf(single_run_df_new, y_col = "rest_corrected_value")
  
  # group means (halbiert)
  group_means_split <- single_run_df_new %>%
    filter(str_starts(trwise_meanblocks, target_condition)) %>%
    filter(!is.na(rest_adj)) %>%
    mutate(tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$"))) %>%
    mutate(period = if_else(tr_number <= 6, "left", "right")) %>%
    group_by(feedback_group, period) %>%
    summarise(group_mean = mean(rest_adj, na.rm = TRUE), .groups = "drop")
  
  group_means_segment <- group_means_split %>%
    mutate(
      x_start = if_else(period == "left", 1, 7),
      x_end = if_else(period == "left", 6, 11)
    )
  
  
  # Plot  
  df_plot <- single_run_df_new %>%
    filter(str_starts(trwise_meanblocks, target_condition)) %>%
    filter(!is.na(rest_adj)) %>%
    mutate(tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$"))) # nimmt Nummer am Ende
  
  plot <- ggplot(data = df_plot, aes(x = tr_number, y = rest_adj, color = factor(feedback_group))) +
    stat_summary(
      fun.data = mean_cl_normal, geom = "ribbon", aes(fill = factor(feedback_group), group = feedback_group), alpha = 0.2, color = NA) +
    stat_summary(fun = mean, geom = "line", aes(group = feedback_group), linewidth = 0.9) +
    geom_segment( data = group_means_segment, aes(x = x_start, xend = x_end, y = group_mean, yend = group_mean, color = factor(feedback_group)), linewidth = 1.6) +
    coord_cartesian(ylim = c(-0.15, 0.15)) +
    scale_x_continuous(breaks = 1:11, labels = 1:11) +
    labs(
      x = "TR",
      y = "Mean Value (adjusted for confounders)",
      title = plot_title,
      color = "Group",
      linetype = "Period"
    ) +
    theme_minimal() +
    geom_vline(xintercept = 6.5, linewidth = 0.8, linetype= "dashed", color = "darkgrey")
  
  print(plot)
  pdf_save_path = paste0("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/mask_plots_blockwise_statsbasedSNVTA_adj/", pdf_title, "adj.pdf")
  ggsave(pdf_save_path, plot = plot, width = 6, height = 4, dpi = 300)
  
  # Significance test
  # ANOVA
  anova_data <- single_run_df_new %>%
    filter(str_starts(trwise_meanblocks, target_condition)) %>%
    filter(!is.na(rest_adj)) %>%
    mutate(
      tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$")),
      period = if_else(tr_number <= 6, "early", "late")
    ) %>%
    group_by(subject, feedback_group, period) %>%
    summarise(mean_value = mean(rest_corrected_value, na.rm = TRUE), .groups = "drop") %>%
    mutate(
      subject        = as.factor(subject),
      feedback_group = as.factor(feedback_group),
      period         = factor(period, levels = c("early","late"))
    )
  
  subject_covs <- merge_file %>%
    mutate(subject = as.character(subject)) %>%
    distinct(subject, BDI_score, TICS_score_all)
  
  anova_data <- anova_data %>%
    mutate(subject = as.character(subject)) %>%  # align type
    left_join(subject_covs, by = "subject") %>%
    mutate(
      subject        = as.factor(subject),
      feedback_group = as.factor(feedback_group),
      period         = factor(period, levels = c("early","late"))
    )
  
  anova_repeated_measures <- anova_data %>%
    anova_test(
      dv = mean_value, wid = subject,
      within  = period,
      between = feedback_group,
      covariate = c(BDI_score, TICS_score_all),   # both numeric covariates
      effect.size = "pes"
    )
  
  print(anova_repeated_measures)
  
  # Post-Hoc (Holm)
  posthoc_within <- anova_data %>%
    group_by(feedback_group) %>%
    pairwise_t_test(
      mean_value ~ period,
      paired = TRUE,
      p.adjust.method = "holm")
  
  posthoc_between <- anova_data %>%
    group_by(period) %>%
    pairwise_t_test(
      mean_value ~ feedback_group,
      paired = FALSE,
      p.adjust.method = "holm")
  
  print(posthoc_within)
  print(posthoc_between)
  
} 


run_trainingrun_analysis <- function(target_condition, plot_title, pdf_title, merge_file, rest_minus_down = FALSE) {
  
  single_run_df <- merge_file %>%
    filter(run %in% c(2, 3, 4, 7, 8))
  
  # individual mean von REST
  rest_means <- single_run_df %>%
    filter(str_starts(trwise_meanblocks, "rest_")) %>%
    group_by(subject) %>%
    summarise(rest_mean = mean(value, na.rm = TRUE), .groups = "drop")
  
  # UP-rest & down-rest neue Variable (oder REST-DOWN)
  if (rest_minus_down) {
    
    single_run_df_new <- single_run_df %>%
      left_join(rest_means, by = "subject") %>%
      mutate(rest_corrected_value = rest_mean - value) %>%
      filter(str_starts(trwise_meanblocks, target_condition))
    
  } else {
    single_run_df_new <- single_run_df %>%
      left_join(rest_means, by = "subject") %>%
      mutate(rest_corrected_value = value - rest_mean) %>%
      filter(str_starts(trwise_meanblocks, target_condition))
  }
  
  single_run_df_new <- adjust_by_conf(single_run_df_new, y_col = "rest_corrected_value")
  
  # Mittelwert über alle Trainingsruns hinweg 
  trainingrun_mean <- single_run_df_new %>%
    filter(str_starts(trwise_meanblocks, target_condition)) %>%
    filter(!is.na(rest_adj)) %>%
    group_by(subject, feedback_group, trwise_meanblocks, BDI_score, TICS_score_all) %>%
    summarise(individual_trainingrun_mean = mean(rest_adj, na.rm = TRUE), .groups = "drop")
  
  # Gruppenmittelwerte (halbiert)
  group_means_split <- trainingrun_mean %>%
    mutate(tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$"))) %>%
    mutate(period = if_else(tr_number <= 6, "left", "right")) %>%
    group_by(feedback_group, period) %>%
    summarise(group_mean = mean(individual_trainingrun_mean, na.rm = TRUE), .groups = "drop")
  
  group_means_segment <- group_means_split %>%
    mutate(
      x_start = if_else(period == "left", 1, 7),
      x_end = if_else(period == "left", 6, 11)
    )     
  
  # Plot  
  df_plot <- trainingrun_mean %>%
    filter(str_starts(trwise_meanblocks, target_condition)) %>%
    filter(!is.na(individual_trainingrun_mean)) %>%
    mutate(tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$"))) # nimmt Nummer am Ende
  
  plot <- ggplot(data = df_plot, aes(x = tr_number, y = individual_trainingrun_mean, color = factor(feedback_group))) +
    stat_summary(
      fun.data = mean_cl_normal, geom = "ribbon", aes(fill = factor(feedback_group), group = feedback_group), alpha = 0.2, color = NA) +
    stat_summary(fun = mean, geom = "line", aes(group = feedback_group), linewidth = 0.9) +
    geom_segment( data = group_means_segment, aes(x = x_start, xend = x_end, y = group_mean, yend = group_mean, color = factor(feedback_group)), linewidth = 2) +
    #coord_cartesian(ylim = c(-0.1, 0.1)) +
    scale_x_continuous(breaks = 1:11, labels = 1:11) +
    labs(
      x = "TR",
      y = " Mean Value (adjusted for confounders)",
      title = plot_title,
      color = "Group",
      linetype = "Period"
    ) +
    theme_minimal() +
    geom_vline(xintercept = 6.5, linewidth = 0.8, linetype= "dashed", color = "grey")
  
  print(plot)
  pdf_save_path = paste0("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/mask_plots_blockwise_statsbasedSNVTA_adj/", pdf_title, "_adj.pdf")
  ggsave(pdf_save_path, plot = plot, width = 6, height = 4, dpi = 300)
  
  # Significance test
  # ANOVA
  anova_data <- trainingrun_mean %>%
    mutate(
      tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$")),
      period = if_else(tr_number <= 6, "early", "late")
    ) %>%
    group_by(subject, feedback_group, period, BDI_score, TICS_score_all) %>%
    summarise(mean_value = mean(individual_trainingrun_mean, na.rm = TRUE), .groups = "drop") %>%
    mutate(
      subject        = as.factor(subject),
      feedback_group = as.factor(feedback_group),
      period         = factor(period, levels = c("early","late"))
      # keep BDI_score & TICS_score_all numeric
    )

  anova_repeated_measures <- anova_data %>%
    anova_test(
      dv = mean_value, wid = subject,
      within  = period,
      between = feedback_group,
      covariate = c(BDI_score, TICS_score_all),
      effect.size = "pes"
    )
  
  print(anova_repeated_measures)

  # Post hoc test (Holm)
  posthoc_within <- anova_data %>%
    group_by(feedback_group) %>%
    pairwise_t_test(
      mean_value ~ period,
      paired = TRUE,
      p.adjust.method = "holm")

  posthoc_between <- anova_data %>%
    group_by(period) %>%
    pairwise_t_test(
      mean_value ~ feedback_group,
      paired = FALSE,
      p.adjust.method = "holm")

  print(posthoc_within)
  print(posthoc_between)
}


main()


