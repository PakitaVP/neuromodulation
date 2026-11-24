library(rstudioapi)
library(dplyr)
library(tidyselect)
library(rlang)
library(tidyverse)
library(gdata)
library(readxl)




rm(list = ls())
# getting the path of this script
current_path <- getActiveDocumentContext()$path
# set the working directory to the path of this script:
setwd(dirname(current_path))

# collect all paths to run the recoding
path_to_log_files <- file.path("Z:/Projects/DOPANF/Data/DOPANF_QA")
path_to_participants_file <- file.path("C:/Development/DOPANF_analyses")
path_to_output <- file.path("Z:/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc")

# check if data path available
if (FALSE == dir.exists(path_to_log_files)) {
  stop(
    "The path to the data does not exists. If it's on a network drive, check connection! Script stops now."
  )
}
if (FALSE == dir.exists(path_to_participants_file)) {
  stop(
    "The path to the participants file does not exists. If it's on a network drive, check connection! Script stops now."
  )
}

# read participants file
participants_filename <- file.path(path_to_participants_file,
                                   "NFTask_only_firstlevel_subjects.csv")
#check whether files exists

#read participants file
data_participants <- read.csv(
  participants_filename,
  header = TRUE,
  dec = ".",
  sep = ","
)

# overall participants
#sub-30823\ses-2\beh
# over all runs
#run 1 bis 3

