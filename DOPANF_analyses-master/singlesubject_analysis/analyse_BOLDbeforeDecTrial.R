library(car)
library(rstudioapi)
library(dplyr)
library(tidyselect)
library(rjson)
#library(validate)
#library(testit)
#library(stringr)
#library(rlang)
#library(tidyverse)
library(gdata)
library(readr)
library(ggplot2)

rm(list=ls())
# getting the path of this script
current_path <- getActiveDocumentContext()$path 
# set the working directory to the path of this script:
setwd(dirname(current_path ))

# PATH: /Volumes/JustData/test_data/DOPANF/sub-45496/ses-27322/BEH
path_to_participants_file <- file.path("/Volumes/JustData/test_data/DOPANF/sub-45496/ses-2/BEH")
path_to_func_file <- file.path("/Volumes/JustData/test_data/DOPANF/sub-45496/ses-2/func")
#path_to_participants_file <- file.path("/Volumes/JustData/test_data/DOPANF/sub-45298/ses-2/BEH")
#path_to_func_file <- file.path("/Volumes/JustData/test_data/DOPANF/sub-45298/ses-2/func")

#FOR ALL RUNS:
# load taskResults - Decision
#SNS_MRI_DOPANF_S12653_02_run-01_tasklogs_beh_task-NFAdapt.csv
decisions_run1_raw<- read.csv(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S12653_02_run-01_taskResults_task-NFAdapt.csv"), header = TRUE, sep = ";")
#decisions_run1_raw<- read.csv(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S68453_02_run-01_taskResults_task-NFAdapt.csv"), header = TRUE, sep = ";")
decisions_run1_UP<-decisions_run1_raw[which(decisions_run1_raw$up_1_down_0==1),]
decisions_run1_DOWN<-decisions_run1_raw[which(decisions_run1_raw$up_1_down_0==0),]
decisions_run1 <- bind_rows(decisions_run1_UP, decisions_run1_DOWN)
decisions_run2_raw<- read.csv(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S12653_02_run-02_taskResults_task-NFAdapt.csv"), header = TRUE, sep = ";")
#decisions_run2_raw<- read.csv(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S68453_02_run-02_taskResults_task-NFAdapt.csv"), header = TRUE, sep = ";")
decisions_run2_UP<-decisions_run2_raw[which(decisions_run2_raw$up_1_down_0==1),]
decisions_run2_DOWN<-decisions_run2_raw[which(decisions_run2_raw$up_1_down_0==0),]
decisions_run2 <- bind_rows(decisions_run2_UP, decisions_run2_DOWN)
decisions_run3_raw<- read.csv(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S12653_02_run-03_taskResults_task-NFAdapt.csv"), header = TRUE, sep = ";")
#decisions_run3_raw<- read.csv(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S68453_02_run-03_taskResults_task-NFAdapt.csv"), header = TRUE, sep = ";")
decisions_run3_UP<-decisions_run3_raw[which(decisions_run3_raw$up_1_down_0==1),]
decisions_run3_DOWN<-decisions_run3_raw[which(decisions_run3_raw$up_1_down_0==0),]
decisions_run3 <- bind_rows(decisions_run3_UP, decisions_run3_DOWN)
decisions <- bind_rows(decisions_run1, decisions_run2, decisions_run3)
decisions_UP <- decisions[which(decisions$up_1_down_0==1),]
decisions_DOWN <- decisions[which(decisions$up_1_down_0==0),]

# load condsonoff -  get TR per Onset
#SNS_MRI_DOPANF_S12653_02_run-01_condsOnOff_beh_task-NFAdapt.json
condsOnset_input_run1 <- fromJSON(file = file.path(path_to_participants_file,"SNS_MRI_DOPANF_S12653_02_run-01_condsOnOff_beh_task-NFAdapt.json"))
condsOnset_input_run2 <- fromJSON(file = file.path(path_to_participants_file,"SNS_MRI_DOPANF_S12653_02_run-02_condsOnOff_beh_task-NFAdapt.json"))
condsOnset_input_run3 <- fromJSON(file = file.path(path_to_participants_file,"SNS_MRI_DOPANF_S12653_02_run-03_condsOnOff_beh_task-NFAdapt.json"))
#condsOnset_input_run1 <- fromJSON(file = file.path(path_to_participants_file,"SNS_MRI_DOPANF_S68453_02_run-01_condsOnOff_beh_task-NFAdapt.json"))
#condsOnset_input_run2 <- fromJSON(file = file.path(path_to_participants_file,"SNS_MRI_DOPANF_S68453_02_run-02_condsOnOff_beh_task-NFAdapt.json"))
#condsOnset_input_run3 <- fromJSON(file = file.path(path_to_participants_file,"SNS_MRI_DOPANF_S68453_02_run-03_condsOnOff_beh_task-NFAdapt.json"))

condsOnset_Reg_run1 <- data.frame(UP=condsOnset_input_run1$NFup, DOWN=condsOnset_input_run1$NFdown)
condsOnset_Reg_run1 <- do.call(rbind, condsOnset_Reg_run1)
condsOnset_Reg_run2 <- data.frame(UP=condsOnset_input_run2$NFup, DOWN=condsOnset_input_run2$NFdown)
condsOnset_Reg_run2 <- do.call(rbind, condsOnset_Reg_run2)
condsOnset_Reg_run3 <- data.frame(UP=condsOnset_input_run3$NFup, DOWN=condsOnset_input_run3$NFdown)
condsOnset_Reg_run3 <- do.call(rbind, condsOnset_Reg_run3)
condsOnset_Reg <- do.call(rbind, list(condsOnset_Reg_run1, condsOnset_Reg_run2, condsOnset_Reg_run3))



#load conds_beh -> condition per TR
#SNS_MRI_DOPANF_S12653_02_run-01_conds_beh_task-NFAdapt.txt

condsTR_run1 <- read.table(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S12653_02_run-01_conds_beh_task-NFAdapt.txt"), header = FALSE, sep = ",")
#condsTR_run1 <- read.table(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S68453_02_run-01_conds_beh_task-NFAdapt.txt"), header = FALSE, sep = ",")
condsTR_run1 <- do.call(rbind, condsTR_run1)
condsTR_run2 <- read.table(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S12653_02_run-02_conds_beh_task-NFAdapt.txt"), header = FALSE, sep = ",")
#condsTR_run2 <- read.table(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S68453_02_run-02_conds_beh_task-NFAdapt.txt"), header = FALSE, sep = ",")
condsTR_run2 <- do.call(rbind, condsTR_run2)
condsTR_run3 <- read.table(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S12653_02_run-03_conds_beh_task-NFAdapt.txt"), header = FALSE, sep = ",")
#condsTR_run3 <- read.table(file.path(path_to_participants_file, "SNS_MRI_DOPANF_S68453_02_run-03_conds_beh_task-NFAdapt.txt"), header = FALSE, sep = ",")
condsTR_run3 <- do.call(rbind, condsTR_run3)
length(condsTR_run2) <- length(condsTR_run3)
length(condsTR_run1) <- length(condsTR_run3)
condsTR <- cbind(condsTR_run1, condsTR_run2, condsTR_run3)

# load extracted signal from SN/VTA
#sub-45496_ses-1_task-NFTraining_run-2_desc-wrapreproc_bold.nii
#extract_SN_run-1.csv
#extract_SN_run-2.csv
#extract_SN_run-3.csv
#extract_VTA_run-1.csv
#extract_VTA_run-2.csv
#extract_VTA_run-3.csv
# import dataframe
print("Importing Dataframe")
data_run1 <- read.csv(file.path(path_to_func_file, "extract_SN_run-1.csv"), header = FALSE, sep = ",")
data_run1 <- do.call(rbind, data_run1)
data_run2 <- read.csv(file.path(path_to_func_file, "extract_SN_run-2.csv"), header = FALSE, sep = ",")
data_run2 <- do.call(rbind, data_run2)
data_run3 <- read.csv(file.path(path_to_func_file, "extract_SN_run-3.csv"), header = FALSE, sep = ",")
data_run3 <- do.call(rbind, data_run3)
length(data_run1) <- length(data_run3)
length(data_run2) <- length(data_run3)
data <- cbind(data_run1, data_run2, data_run3)

# choice 0||1 x cond UP||DOWN and calc average
start_UP_effort<-mean(c(data[condsOnset_Reg_run1[c(decisions_run1$up_1_down_0==1 & decisions_run1$choice==1),1],1], data[condsOnset_Reg_run2[c(decisions_run1$up_1_down_0==1 & decisions_run2$choice==1),1],2],  data[condsOnset_Reg_run3[decisions_run1$up_1_down_0==1 & c(decisions_run3$choice==1),1],3]), na.rm=TRUE)
start_UP_noeffort<-mean(c(data[condsOnset_Reg_run1[c(decisions_run1$up_1_down_0==1 & decisions_run1$choice==0,1)],1], data[condsOnset_Reg_run2[c(decisions_run1$up_1_down_0==1 & decisions_run2$choice==0),1],2],  data[condsOnset_Reg_run3[c(decisions_run1$up_1_down_0==1 & decisions_run3$choice==0),1],3]), na.rm=TRUE)
stop_UP_effort<-mean(c(data[condsOnset_Reg_run1[c(decisions_run1$up_1_down_0==1 & decisions_run1$choice==1),1],2], data[condsOnset_Reg_run2[c(decisions_run1$up_1_down_0==1 & decisions_run2$choice==1),2],2],  data[condsOnset_Reg_run3[c(decisions_run1$up_1_down_0==1 & decisions_run3$choice==1),2],3]), na.rm=TRUE)
stop_UP_noeffort<-mean(c(data[condsOnset_Reg_run1[c(decisions_run1$up_1_down_0==1 & decisions_run1$choice==0,1)],2], data[condsOnset_Reg_run2[c(decisions_run1$up_1_down_0==1 & decisions_run2$choice==0),2],2],  data[condsOnset_Reg_run3[c(decisions_run1$up_1_down_0==1 & decisions_run3$choice==0),2],3]), na.rm=TRUE)
#stop_UP_effort<-mean(c(data[condsOnset_Reg[2,c(decisions_run1$choice==1)],1], data[condsOnset_Reg[6,c(decisions_run2$choice==1)],2],  data[condsOnset_Reg[10,c(decisions_run3$choice==1)],3]), na.rm=TRUE)
#stop_UP_noeffort<-mean(c(data[condsOnset_Reg[2,c(decisions_run1$choice==0)],1], data[condsOnset_Reg[6,c(decisions_run2$choice==0)],2],  data[condsOnset_Reg[10,c(decisions_run3$choice==0)],3]), na.rm=TRUE)


#start_DOWN_effort<-mean(c(data[condsOnset_Reg[3,c(decisions_run1$choice==1)],1], data[condsOnset_Reg[7,c(decisions_run2$choice==1)],2],  data[condsOnset_Reg[11,c(decisions_run3$choice==1)],3]), na.rm=TRUE)
#start_DOWN_noeffort<-mean(c(data[condsOnset_Reg[3,c(decisions_run1$choice==0)],1], data[condsOnset_Reg[7,c(decisions_run2$choice==0)],2],  data[condsOnset_Reg[11,c(decisions_run3$choice==0)],3]), na.rm=TRUE)
#stop_DOWN_effort<-mean(c(data[condsOnset_Reg[4,c(decisions_run1$choice==1)],1], data[condsOnset_Reg[8,c(decisions_run2$choice==1)],2],  data[condsOnset_Reg[12,c(decisions_run3$choice==1)],3]), na.rm=TRUE)
#stop_DOWN_noeffort<-mean(c(data[condsOnset_Reg[4,c(decisions_run1$choice==0)],1], data[condsOnset_Reg[8,c(decisions_run2$choice==0)],2],  data[condsOnset_Reg[12,c(decisions_run3$choice==0)],3]), na.rm=TRUE)
start_DOWN_effort<-mean(c(data[condsOnset_Reg_run1[c(decisions_run1$up_1_down_0==0 & decisions_run1$choice==1),1],1], data[condsOnset_Reg_run2[c(decisions_run1$up_1_down_0==0 & decisions_run2$choice==1),1],2],  data[condsOnset_Reg_run3[decisions_run1$up_1_down_0==0 & c(decisions_run3$choice==1),1],3]), na.rm=TRUE)
start_DOWN_noeffort<-mean(c(data[condsOnset_Reg_run1[c(decisions_run1$up_1_down_0==0 & decisions_run1$choice==0,1)],1], data[condsOnset_Reg_run2[c(decisions_run1$up_1_down_0==0 & decisions_run2$choice==0),1],2],  data[condsOnset_Reg_run3[c(decisions_run1$up_1_down_0==0 & decisions_run3$choice==0),1],3]), na.rm=TRUE)
stop_DOWN_effort<-mean(c(data[condsOnset_Reg_run1[c(decisions_run1$up_1_down_0==0 & decisions_run1$choice==1),1],2], data[condsOnset_Reg_run2[c(decisions_run1$up_1_down_0==0 & decisions_run2$choice==1),2],2],  data[condsOnset_Reg_run3[c(decisions_run1$up_1_down_0==0 & decisions_run3$choice==1),2],3]), na.rm=TRUE)
stop_DOWN_noeffort<-mean(c(data[condsOnset_Reg_run1[c(decisions_run1$up_1_down_0==0 & decisions_run1$choice==0,1)],2], data[condsOnset_Reg_run2[c(decisions_run1$up_1_down_0==0 & decisions_run2$choice==0),2],2],  data[condsOnset_Reg_run3[c(decisions_run1$up_1_down_0==0 & decisions_run3$choice==0),2],3]), na.rm=TRUE)


new_data <- data.frame(x=c(1,2), UP_effort=c(start_UP_effort,stop_UP_effort), UP_noeffort=c(start_UP_noeffort,stop_UP_noeffort), DOWN_effort=c(start_DOWN_effort,stop_DOWN_effort), DOWN_noeffort=c(start_DOWN_noeffort,stop_DOWN_noeffort))

new_data %>% tidyr::gather("id", "value", 2:5) %>% 
  ggplot(., aes(x, value))+
  geom_point()+
  geom_smooth(method = "lm", se=FALSE, color="black")+
  facet_wrap(~id)
