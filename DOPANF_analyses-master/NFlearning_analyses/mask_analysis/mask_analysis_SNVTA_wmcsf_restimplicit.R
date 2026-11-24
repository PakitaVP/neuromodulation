main <- function() {
  
  library(dplyr)
  library(ggplot2)
  library(broom)
  library(tidyr)
  library(rlang)
  
  mask_file <- read.csv("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/extract_from_cons/con_extractions_probFconstatSNVTA_task-NFTraining_wmcsf_confounder_restimplicit_summary.csv")
  
  mean_variables <- c("mean_thresh05", "statistical_mean_q50")
  std_variables  <- c("std_thresh05", "statistical_std_q50")
  conditions <- c("UP", "DOWN", "UP-DOWN", "UP+DOWN")
  
  for (i in seq_along(mean_variables)) {
    mean_variable <- mean_variables[i]
    std_variable  <- std_variables[i] 
    
    for (condition in conditions) {
      run_TRBL_analysis("TR2-BL1", 1, 9, condition, mean_variable, std_variable, mask_file)
      run_TRBL_analysis("TR1-BL1", 1, 5, condition, mean_variable, std_variable, mask_file)
      run_TRBL_analysis("TR2-BL2", 6, 9, condition, mean_variable, std_variable, mask_file)
      run_TRBL_analysis("BL2-TR1", 5, 6, condition, mean_variable, std_variable, mask_file)
      run_TRBL_analysis("BL2-BL1", 1, 6, condition, mean_variable, std_variable, mask_file)
      
      trainingrun_analysis("over all trainingruns", c(2,3,4,7,8), "all", condition, mean_variable, std_variable, mask_file)
      trainingrun_analysis("on day 1", c(2,3,4), "day1", condition, mean_variable, std_variable, mask_file)
      trainingrun_analysis("on day 2", c(7,8), "day2", condition, mean_variable, std_variable, mask_file)
    }
  }
}



# TRBL Analysis (+ Consolidation)
run_TRBL_analysis <- function(title, run_number_a, run_number_b, target_condition, mean_variable, std_variable, mask_file) {
  
  full_title <- paste0(title, "_", target_condition)
  
  TR_BL_singlesubject_withgroup <- mask_file %>%
    group_by(subject) %>%
    filter(run %in% c(run_number_a, run_number_b) & condition == target_condition) %>% 
    ungroup() %>%
    select(all_of(c("subject", "feedback_group", mean_variable, std_variable, "run", "condition")))
  
  TR_BL_summary <- TR_BL_singlesubject_withgroup %>%
    pivot_wider(
      names_from = run,
      values_from = c(mean_variable, std_variable),
      names_glue = "{.value}_run{run}"
    ) %>%
    mutate(
      mean_TR_BL = !!sym(paste0(mean_variable, "_run", run_number_b)) - !!sym(paste0(mean_variable, "_run", run_number_a)),
      mean_std   = (!!sym(paste0(std_variable, "_run", run_number_b)) + !!sym(paste0(std_variable, "_run", run_number_a))) / 2 
    ) %>%
    select(subject, feedback_group, mean_TR_BL, mean_std)
  
  # Signifikanz prüfen
  significance_test <- pairwise.t.test(x = TR_BL_summary$mean_TR_BL,
                                     g = TR_BL_summary$feedback_group,
                                     p.adjust.method = "none")
  
  t_test_save_path <- "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/mask_analysis/t-tests_mask_analysis/"
  csv_save_path <- paste0(t_test_save_path, "t-test_results_wmcsf_restimplicit_probFconstatSNVTA_", mean_variable, "_", full_title, ".csv")
  
  pmat <- significance_test$p.value
  pmat[] <- pmin(pmax(pmat, 0), 1)
  utils::write.csv2(pmat, csv_save_path, row.names = TRUE)
  
  # Plot
  TR_BL_summary <- TR_BL_summary %>%
    mutate(feedback_group = factor(feedback_group,
                                   levels = c(1, 2, 3),
                                   labels = c("Reward", "Punishment", "Control")))
  
  barplot <- ggplot(TR_BL_summary, aes(x = feedback_group, y = mean_TR_BL)) +
    stat_summary(aes(fill = feedback_group),fun = mean, geom = "bar", width = 0.6) +
    stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2, linewidth = 0.5) +
    #geom_jitter(width = 0.1, size = 2, color = "black") +
    scale_fill_manual(values = c("Reward" = "lightblue", 
                                 "Punishment" = "lightsalmon", #tan1 #sandybrown
                                 "Control" = "grey")) +
    labs(
      #title = paste0("Group difference in mean SN/VTA activation (",title,") ", mean_variable, " ", target_condition),
      x = "Group",
      y = "SN/VTA Beta Estimates",
      fill = "Group"
    ) +
    theme_minimal() +
    theme(legend.position = "none") 
  # + coord_cartesian(ylim = c(-0.3, 0.3))
  
  pdf_title = paste0("SNVTA_", mean_variable, "_wmscf_restimplicit_probFconstatSNVTA_", full_title, ".pdf")
  save_plot(pdf_title, barplot) 
}

