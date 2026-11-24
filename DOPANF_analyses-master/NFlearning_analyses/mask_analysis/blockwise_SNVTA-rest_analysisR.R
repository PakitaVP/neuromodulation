main <- function() {
  
  library(dplyr)
  library(tidyverse)
  library(rstatix)
  library(tidyr)
  library(ggplot2)
  library(stringr)
  
  setwd("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/timeseries_analysis/")
  file_path = "blockwiseValues_scalingmode-4_mask-statsbasedSNVTA_task-NFTraining_summary.csv"
  blockwise_values_file <- read.csv(file_path)
  
  # create new merge file with only relevant columns
  merge_file <- blockwise_values_file %>%
    select(subject, run, feedback_group, matches("_trwise_meanblocks_\\d+$")) %>%
    pivot_longer(
      cols = matches("_trwise_meanblocks_\\d+$"),
      names_to = "trwise_meanblocks",
      values_to = "value"
    )
  
  run_BL_TR_rest_analysis(1, "up_", "Baseline (run 1) TRs UP", "SNVTA_blockwise_baseline_UP", merge_file)
  run_BL_TR_rest_analysis(1, "down_", "Baseline (run 1) TRs DOWN", "SNVTA_blockwise_baseline_DOWN", merge_file)
  run_BL_TR_rest_analysis(9, "up_", "Transfer (run 9) TRs UP", "SNVTA_blockwise_transfer_UP", merge_file)
  run_BL_TR_rest_analysis(9, "down_", "Transfer (run 9) TRs DOWN", "SNVTA_blockwise_transfer_DOWN", merge_file)


  run_trainingrun_analysis("up_", "Trainingrun TRs UP", "SNVTA_blockwise_trainingruns_UP", merge_file)
  run_trainingrun_analysis("down_", "Trainingrun TRs DOWN", "SNVTA_blockwise_trainingruns_DOWN", merge_file)

  # DOWN-REST analyses 
  # run_BL_TR_rest_analysis(1, "down_", "Baseline (run 1) TRs REST-DOWN", "SNVTA_blockwise_baseline_REST-DOWN", merge_file, TRUE)
  # run_BL_TR_rest_analysis(9, "down_", "Transfer (run 9) TRs REST-DOWN", "SNVTA_blockwise_transfer_REST-DOWN", merge_file, TRUE)
  # 
  # run_trainingrun_analysis("down_", "Trainingrun TRs REST-DOWN", "SNVTA_blockwise_trainingruns_REST-DOWN", merge_file, TRUE)
}

