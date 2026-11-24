
data_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc';
data_searchterm = '*_desc-swrapreproc_bold.nii';
output_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\timeseries_analysis';
data_bids_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA';
[current_path,~,~] = fileparts(mfilename('fullpath'));


% NFTraining NFTask or BLTask
current_task = 'NFTask';
current_task_acronym = '';
nr_of_sessions = 0;
nr_of_runs = 0;


[current_path,~,~] = fileparts(mfilename('fullpath'));
if (strcmp('NFTraining', current_task))
    nr_of_sessions = [1 2];
    nr_of_runs = [5 4];
    data_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc';
    data_searchterm = '*_desc-swrapreproc_bold.nii';
    output_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\timeseries_analysis';
    data_bids_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA';
    
    % subjects
    subjects_description = readtable(fullfile(current_path, '..', 'NFTraining_only_firstlevel_subjects.csv'), 'Delimiter',',','ReadVariableNames',true);
    subjects = subjects_description.subjectID_BIDS(1:2:end);
    group = subjects_description.feedback_group(1:2:end);
    current_task_acronym = 'NFTraining';
elseif (strcmp('NFTask', current_task))
    data_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc';
    data_searchterm = '*_desc-swrapreproc_bold.nii';
    output_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\timeseries_analysis';
    data_bids_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA';
    
    % subjects
    subjects_description = readtable(fullfile(current_path, '..', 'NFTask_only_firstlevel_subjects.csv'), 'Delimiter',',','ReadVariableNames',true);
    subjects = subjects_description.subjectID_BIDS(:);
    group = subjects_description.feedback_group(:);
    
    % design struct needed
    nr_of_sessions=2;
    nr_of_runs = 3;
    current_task_acronym = 'NFAdapt';
elseif (strcmp('BLTask', current_task))
    data_path = '';
    data_searchterm = '';
    output_path = '';
    
    % subjects
    subjects_description = readtable(fullfile(current_path, '..', 'BLTask_only_firstlevel_subjects.csv'), 'Delimiter',',','ReadVariableNames',true);
    subjects = subjects_description.subjectID_BIDS(:);
    group = subjects_description.feedback_group(:);
    % design struct needed
    nr_of_sessions=2;
    nr_of_runs = 2;
    current_task_acronym = 'DecMakBL';
end

% choose the current mask 
% 1 Adcock probSN mask
% 2 Adcock probVTA mask
% 3 both Adcock probSNVTA mask
mask_chosen = 3;
mask_path = '';
mask_filename = '';
mask_output_name = '';
if (1 == mask_chosen)
    mask_output_name = 'probSN';
elseif (2 == mask_chosen)
    mask_output_name = 'probVTA';
 elseif (3 == mask_chosen)
    mask_output_name = 'probSNVTA';
end


corr_values_trwise = [];
corr_values_blockwise = [];
percent_motion = [];
means_upvsbl = [];
stds_upvsbl = [];
means_downvsbl = [];
stds_downvsbl = [];
up_trwise_meanblock_transfer2 = [];
down_trwise_meanblock_transfer2 = [];
rest_trwise_meanblock_transfer2 = [];
up_trwise_meanblock_training = [];
down_trwise_meanblock_training = [];
rest_trwise_meanblock_training = [];
up_trwise_meanblock_baseline1 = [];
down_trwise_meanblock_baseline1 = [];
rest_trwise_meanblock_baseline1 = [];
% load summary file according to task and mask, results in
% variable output_blockwise
load(fullfile(output_path, ['blockwiseValues_' mask_output_name '_task-' current_task '_summary.mat']));
load(fullfile(output_path, ['trwiseValues' mask_output_name '_task-' current_task '_summary.mat']));