save_plot <- function(pdf_title, plot) {
  print(plot)
  save_prefix_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/mask_plots_restimplicit_probFconstatSNVTA/"
  save_path = paste0(save_prefix_path, pdf_title)
  pdf(save_path, width = 7, height = 5)
  print(plot)
  dev.off()
}




trainingrun_analysis <- function(title, trainingruns, pdf_title, target_condition, mean_variable, std_variable, mask_file) {
  
  full_title <- paste0(pdf_title, "_", target_condition)
  
  trainingruns_all_singlesubject_withgroup <- mask_file %>%
    group_by(subject) %>%
    filter(run %in% trainingruns & condition == target_condition) %>%
    ungroup() %>%
    select(all_of(c("subject", "feedback_group", mean_variable, std_variable, "run", "condition")))
  
  group_means <- trainingruns_all_singlesubject_withgroup %>%
    group_by(feedback_group, run) %>%
    summarise(
      mean = mean(!!sym(mean_variable), na.rm = TRUE),
      se = sd(!!sym(mean_variable), na.rm = TRUE) / sqrt(n()),
      #std  = mean(std_thresh05, na.rm = TRUE),  
      .groups = "drop"
    ) %>%
    mutate(ci = 1.96 * se)
  
  #Signifikanz prüfen
  if (title == "over all trainingruns") {
    significance_test <- trainingruns_all_singlesubject_withgroup %>%
      filter(run %in% trainingruns) %>%
      group_by(run) %>%
      summarise(
        result = list(
          pairwise.t.test(
            x = !!sym(mean_variable),
            g = feedback_group,
            p.adjust.method = "none"
          )
        ),
        .groups = "drop"
      ) %>%
      mutate(
        comparisons = purrr::map(result, ~ broom::tidy(.x))
      ) %>%
      select(run, comparisons) %>%
      tidyr::unnest(comparisons)


    t_test_save_path <- "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/mask_analysis/t-tests_mask_analysis/"
    csv_save_path <- paste0(t_test_save_path, "t-test_results_trainingruns_wmscf_restimplicit_probFconstatSNVTA_", mean_variable, "_", target_condition, ".csv")
    utils::write.csv2(significance_test, csv_save_path, row.names = FALSE)

  }
  
  # Plot
  runs <- sort(unique(c(trainingruns_all_singlesubject_withgroup$run, group_means$run)))
  
  lineplot <- ggplot() +
    # individual lines
    # geom_line(data = trainingruns_all_singlesubject_withgroup,
    #           aes(x = as.numeric(factor(run, levels = runs)),
    #               y = !!sym(mean_variable),
    #               group = subject,
    #               color = as.factor(feedback_group)),
    #           linewidth = 0.5, alpha = 0.4) +
    # group mean line
    geom_ribbon(data = group_means,
                aes(x = as.numeric(factor(run, levels = runs)),
                    ymin = mean - ci,
                    ymax = mean + ci,
                    fill = as.factor(feedback_group),
                    group = feedback_group),
                alpha = 0.2) +
    geom_line(data = group_means,
              aes(x = as.numeric(factor(run, levels = runs)),
                  y = mean,
                  color = as.factor(feedback_group),
                  group = feedback_group),
              linewidth = 1.5) +
    scale_fill_manual(values = c("powderblue", "peachpuff2", "grey85"),
                      labels = c("Reward", "Punishment", "Control")) +
    scale_color_manual(values = c("lightblue", "lightsalmon", "grey"),
                       labels = c("Reward", "Punishment", "Control")) +
    # show runs numbers
    scale_x_continuous(breaks = seq_along(runs), labels = runs,
                       expand = expansion(mult = c(0.02, 0.02))) +
    labs(
      #title = paste0("Mean SNVTA activation ", title, " ", mean_variable, " ", target_condition),
      x = "Run", 
      y = "SN/VTA Beta Estimates", 
      color = "Group", 
      fill = "Group"
    ) +
    theme_minimal() 
    #+ coord_cartesian(ylim = c(-0.2, 0.25))
  
  print(lineplot)


  pdf_title = paste0("SNVTA_", mean_variable, "_trainingruns_wmscf_restimplicit_probFconstatSNVTA_", full_title, ".pdf")
  save_plot(pdf_title, lineplot)
}

main()

