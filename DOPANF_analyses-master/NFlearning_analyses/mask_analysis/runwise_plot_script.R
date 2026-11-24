library(dplyr)
library(ggplot2)

mask_file <- read.csv("/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/extract_from_cons/con_extractions_statsbasedSNVTA_task-NFTraining_wmcsf_confounder_restimplicit_summary.csv")

mask_file_summary <- mask_file %>%
  filter(condition %in% c("UP", "DOWN")) %>%
  mutate(run = as.integer(run)) %>%
  group_by(feedback_group, condition, run) %>%
  summarise(
    mean_value = mean(mean_thresh05, na.rm = TRUE),
    se_value   = sd(mean_thresh05, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(
      group = factor(feedback_group,
                     levels = c(1, 2, 3),
                     labels = c("Reward", "Punishment", "Control")),
      cond_run = paste0(condition, "_", run, "_", group)
    )
    


group_levels <- c("Reward", "Punishment", "Control")
cond_run_levels <- unlist(lapply(group_levels, function(g) {
  c(paste0("UP_", 1:9, "_", g), paste0("DOWN_", 1:9, "_", g))
}))

mask_file_summary$cond_run <- factor(mask_file_summary$cond_run, levels = cond_run_levels)

x_labels <- rep(c(paste0(1:9), paste0(1:9)), times = length(group_levels))
# x_labels <- rep(c(paste0("UP", 1:9), paste0("DOWN", 1:9)), times = length(group_levels))

# wenn nur Zahlen 1,3,5,7,9 in der x-Achse stehen sollen (finde ich persönlich nicht schln, weil dann 9 & 1 direkt nebeneinander stehen)
# x_labels <- rep(c(1:9, 1:9), times = length(group_levels))
# x_labels <- ifelse(x_labels %% 2 == 1, x_labels, "")

#grey shading for DOWN runs
down_idx <- which(grepl("^DOWN_", levels(mask_file_summary$cond_run)))
blocks <- split(down_idx, cumsum(c(1, diff(down_idx) != 1)))
rect_df <- do.call(rbind, lapply(blocks, function(idx) {
  data.frame(
    xmin = min(idx) - 0.5,
    xmax = max(idx) + 0.5,
    ymin = -Inf,
    ymax = Inf
  )
}))

plot <- ggplot(mask_file_summary, aes(x = cond_run, y = mean_value, fill = group)) +
  geom_rect(
    data = rect_df,
    inherit.aes = FALSE,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    fill = "grey80", alpha = 0.35
  ) +
  geom_bar(stat = "identity", width = 0.8) +
  geom_errorbar(
    aes(ymin = mean_value - se_value, ymax = mean_value + se_value),
    width = 0.2
  ) +
  scale_fill_manual(
    name = "Group",
    values = c(
      "Reward" = "lightblue",
      "Punishment" = "lightsalmon",
      "Control" = "grey"
    )
  ) +
  scale_x_discrete(
    name = "Run",
    labels = x_labels
  ) +
  labs(y = "Beta Estimates") +
  theme_classic(base_size = 14) +
  theme(
    legend.position = "right",
    #axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  ) 
print(plot)
# save plot
# ggsave(
#   filename = "runwise_plot.pdf",
#   plot = plot,
#   path = "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/mask_analysis",
#   width = 10, height = 4
# )


# create CSV with all means and SEs
summary_table <- mask_file_summary %>%
  mutate(condition = factor(condition, levels = c("UP", "DOWN"))) %>%
  arrange(group, condition, run) %>%
  select(group, condition, run, mean_value, se_value) %>%
  mutate(
    mean_value = round(mean_value, 2),
    se_value = round(se_value, 2)
  )

print(summary_table, n = Inf)

# save CSV
# write.csv(
#   summary_table,
#   file = "/Users/malimaurer/Documents/Development/DOPANF_analyses/NFlearning_analyses/mask_analysis/runwise_means_ses.csv",
#   row.names = FALSE
# )

