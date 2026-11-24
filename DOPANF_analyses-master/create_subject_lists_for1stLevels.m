
clear all 

% 
addpath('utils');
current_OS = OS.MACOS;

% defintion of all variables and their translations - task names, etc.
path_to_table = '';
path_to_sequence_descr = '';
if (ismac == current_OS)
    path_to_data_availibility_file = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF/';
    path_to_decision_overview_file = '/Volumes/JustData-1/Projects/DOPANF/Data/BehavioralData/task_mentaleffortdiscounting_nback/data_qa/Kelly_added_files/data_cleaning/data';
    path_to_table = '/Volumes/JustData-1/Projects/DOPANF/Documents/Organisation';
    path_to_sequence_descr = '/Volumes/JustData-1/Projects/DOPANF/DataDescription';
    path_to_fmaps = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc/';
elseif (ispc == current_OS)
    path_to_data_availibility_file = 'Z:\Projects\DOPANF\Data\DOPANF\';
    path_to_decision_overview_file = 'Z:\Projects\DOPANF\Data\BehavioralData\task_mentaleffortdiscounting_nback\data_qa\Kelly_added_files\data_cleaning\data\';
    path_to_table = 'Z:\Projects\DOPANF\Documents\Organisation\';
    path_to_sequence_descr = 'Z:\Projects\DOPANF\DataDescription\';
    path_to_fmaps = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc\';
    path_to_qa = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-qc\';
end

Config = Configuration_renaming;
% list of subjects without onsets in indiff logfiles from config
% Config.subjects_onsets_from_DecMakBL_edfs

% read the participant table with overview 
table_particpants = readtable(fullfile(path_to_table, 'Participants.xlsx'),'Sheet','Participants', 'Format', 'auto');
table_particpants = renamevars(table_particpants,["attribute_1_SubjectID_", "Status_Note_Pilot_Study_in_Study_out_"],...
                    ["SubjectID", "Status"]);
                
% read the table with all IDS (BIDS and token) 
table_sequences = readtable(fullfile(path_to_sequence_descr, 'DOPANF_SequencesPerSubjectDescription.xlsx'),'Sheet','Tabelle1', 'Format', 'auto');
table_sequences = renamevars(table_sequences,["SubjID"],...
                    ["SubjectID"]);


% just take IDs from participants that are in
participants_studyin = table_particpants.SubjectID(find(strcmp('Study_in',table_particpants.Status)));

% data availibility from DOPANF folder
table_data_availibilty = readtable(fullfile(path_to_data_availibility_file, 'data_availibity.csv'));
% delete all entries that don't have any logfiles since that means there
% are no data available
table_data_availibilty(table_data_availibilty.et_logfile_available==0 & table_data_availibilty.indiff_logfile_available == 0 & table_data_availibilty.onset_logfile_available == 0 & table_data_availibilty.tasklog_logfile_available == 0,:) = [];

% behavioral overview from Kelly folder
table_decisions_overview = readtable(fullfile(path_to_decision_overview_file, 'data_all_choice_runs.csv'));