run_BL_TR_rest_analysis <- function(target_run, target_condition, plot_title, pdf_title, merge_file, rest_minus_down = FALSE) {  

  single_run_df <- merge_file %>%
    group_by(subject) %>%
    filter(run == target_run)
    
  # individual mean von REST
  # rest_means <- single_run_df %>%
  #   filter(str_starts(trwise_meanblocks, "rest_")) %>%
  #   group_by(subject) %>%
  #   summarise(rest_mean = mean(value, na.rm = TRUE))
  
  
  # if (rest_minus_down) {
  #   # UP-rest & down-rest neue Variable (oder DOWN-REST)
  #   single_run_df_new <- single_run_df %>%
  #     group_by(subject) %>%
  #     mutate(
  #       rest_corrected_value = mean(
  #         value[startsWith(trwise_meanblocks, "rest_")],
  #         na.rm = TRUE
  #       ) - value
  #     ) %>%
  #     ungroup()
  # } else {
  #   single_run_df_new <- single_run_df %>%
  #     group_by(subject) %>%
  #     mutate(
  #       rest_corrected_value = value - mean(
  #         value[startsWith(trwise_meanblocks, "rest_")],
  #         na.rm = TRUE
  #       )
  #     ) %>%
  #     ungroup()
  # }
 
  # group means (halbiert)
  group_means_split <- single_run_df %>%
    filter(str_starts(trwise_meanblocks, target_condition)) %>%
    filter(!is.na(value)) %>%
    mutate(tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$"))) %>%
    mutate(period = if_else(tr_number <= 6, "left", "right")) %>%
    group_by(feedback_group, period) %>%
    summarise(group_mean = mean(value, na.rm = TRUE), .groups = "drop")
  
  group_means_segment <- group_means_split %>%
    mutate(
      x_start = if_else(period == "left", 1, 7),
      x_end = if_else(period == "left", 6, 11)
    )
  
  # Plot  
  df_plot <- single_run_df %>%
    filter(str_starts(trwise_meanblocks, target_condition)) %>%
    filter(!is.na(value)) %>%
    mutate(tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$"))) # nimmt Nummer am Ende

  plot <- ggplot(data = df_plot, aes(x = tr_number, y = value, color = factor(feedback_group))) +
    stat_summary(
      fun.data = mean_cl_normal, geom = "ribbon", 
      aes(fill = factor(feedback_group), group = feedback_group), 
      alpha = 0.2, color = NA, show.legend = FALSE
      ) +
    stat_summary(fun = mean, geom = "line", aes(group = feedback_group), linewidth = 0.9) +
    geom_segment( data = group_means_segment, 
                  aes(x = x_start, xend = x_end, y = group_mean, yend = group_mean, 
                      color = factor(feedback_group)), linewidth = 1.6) +
    coord_cartesian(ylim = c(-0.15, 0.15)) +
    scale_x_continuous(breaks = 1:11, labels = 1:11) +
    scale_color_manual(values = c("1" = "lightblue",
                                  "2" = "lightsalmon",
                                  "3" = "grey"),
                       labels = c("Reward", "Punishment", "Control")) +
    scale_fill_manual(values = c("1" = "lightblue",
                                 "2" = "lightsalmon",
                                 "3" = "grey")) +
    labs(
      x = "TR",
      y = "Signal difference (%)",
      title = plot_title,
      color = "Group",
      linetype = "Period"
    ) +
    theme_minimal() +
    geom_vline(xintercept = 6.5, linewidth = 0.8, linetype= "dashed", color = "darkgrey")

  print(plot)
  pdf_save_path = paste0("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/mask_plots_blockwise_scalingmode_4_mask_statsbasedSNVTA_mali/", pdf_title, ".pdf")
  ggsave(pdf_save_path, plot = plot, width = 6, height = 4, dpi = 300)

  # Significance test
  # ANOVA
  cat("\nANALYSIS:", plot_title, "\n")
  
  anova_data <- single_run_df %>%
    filter(str_starts(trwise_meanblocks, target_condition)) %>%
    filter(!is.na(value)) %>%
    mutate(
      tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$")),
      period = if_else(tr_number <= 6, "early", "late")
    ) %>%
    group_by(subject, feedback_group, period) %>%
    summarise(mean_value = mean(value, na.rm = TRUE), .groups = "drop")
  
  anova_repeated_measures <- anova_data %>%
    anova_test(dv = mean_value, wid = subject,
               within = period, between = feedback_group)
  
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
  # rest_means <- single_run_df %>%
  #   filter(str_starts(trwise_meanblocks, "rest_")) %>%
  #   group_by(subject) %>%
  #   summarise(rest_mean = mean(value, na.rm = TRUE), .groups = "drop")
  # 
  # # UP-rest & down-rest neue Variable (oder REST-DOWN)
  # if (rest_minus_down) {
  # 
  #   single_run_df_new <- single_run_df %>%
  #     left_join(rest_means, by = "subject") %>%
  #     mutate(rest_corrected_value = rest_mean - value) %>%
  #     filter(str_starts(trwise_meanblocks, target_condition))
  #   
  # } else {
  #   single_run_df_new <- single_run_df %>%
  #     left_join(rest_means, by = "subject") %>%
  #     mutate(rest_corrected_value = value - rest_mean) %>%
  #     filter(str_starts(trwise_meanblocks, target_condition))
  # }
  
  # Mittelwert über alle Trainingsruns hinweg 
  trainingrun_mean <- single_run_df %>%
    group_by(subject, feedback_group, trwise_meanblocks) %>%
    summarise(
      individual_trainingrun_mean = mean(value, na.rm = TRUE),
      .groups = "drop"
    )
  

  
  # Plot  
  df_plot <- trainingrun_mean %>%
    filter(str_starts(trwise_meanblocks, target_condition)) %>%
    filter(!is.na(individual_trainingrun_mean)) %>%
    mutate(tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$"))) # nimmt Nummer am Ende
  
  # Gruppenmittelwerte halbieren & segmentieren
  group_means_segment <- df_plot %>%
    mutate(period = if_else(tr_number <= 6, "left", "right")) %>%
    group_by(feedback_group, period) %>%
    summarise(group_mean = mean(individual_trainingrun_mean, na.rm = TRUE), .groups = "drop") %>%
    mutate(
      x_start = if_else(period == "left", 1, 7),
      x_end = if_else(period == "left", 6, 11)
    ) 
  
  plot <- ggplot(data = df_plot, 
                 aes(x = tr_number, 
                     y = individual_trainingrun_mean, 
                     color = factor(feedback_group))) +
  stat_summary(
    fun.data = mean_cl_normal, 
    geom = "ribbon", 
    aes(fill = factor(feedback_group), group = feedback_group), 
    alpha = 0.2, color = NA, show.legend = FALSE
  ) +
  stat_summary(fun = mean, geom = "line", 
               aes(group = feedback_group), 
               linewidth = 0.9) +
  geom_segment(data = group_means_segment, 
                aes(x = x_start, xend = x_end, 
                    y = group_mean, yend = group_mean, 
                    color = factor(feedback_group)), 
                linewidth = 2) +
  #coord_cartesian(ylim = c(-0.1, 0.1)) +
  scale_x_continuous(breaks = 1:11, labels = 1:11) +
  scale_color_manual(
    values = c("1" = "lightblue",
               "2" = "lightsalmon",
               "3" = "grey"),
    labels = c("Reward", "Punishment", "Control")
  ) +
  scale_fill_manual(
    values = c("1" = "lightblue",
               "2" = "lightsalmon",
               "3" = "grey")
  ) +
  labs(
    x = "TR",
    y = "Signal difference (%)",
    title = plot_title,
    color = "Group",
    linetype = "Period"
  ) +
  theme_minimal() +
  geom_vline(xintercept = 6.5, linewidth = 0.8, linetype= "dashed", color = "grey")
  
  print(plot)
  pdf_save_path = paste0("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/mask_plots_blockwise_scalingmode_4_mask_statsbasedSNVTA_mali/", pdf_title, ".pdf")
  ggsave(pdf_save_path, plot = plot, width = 6, height = 4, dpi = 300)

  # Significance test
  # ANOVA
  cat("\nANALYSIS:", plot_title, "\n")
  
  anova_data <- trainingrun_mean %>%
    filter(str_detect(trwise_meanblocks, target_condition)) %>%
    mutate(
      tr_number = as.integer(str_extract(trwise_meanblocks, "\\d+$")),
      period = if_else(tr_number <= 6, "early", "late")
    ) %>%
    group_by(subject, feedback_group, period) %>%
    summarise(mean_value = mean(individual_trainingrun_mean, na.rm = TRUE), .groups = "drop") %>%
    mutate(
      subject = as.factor(subject),
      feedback_group = as.factor(feedback_group),
      period = factor(period, levels = c("early","late"))
    )

  anova_repeated_measures <- anova_data %>%
    anova_test(
      dv = mean_value, wid = subject,
      within = period, between = feedback_group,
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