for indSubject = 1:numel(subjects)
    for indSession = 1:length(nr_of_sessions)
        current_session = nr_of_sessions(indSession);
        for indRun = 1:nr_of_runs(indSession)

            if (strcmp('NFTraining', current_task))
                current_run = nr_of_runs(1)*(indSession-1)+indRun;
            else
                current_run = indRun;
            end

            current_subject = ['sub_' mat2str(subjects(indSubject))];
            fprintf('Current subject: %s\n', current_subject);
            % correlate the feedback values that have been calculate during the online
            % experiment with the ones from preprocessed offline data (possible for different masks)
            % for NFTask, we compare values tr-wise and blockwise according
            % to task switch FB value based on last three TRs
            if (strcmp('NFTask', current_task))
                logfile_name = dir(fullfile(data_bids_path, ['sub-' mat2str(subjects(indSubject))], ['ses-' mat2str(current_session)], 'beh' ,['*_run-' mat2str(indRun) '_tasklogs_beh_task-' current_task_acronym '.csv']));
                tasklog = readtable(fullfile(logfile_name.folder, logfile_name.name));
                logfile_NF_name = dir(fullfile(data_bids_path, ['sub-' mat2str(subjects(indSubject))], ['ses-' mat2str(current_session)], 'beh' ,['*_run-' mat2str(indRun) '_NFBs_beh_task-' current_task_acronym '.mat']));
                NFvalues = load(fullfile(logfile_NF_name.folder, logfile_NF_name.name));
                corr_values_trwise(indSubject, current_run) = corr2(output_trwise.(current_subject)(current_run).offline_fb_values(1:length(NFvalues.vectNFBs)), NFvalues.vectNFBs);
                corr_values_blockwise(indSubject, current_run) = corr(reshape([output_blockwise.(current_subject)(current_run).up_fb_values; output_blockwise.(current_subject)(current_run).down_fb_values], [], 1)'.', tasklog.feedback(1:42));
            elseif (strcmp('NFTraining', current_task))
                
                logfile_NF_name = dir(fullfile(data_bids_path, ['sub-' mat2str(subjects(indSubject))], ['ses-' mat2str(current_session)], 'beh' ,['*_run-' mat2str(indRun) '_NFBs_beh_task-' current_task_acronym '.mat']));
                NFvalues = load(fullfile(logfile_NF_name.folder, logfile_NF_name.name));
                corr_values_trwise(indSubject, current_run) = corr2(output_trwise.(current_subject)(current_run).offline_fb_values(1:length(NFvalues.vectNFBs)), NFvalues.vectNFBs);
            end
            v = sprintf('percent_motion_FDs_%d', indRun);
            percent_motion(indSubject, current_run) = subjects_description.(v)(subjects_description.day==current_session & subjects_description.subjectID_BIDS == subjects(indSubject));
            % compare std between up and down
            means_upvsbl(indSubject, current_run) = mean(output_blockwise.(current_subject)(current_run).up_values_blockwise - mean(output_blockwise.(current_subject)(current_run).baseline_values_blockwise));
            stds_upvsbl(indSubject, current_run) = std(output_blockwise.(current_subject)(current_run).up_values_blockwise - mean(output_blockwise.(current_subject)(current_run).baseline_values_blockwise));
            means_downvsbl(indSubject, current_run) = mean(output_blockwise.(current_subject)(current_run).down_values_blockwise - mean(output_blockwise.(current_subject)(current_run).baseline_values_blockwise));
            stds_downvsbl(indSubject, current_run) = std(output_blockwise.(current_subject)(current_run).down_values_blockwise - mean(output_blockwise.(current_subject)(current_run).baseline_values_blockwise));

            if (strcmp('NFTraining', current_task))
                % tr-wise mean values per block over all subjects for block
                % splitting 
            
                up_trwise_meanblock_transfer2(indSubject, 1:11) = output_blockwise.(current_subject)(9).up_trwise_meanblocks;
                down_trwise_meanblock_transfer2(indSubject, 1:11) = output_blockwise.(current_subject)(9).down_trwise_meanblocks;
                rest_trwise_meanblock_transfer2(indSubject, 1:10) = output_blockwise.(current_subject)(9).rest_trwise_meanblocks;
 
                up_trwise_meanblock_training(indSubject, 1:11) = (output_blockwise.(current_subject)(2).up_trwise_meanblocks + output_blockwise.(current_subject)(3).up_trwise_meanblocks + output_blockwise.(current_subject)(4).up_trwise_meanblocks + output_blockwise.(current_subject)(7).up_trwise_meanblocks + output_blockwise.(current_subject)(8).up_trwise_meanblocks)/5;
                down_trwise_meanblock_training(indSubject, 1:11) = (output_blockwise.(current_subject)(2).down_trwise_meanblocks + output_blockwise.(current_subject)(3).down_trwise_meanblocks + output_blockwise.(current_subject)(4).down_trwise_meanblocks + output_blockwise.(current_subject)(7).down_trwise_meanblocks + output_blockwise.(current_subject)(8).down_trwise_meanblocks)/5;
                rest_trwise_meanblock_training(indSubject, 1:10) = (output_blockwise.(current_subject)(2).rest_trwise_meanblocks + output_blockwise.(current_subject)(3).rest_trwise_meanblocks + output_blockwise.(current_subject)(4).rest_trwise_meanblocks + output_blockwise.(current_subject)(7).rest_trwise_meanblocks + output_blockwise.(current_subject)(8).rest_trwise_meanblocks)/5;
            
                up_trwise_meanblock_baseline1(indSubject, 1:11) = NaN(1,11);
                down_trwise_meanblock_baseline1(indSubject, 1:11) = NaN(1,11);
                up_trwise_meanblock_baseline1(indSubject, 1:length(output_blockwise.(current_subject)(1).up_trwise_meanblocks)) = output_blockwise.(current_subject)(1).up_trwise_meanblocks;
                down_trwise_meanblock_baseline1(indSubject, 1:length(output_blockwise.(current_subject)(1).down_trwise_meanblocks)) = output_blockwise.(current_subject)(1).down_trwise_meanblocks;
                rest_trwise_meanblock_baseline1(indSubject, 1:10) = output_blockwise.(current_subject)(1).rest_trwise_meanblocks;
           end

        end
    end
end



clear output_blockwise;
% create correlation plot
figure;
bar(corr_values_trwise);
filename_fig = fullfile(output_path, sprintf('validation_correlation_trwise_online_offline_fbvalues_mask-%s_task-%s.png', mask_output_name, current_task));
if (strcmp('NFTraining', current_task))
    test = array2table(corr_values_trwise, 'VariableNames', {'run_1','run_2','run_3','run_4','run_5','run_6','run_7','run_8','run_9'});