tasks = {'NFTraining','NFAdapt','DecMakBL'};
% for each subject
% for each session
% for each task
current_running_index = 0;
for indSubject = 1:length(participants_studyin)
    current_participant_tokenID = participants_studyin{indSubject};
    current_participant_bidsID = cell2mat(unique(table_sequences.BIDS_subID(find(strcmp(table_sequences.SubjectID, current_participant_tokenID)))));
    
    for indSession = 1:max(table_data_availibilty.session)
        for indTask = 1:length(tasks)
            
            current_task = tasks{indTask};
            current_nr_of_runs = length(find(table_data_availibilty.token_id == str2double(participants_studyin{indSubject}) & table_data_availibilty.session==indSession & strcmp(table_data_availibilty.task,tasks{indTask})));
            if (0 == current_nr_of_runs)
                continue;
            end
            current_running_index = current_running_index + 1;
            output_subjectID_token(current_running_index) = str2double(current_participant_tokenID);
            output_subjectID_BIDS(current_running_index) = str2double(current_participant_bidsID);
            output_nr_of_runs(current_running_index) = current_nr_of_runs;
            output_day(current_running_index) = indSession;
            output_task_name{current_running_index} = current_task;
            output_feedback_group(current_running_index) = table_particpants(find(strcmp(table_particpants.SubjectID, current_participant_tokenID)),:).Feedbackgruppe_1Reward_2Punishment_3YokedControl_;
            output_regulation_group(current_running_index) = table_particpants(find(strcmp(table_particpants.SubjectID, current_participant_tokenID)),:).Regulationsgruppe_1_Cappuccino_2_Espresso_;
            output_gender(current_running_index) = table_particpants(find(strcmp(table_particpants.SubjectID, current_participant_tokenID)),:).Gender;
            
            current_table_decisions_entry = table_decisions_overview(find(table_decisions_overview.subjectID==str2double(current_participant_tokenID)),:);
            % choose from decisions
            if (1 == strcmp(tasks{indTask}, 'NFAdapt') || 1 == strcmp(tasks{indTask}, 'DecMakBL'))
                output_percent_dec_accept(current_running_index) = current_table_decisions_entry.ones*100;
                output_percent_dec_decline(current_running_index) = current_table_decisions_entry.zeros*100;
                output_percent_missing_responses(current_running_index) = current_table_decisions_entry.nas*100;
                % only defined by baseline decisions
                %output_percent_dec_accept(current_running_index) = ((current_table_decisions_entry.I1_ones + current_table_decisions_entry.I2_ones)/2)*100;
                %output_percent_dec_decline(current_running_index) = ((current_table_decisions_entry.I1_zeros + current_table_decisions_entry.I2_zeros)/2)*100;
                %output_percent_missing_responses(current_running_index) = ((current_table_decisions_entry.I1_nas + current_table_decisions_entry.I2_nas)/2)*100;
                
                output_nr_of_decision_trials(current_running_index) = current_table_decisions_entry.trials;
            else
                output_percent_dec_accept(current_running_index) = NaN;
                output_percent_dec_decline(current_running_index) = NaN;
                output_percent_missing_responses(current_running_index) = NaN;
                output_nr_of_decision_trials(current_running_index) = NaN;
            end
            
            if (1 == strcmp(tasks{indTask}, 'DecMakBL') && (any(strcmp(Config.subjects_onsets_from_DecMakBL_edfs, current_participant_bidsID))))
                % it's one of the exceptions, so let's check whether edf
                % file available, which causes availibility of onsets
                output_edf_files_available = [table_data_availibilty(find(table_data_availibilty.token_id == str2double(participants_studyin{indSubject}) & table_data_availibilty.session==indSession & strcmp(table_data_availibilty.task,tasks{indTask})),:).et_logfile_available];
                output_onset_files_available = [table_data_availibilty(find(table_data_availibilty.token_id == str2double(participants_studyin{indSubject}) & table_data_availibilty.session==indSession & strcmp(table_data_availibilty.task,tasks{indTask})),:).indiff_logfile_available];
                
                output_onsets_BLtask_available(1:current_nr_of_runs, current_running_index) = output_onset_files_available.*output_edf_files_available;
                %dirty hack since I don't know the final size of the array
                output_onsets_NFtask_available(:, current_running_index) = NaN;
            elseif (1 == strcmp(tasks{indTask}, 'DecMakBL') && (~any(strcmp(Config.subjects_onsets_from_DecMakBL_edfs, current_participant_bidsID))))
                output_onset_files_available = [table_data_availibilty(find(table_data_availibilty.token_id == str2double(participants_studyin{indSubject}) & table_data_availibilty.session==indSession & strcmp(table_data_availibilty.task,tasks{indTask})),:).indiff_logfile_available];
                output_onsets_BLtask_available(1:current_nr_of_runs, current_running_index) = output_onset_files_available;
                %dirty hack since I don't know the final size of the array
                output_onsets_NFtask_available(:, current_running_index) = NaN;
            elseif (1 == strcmp(tasks{indTask}, 'NFAdapt'))
                output_onset_files_available = [table_data_availibilty(find(table_data_availibilty.token_id == str2double(participants_studyin{indSubject}) & table_data_availibilty.session==indSession & strcmp(table_data_availibilty.task,tasks{indTask})),:).tasklog_logfile_available];
                %output_onsets_NFtask_available(1:current_nr_of_runs, 1:current_running_index) = 0;
                output_onsets_NFtask_available(1:current_nr_of_runs, current_running_index) = output_onset_files_available;
            %elseif (1 == strcmp(tasks{indTask}, 'NFTraining'))
                %                 output_onset_files_available = [table_data_availibilty(find(table_data_availibilty.token_id == str2double(participants_studyin{indSubject}) & table_data_availibilty.session==indSession & strcmp(table_data_availibilty.task,tasks{indTask})),:).onset_logfile_available];
                %                 output_onsets_BLtask_available = output_onset_files_available;
            end
            
            % all fieldmaps available?
            if (1 == strcmp(tasks{indTask}, 'DecMakBL') && (any(strcmp(Config.subjects_fieldmaps_for_DecMakBL_missing, current_participant_bidsID))))
                output_fieldmap_files_available(1:current_nr_of_runs, current_running_index) = 0;
            else
                output_fieldmap_files_available(1:current_nr_of_runs, current_running_index) = 1;
            end
            
            % Load moco files for each run, calc percentage of motion scans
            for indRun = 1:current_nr_of_runs
                if (1 == strcmp(tasks{indTask}, 'DecMakBL'))
                    % exception
                    if (strcmp(current_participant_bidsID, '45671') || strcmp(current_participant_bidsID, '44052') && 2 == indSession)
                        output_percent_motion(indRun, current_running_index) = NaN;
                        continue;
                    end
                    fd_file = readtable(fullfile(path_to_fmaps, ['sub-' current_participant_bidsID],['ses-' num2str(indSession)], 'func', ['sub-' current_participant_bidsID '_ses-' num2str(indSession) '_task-BLTask_run-' num2str(indRun) '_desc-confounds_fd.tsv' ]), 'FileType','text');
                    output_percent_motion(indRun, current_running_index) = sum(fd_file.framewise_displacement_censor05)/length(fd_file.framewise_displacement_censor05)*100;
                    snr_file = readtable(fullfile(path_to_qa, ['sub-' current_participant_bidsID],['ses-' num2str(indSession)], 'func', ['sub-' current_participant_bidsID '_ses-' num2str(indSession) '_task-NFTraining_run-' num2str(indRun) '_desc-stats_summary.tsv' ]), 'FileType','text');
                    output_snr_gm(indRun, current_running_index) = snr_file.tSNR_mean_GM;
                    output_snr_wm(indRun, current_running_index) = snr_file.tSNR_mean_WM;
                    output_snr_csf(indRun, current_running_index) = snr_file.tSNR_mean_CSF;
                    output_snr_brain(indRun, current_running_index) = snr_file.tSNR_mean_brain;
                elseif (1 == strcmp(tasks{indTask}, 'NFAdapt'))
                    % exception
                    fd_file = readtable(fullfile(path_to_fmaps, ['sub-' current_participant_bidsID],['ses-' num2str(indSession)], 'func', ['sub-' current_participant_bidsID '_ses-' num2str(indSession) '_task-NFTask_run-' num2str(indRun) '_desc-confounds_fd.tsv' ]), 'FileType','text');
                    output_percent_motion(indRun, current_running_index) = sum(fd_file.framewise_displacement_censor05)/length(fd_file.framewise_displacement_censor05)*100;
                    snr_file = readtable(fullfile(path_to_qa, ['sub-' current_participant_bidsID],['ses-' num2str(indSession)], 'func', ['sub-' current_participant_bidsID '_ses-' num2str(indSession) '_task-NFTraining_run-' num2str(indRun) '_desc-stats_summary.tsv' ]), 'FileType','text');
                    output_snr_gm(indRun, current_running_index) = snr_file.tSNR_mean_GM;
                    output_snr_wm(indRun, current_running_index) = snr_file.tSNR_mean_WM;
                    output_snr_csf(indRun, current_running_index) = snr_file.tSNR_mean_CSF;
                    output_snr_brain(indRun, current_running_index) = snr_file.tSNR_mean_brain;
                elseif (1 == strcmp(tasks{indTask}, 'NFTraining'))
                    if (strcmp(current_participant_bidsID, '45622') || strcmp(current_participant_bidsID, '38023'))
                        output_percent_motion(indRun, current_running_index) = NaN;
                        continue;
                    end
                    fd_file = readtable(fullfile(path_to_fmaps, ['sub-' current_participant_bidsID],['ses-' num2str(indSession)], 'func', ['sub-' current_participant_bidsID '_ses-' num2str(indSession) '_task-NFTraining_run-' num2str(indRun) '_desc-confounds_fd.tsv' ]), 'FileType','text');
                    output_percent_motion(indRun, current_running_index) = sum(fd_file.framewise_displacement_censor05)/length(fd_file.framewise_displacement_censor05)*100;
                    snr_file = readtable(fullfile(path_to_qa, ['sub-' current_participant_bidsID],['ses-' num2str(indSession)], 'func', ['sub-' current_participant_bidsID '_ses-' num2str(indSession) '_task-NFTraining_run-' num2str(indRun) '_desc-stats_summary.tsv' ]), 'FileType','text');
                    output_snr_gm(indRun, current_running_index) = snr_file.tSNR_mean_GM;
                    output_snr_wm(indRun, current_running_index) = snr_file.tSNR_mean_WM;
                    output_snr_csf(indRun, current_running_index) = snr_file.tSNR_mean_CSF;
                    output_snr_brain(indRun, current_running_index) = snr_file.tSNR_mean_brain;
                end
                
            end
        end
    end