for (sub in data_participants$subjectID_BIDS) {
  for (indRun in 1:3) {
    na.pad <- function(x, len) {
      x[1:len]
    }
    
    makePaddedDataFrame <- function(l, ...) {
      maxlen <- max(sapply(l, length))
      data.frame(lapply(l, na.pad, len = maxlen), ...)
    }
    
    print(sub, indRun)
    subject_path <- file.path(path_to_log_files, paste0("sub-", sub), "ses-2", "beh")
    
    tasklog_filename <- list.files(path = subject_path,
                                   pattern = paste0("run-", indRun, "_tasklogs"))
    
    taskresult_filename <- list.files(
      path = subject_path,
      pattern = paste0("run-", indRun, "_taskResults_task-NFAdapt")
    )
    
    #TODO check whether files exists
    
    #load data
    data_tasklog <- read.csv(
      file.path(subject_path, tasklog_filename),
      header = TRUE,
      dec = ".",
      sep = ";"
    )
    data_taskresult <- read.csv(
      file.path(subject_path, taskresult_filename),
      header = TRUE,
      dec = ".",
      sep = ";"
    )
    
    # tasklog$feedback == pmod
    #A) alle Werte vs B) >25 %
    # do mean correction
    
    onsets_dec_trials_accepted_all <- data_tasklog$volNrFirstTask[which(data_taskresult$choice == 1)]
    onsets_dec_trials_rejected_all <- data_tasklog$volNrFirstTask[which(data_taskresult$choice == 0)]
    onsets_dec_trials_noresponse <- data_tasklog$volNrFirstTask[which(is.na(data_taskresult$choice))]
    onsets_dec_trials_accepted_above_25 <- data_tasklog$volNrFirstTask[which(data_taskresult$choice == 1 &
                                                                               data_tasklog$feedback > 14)]
    onsets_dec_trials_rejected_above_25 <- data_tasklog$volNrFirstTask[which(data_taskresult$choice == 0 &
                                                                               data_tasklog$feedback > 14)]
    onsets_dec_trials_rejected_below_25 <- data_tasklog$volNrFirstTask[which(data_taskresult$choice == 0 &
                                                                               data_tasklog$feedback <= -15)]
    onsets_dec_trials_accepted_below_25 <- data_tasklog$volNrFirstTask[which(data_taskresult$choice == 1 &
                                                                               data_tasklog$feedback <= -15)]
    onsets_dec_trials_accepted_above_0 <- data_tasklog$volNrFirstTask[which(data_taskresult$choice == 1 &
                                                                              data_tasklog$feedback > 0)]
    onsets_dec_trials_rejected_below_0 <- data_tasklog$volNrFirstTask[which(data_taskresult$choice == 0 &
                                                                              data_tasklog$feedback <= 0)]
    onsets_dec_trials_others <- data_tasklog$volNrFirstTask[which((data_taskresult$choice == 0 &
                                                                     data_tasklog$feedback > -14)
                                                                  |
                                                                    (data_taskresult$choice == 1 & data_tasklog$feedback < 14)
                                                                  |
                                                                    is.na(data_taskresult$choice)
    )]
    onsets_dec_trials_others2 <- data_tasklog$volNrFirstTask[which((data_tasklog$feedback > -14 &
                                                                      data_tasklog$feedback < 14)
                                                                   |
                                                                     is.na(data_taskresult$choice)
    )]
    onsets_dec_trials_regwrong <- data_tasklog$volNrFirstTask[which((data_taskresult$choice == 0 &
                                                                       data_tasklog$feedback > 0)
                                                                    |
                                                                      (data_taskresult$choice == 1 & data_tasklog$feedback < 0)
                                                                    |
                                                                      is.na(data_taskresult$choice)
    )]
    
    onset_frame <- makePaddedDataFrame(
      list(
        accepted_all = onsets_dec_trials_accepted_all,
        rejected_all = onsets_dec_trials_rejected_all,
        noresponse = onsets_dec_trials_noresponse,
        accepted_above_25 = onsets_dec_trials_accepted_above_25,
        rejected_above_25 = onsets_dec_trials_rejected_above_25,
        rejected_below_25 = onsets_dec_trials_rejected_below_25,
        accepted_below_25 = onsets_dec_trials_accepted_below_25,
        accepted_above_0 = onsets_dec_trials_accepted_above_0,
        rejected_below_0 = onsets_dec_trials_rejected_below_0,
        others = onsets_dec_trials_others,
        others2 = onsets_dec_trials_others2,
        others_regwrong = onsets_dec_trials_regwrong
      )
    )
    
    
    pmods_dec_trials_accepted_all <- round(data_tasklog$feedback[which(data_taskresult$choice == 1)] - mean(data_tasklog$feedback),
                                           digits = 0)
    pmods_dec_trials_rejected_all <- round(data_tasklog$feedback[which(data_taskresult$choice == 0)] - mean(data_tasklog$feedback),
                                           digits = 0)
    pmods_dec_trials_noresponse <- data_tasklog$feedback[which(is.na(data_taskresult$choice))]
    pmods_dec_trials_accepted_above_25 <- round(data_tasklog$feedback[which(data_taskresult$choice == 1
                                                                            &
                                                                              data_tasklog$feedback > 14)] - mean(data_tasklog$feedback),
                                                digits = 0)
    pmods_dec_trials_rejected_below_25 <- round(data_tasklog$feedback[which(data_taskresult$choice == 0
                                                                            &
                                                                              data_tasklog$feedback <= -15)] - mean(data_tasklog$feedback),
                                                digits = 0)
    pmods_dec_trials_accepted_above_0 <- round(data_tasklog$feedback[which(data_taskresult$choice == 1
                                                                           &
                                                                             data_tasklog$feedback > 0)] - mean(data_tasklog$feedback),
                                               digits = 0)
    pmods_dec_trials_rejected_below_0 <- round(data_tasklog$feedback[which(data_taskresult$choice == 0
                                                                           &
                                                                             data_tasklog$feedback <= 0)] - mean(data_tasklog$feedback),
                                               digits = 0)
    pmods_dec_trials_rejected_above_25 <- round(data_tasklog$feedback[which(data_taskresult$choice == 0
                                                                            &
                                                                              data_tasklog$feedback > 14)] - mean(data_tasklog$feedback),
                                                digits = 0)
    pmods_dec_trials_accepted_below_25 <- round(data_tasklog$feedback[which(data_taskresult$choice == 1
                                                                            &
                                                                              data_tasklog$feedback <= -15)] - mean(data_tasklog$feedback),
                                                digits = 0)
    pmods_dec_trials_others <- round(data_tasklog$feedback[which((data_taskresult$choice == 0
                                                                  &
                                                                    data_tasklog$feedback > -14)
                                                                 |
                                                                   (data_taskresult$choice == 1
                                                                    &
                                                                      data_tasklog$feedback < 14)
                                                                 |
                                                                   is.na(data_taskresult$choice)
    )] - mean(data_tasklog$feedback),
    digits = 0)
    pmods_dec_trials_others2 <- round(data_tasklog$feedback[which((data_tasklog$feedback > -14 &
                                                                     data_tasklog$feedback < 14)
                                                                  |
                                                                    is.na(data_taskresult$choice)
    )] - mean(data_tasklog$feedback),
    digits = 0)
    pmods_dec_trials_regwrong <- round(data_tasklog$feedback[which((data_taskresult$choice == 0
                                                                    &
                                                                      data_tasklog$feedback > 0)
                                                                   |
                                                                     (data_taskresult$choice == 1
                                                                      &
                                                                        data_tasklog$feedback < 0)
                                                                   |
                                                                     is.na(data_taskresult$choice)
    )] - mean(data_tasklog$feedback),
    digits = 0)
    
    pmod_frame <-  makePaddedDataFrame(
      list(
        accepted_all = pmods_dec_trials_accepted_all,
        rejected_all = pmods_dec_trials_rejected_all,
        noresponse = pmods_dec_trials_noresponse,
        accepted_above_25 = pmods_dec_trials_accepted_above_25,
        rejected_below_25 = pmods_dec_trials_rejected_below_25,
        rejected_above_25 = pmods_dec_trials_rejected_above_25,
        accepted_below_25 = pmods_dec_trials_accepted_below_25,
        accepted_above_0 = pmods_dec_trials_accepted_above_0,
        rejected_below_0 = pmods_dec_trials_rejected_below_0,
        others = pmods_dec_trials_others,
        others2 = pmods_dec_trials_others2,
        others_regwrong = pmods_dec_trials_regwrong
      )
    )
    
    out_fname_onset <- paste0("sub-",
                              sub,
                              "_session-2_task-NFTask_run-",
                              indRun,
                              "_desc-onsets",
                              ".csv")
    out_fname_pmods <- paste0("sub-",
                              sub,
                              "_session-2_task-NFTask_run-",
                              indRun,
                              "_desc-pmods",
                              ".csv")
    output_path_sub <- paste0(file.path(path_to_output, paste0("sub-", sub), "ses-2", "beh"))
    if (!dir.exists(output_path_sub)) {
      dir.create(output_path_sub)
    }
    
    
    
    write.csv(onset_frame,
              file.path(output_path_sub, out_fname_onset),
              row.names = TRUE)
    write.csv(pmod_frame,
              file.path(output_path_sub, out_fname_pmods),
              row.names = TRUE)
    
    
    # Define boolean regright for regulation conditions
    regright_upreg_block <- data_tasklog$feedback[data_tasklog$trial[which(data_tasklog$updown == 2)]] > 14
    regright_upreg_block[regright_upreg_block == "true"] <- 1
    
    regright_downreg_block <- data_tasklog$feedback[data_tasklog$trial[which(data_tasklog$updown == 4)]] < -14
    regright_downreg_block[regright_downreg_block == "true"] <- 1
    
    
    out_fname_regrightup <- paste0(
      "sub-",
      sub,
      "_session-2_task-NFTask_run-",
      indRun,
      "_desc-boolregrightup",
      ".csv"
    )
    
    write.csv(
      regright_upreg_block,
      file.path(output_path_sub, out_fname_regrightup),
      row.names = FALSE,
      col.names = FALSE
    )
    
    out_fname_regrightdown <- paste0(
      "sub-",
      sub,
      "_session-2_task-NFTask_run-",
      indRun,
      "_desc-boolregrightdown",
      ".csv"
    )
    
    write.csv(
      regright_downreg_block,
      file.path(output_path_sub, out_fname_regrightdown),
      row.names = FALSE,
      col.names = FALSE
    )
    
  }
}