elseif (strcmp('NFTask', current_task))
    test = array2table(corr_values_trwise, 'VariableNames', {'run_1','run_2','run_3'});
end
test.subject = subjects;
writetable(test, fullfile(output_path, sprintf('validation_correlation_trwise_online_offline_fbvalues_mask-%s_task-%s.csv', mask_output_name, current_task)))
saveas(gcf, filename_fig)
close
if (strcmp('NFTask', current_task))
    figure;
    bar(corr_values_blockwise);
    test = array2table(corr_values_blockwise, 'VariableNames', {'run_1','run_2','run_3'});
    test.subject = subjects;
    writetable(test, fullfile(output_path, sprintf('validation_correlation_blockwise_online_offline_fbvalues_mask-%s_task-%s.csv', mask_output_name, current_task)))
    filename_fig = fullfile(output_path, sprintf('validation_correlation_blockwise_online_offline_fbvalues_mask-%s_task-%s.png', mask_output_name, current_task));
    saveas(gcf, filename_fig)
    close
end
% check the correlation between motion and corr, look at identity values
corr(corr_values_trwise, percent_motion,'rows', 'complete')

figure
tiledlayout(2,2)
nexttile
bar(means_upvsbl);
title("Means up - rest")
nexttile
bar(means_downvsbl);
title("Means down - rest")
nexttile
bar(stds_upvsbl);
title("Stds up - rest")
nexttile
bar(stds_downvsbl);
title("Stds down - rest")
filename_fig = fullfile(output_path, sprintf('validation_means_stds_mask-%s_task-%s.png', mask_output_name, current_task));
saveas(gcf, filename_fig)
close

% block split 

% transfer_up_reward =  mean(up_trwise_meanblock_transfer2(find(group==1),:));
% transfer_down_reward = mean(down_trwise_meanblock_transfer2(find(group==1),:));
% transfer_up_pun =  mean(up_trwise_meanblock_transfer2(find(group==2),:));
% transfer_down_pun = mean(down_trwise_meanblock_transfer2(find(group==2),:));
% transfer_up_control =  mean(up_trwise_meanblock_transfer2(find(group==3),:));
% transfer_down_control = mean(down_trwise_meanblock_transfer2(find(group==3),:));
% 
% bl_up_reward =  mean(up_trwise_meanblock_baseline1(find(group==1),:));
% bl_down_reward = mean(down_trwise_meanblock_baseline1(find(group==1),:));
% bl_up_pun =  mean(up_trwise_meanblock_baseline1(find(group==2),:));
% bl_down_pun = mean(down_trwise_meanblock_baseline1(find(group==2),:));
% bl_up_control =  mean(up_trwise_meanblock_baseline1(find(group==3),:));
% bl_down_control = mean(down_trwise_meanblock_baseline1(find(group==3),:));
% 
% training_up_reward =  mean(up_trwise_meanblock_training(find(group==1),:));
% training_down_reward = mean(down_trwise_meanblock_training(find(group==1),:));
% training_up_pun =  mean(up_trwise_meanblock_training(find(group==2),:));
% training_down_pun = mean(down_trwise_meanblock_training(find(group==2),:));
% training_up_control =  mean(up_trwise_meanblock_training(find(group==3),:));
% training_down_control = mean(down_trwise_meanblock_training(find(group==3),:));
% 
% figure
% tiledlayout(3,2);
% plot(transfer_up_reward)
% hold on 
% plot(transfer_up_pun)
% hold on 
% plot(transfer_up_control)
% title("Transfer Upregulation")
% legend('Reward', 'Punishment', 'Control')
% hold off
% 
% figure
% plot(transfer_down_reward)
% hold on 
% plot(transfer_down_pun)
% hold on 
% plot(transfer_down_control)
% title("Transfer Downregulation")
% legend('Reward', 'Punishment', 'Control')
% hold off
% 
% figure
% plot(bl_up_reward)
% hold on 
% plot(bl_up_pun)
% hold on 
% plot(bl_up_control)
% title("Baseline Upregulation")
% legend('Reward', 'Punishment', 'Control')
% 
% figure
% plot(bl_down_reward)
% hold on 
% plot(bl_down_pun)
% hold on 
% plot(bl_down_control)
% title("Baseline Downregulation")
% legend('Reward', 'Punishment', 'Control')
% 
% figure
% plot(training_up_reward)
% hold on 
% plot(training_up_pun)
% hold on 
% plot(training_up_control)
% title("Training Upregulation")
% legend('Reward', 'Punishment', 'Control')
% 
% figure
% plot(training_down_reward)
% hold on 
% plot(training_down_pun)
% hold on 
% plot(training_down_control)
% title("Training Downregulation")
% legend('Reward', 'Punishment', 'Control')
% 
% 
% filename_fig = fullfile(output_path, sprintf('validation_trwise_blockaverage_mask-%s_task-%s.png', mask_output_name, current_task));
% saveas(gcf, filename_fig)
% close