end

% create a table from all these variables
headers_output_table = {'subjectID_BIDS', 'subjectID_token', 'feedback_group', 'regulation_group', 'task_name', 'nr_of_runs', 'nr_of_decision_trials', 'day', 'BLTask_onsets_available', 'NFTask_onsets_available', 'all_fieldmaps_available', 'percent_missing_responses', 'percent_dec_accept', 'percent_dec_decline', 'percent_motion_FDs', 'tSNR_GM', 'tSNR_WM', 'tSNR_CSF', 'tSNR_brain'};
%, 
output_table = table(output_subjectID_BIDS.', output_subjectID_token.', output_feedback_group.', output_regulation_group.', ...
                     output_task_name.', output_nr_of_runs.', output_nr_of_decision_trials.', output_day.', output_onsets_BLtask_available.', ...
                     output_onsets_NFtask_available.', output_fieldmap_files_available.', output_percent_missing_responses.', ...
                     output_percent_dec_accept.', output_percent_dec_decline.', output_percent_motion.',...
                     output_snr_gm.', output_snr_wm.', output_snr_csf.', output_snr_brain.', 'VariableNames', headers_output_table);
                 %
output_table.task_name(strcmp(output_table.task_name, 'NFAdapt')) = {'NFTask'};
output_table.task_name(strcmp(output_table.task_name, 'DecMakBL')) = {'BLTask'};

% and now define the criteria to choose the subjects from
% output_table.task_name=='NFTraining'
% for all days
%     for all_runs
%         output_table.all_fieldmaps_available == 1
%         output_table.percent_motion_FDs < 10

%% NFTask subjects

table_to_save = output_table(strcmp(output_table.task_name, 'NFTask') & output_table.percent_missing_responses < 10.0 & output_table.nr_of_decision_trials > 160 & output_table.percent_dec_accept <= 80.0 & output_table.percent_dec_decline <= 80.0,:);
entries_to_delete = [];
for indEntry = 1:height(table_to_save)
    if (0 == sum(table_to_save.NFTask_onsets_available(indEntry,:)))
        entries_to_delete = [entries_to_delete indEntry];
    end
end
table_to_save(entries_to_delete,:)=[];
writetable(table_to_save, 'NFTask_only_firstlevel_subjects.csv');

%% BLTask subjects
table_to_save = output_table(strcmp(output_table.task_name, 'BLTask') & output_table.percent_missing_responses < 10.0 & output_table.nr_of_decision_trials > 120 & output_table.percent_dec_accept <= 80.0 & output_table.percent_dec_decline <= 80.0,:);
entries_to_delete = [];
for indEntry = 1:height(table_to_save)
    if (0 == sum(table_to_save.BLTask_onsets_available(indEntry,:)))
        entries_to_delete = [entries_to_delete indEntry];
    end
end
table_to_save(entries_to_delete,:)=[];
writetable(table_to_save, 'BLTask_only_firstlevel_subjects.csv');

%% BLTask subjects
table_to_save = output_table(strcmp(output_table.task_name, 'BLTask') & output_table.percent_missing_responses < 10.0 & output_table.nr_of_decision_trials > 120 & output_table.percent_dec_accept <= 100.0 & output_table.percent_dec_decline <= 100.0,:);
entries_to_delete = [];
for indEntry = 1:height(table_to_save)
    if (0 == sum(table_to_save.BLTask_onsets_available(indEntry,:)))
        entries_to_delete = [entries_to_delete indEntry];
    end
end
table_to_save(entries_to_delete,:)=[];
writetable(table_to_save, 'All_subjects.csv');

%% NFTraining subjects
table_to_save = output_table(strcmp(output_table.task_name, 'NFTraining'),:);
%entries_to_delete = [];
%for indEntry = 1:height(table_to_save)
 %   if (0 == sum(table_to_save.BLTask_onsets_available(indEntry,:)))
  %      entries_to_delete = [entries_to_delete indEntry];
   % end
%end
%table_to_save(entries_to_delete,:)=[];
writetable(table_to_save, 'NFTraining_only_firstlevel_subjects.csv');

% output_table.task_name=='NFTask'
% for all days
%     for all runs
%         output_table.nr_of_decision_trials > 
%         output_table.NFTask_onsets_available ==1
%         output_table.all_fieldmaps_available
%         output_table.percent_missing_responses  
%         output_table.percent_dec_accept
%         output_table.percent_dec_decline
%         output_table.percent_motion_FDs
%         
% output_table.task_name=='BLTask'
% for all days
%     for all runs
%         output_table.nr_of_decision_trials > 
%         output_table.BLTask_onsets_available == 1
%         output_table.all_fieldmaps_available
%         output_table.percent_missing_responses  
%         output_table.percent_dec_accept
%         output_table.percent_dec_decline
%         output_table.percent_motion_FDs
%
