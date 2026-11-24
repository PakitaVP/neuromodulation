

close all;
clear all;
addpath('C:\Users\lhellr\Documents\MATLAB\Toolboxes\NIfTI_20140122\');

data_path = '';
data_searchterm = '';
nr_of_regulation_blocks = 9;
length_of_blocks = 10;

% HP filter params
TR = 2.000;
hpf_cutoffFreq = 1/128;
normFactor = 1/TR*0.5;
hrfDelay=3;
ORDER = 2; %  -- filer order another thing that's arbitrary.
[b,a] = butter(ORDER,hpf_cutoffFreq/normFactor,'high');

% NFTraining NFTask or BLTask
current_task = 'NFTraining';
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
    subjects_token = subjects_description.subjectID_token(1:2:end);
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
    subjects_token = subjects_description.subjectID_token(:);
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
    subjects_token = subjects_description.subjectID_token(:);
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
mask_chosen = 1;
mask_path = '';
mask_filename = '';
mask_output_name = '';
if (1 == mask_chosen)
    mask_path = 'Z:\Projects\DOPANF\Masks\DOPANF_Masks_analyses\SubstantiaNigra';
    mask_filename = 'rmean_SN.nii'; %
    mask_output_name = 'probSN';
elseif (2 == mask_chosen)
    mask_path = 'Z:\Projects\DOPANF\Masks\DOPANF_Masks_analyses\VTA';
    mask_filename = 'rmean_VTA.nii'; %rSN_1mm
    mask_output_name = 'probVTA';
 elseif (3 == mask_chosen)
    mask_path = 'Z:\Projects\DOPANF\Masks\DOPANF_Masks_analyses';
    mask_filename = 'rmask_probSNVTA.nii'; %
    mask_output_name = 'probSNVTA';
end

output_timecourse = struct();
output_blockwise = struct();
output_trwise = struct();
for indSubject = 1:numel(subjects)
    
    current_subject = ['sub_' mat2str(subjects(indSubject))];
    fprintf('Current subject: %d %s\n', indSubject, current_subject);
    % Maske MNI SPace
    mask_file = fullfile(mask_path, mask_filename);
    mask_data = load_nii(mask_file);
    % design struct needed but here it's individually defined, will be load
    % later
    
    
    for indSession = 1:length(nr_of_sessions)
        current_session = nr_of_sessions(indSession);

        for indRun = 1:nr_of_runs(indSession)

            if (strcmp('NFTraining', current_task))
                current_run = nr_of_runs(1)*(indSession-1)+indRun;
            else
                current_run = indRun;
            end
            file_path = dir(fullfile(data_path, ['sub-' mat2str(subjects(indSubject))], ['ses-' mat2str(current_session)], 'func',  ['*' current_task '_run-' mat2str(indRun) data_searchterm]));
            epi_data = load_nii(fullfile(file_path.folder, file_path.name));
        
            % mult epi * mask
            [mix,miy,miz]=ind2sub(size(mask_data.img),find(mask_data.img >= 0.5));
            mi=[mix,miy,miz];
            mask_voxels = [];
            for indInd=1:size(mi,1)
                mask_voxels(:,indInd) = double(squeeze(epi_data.img(mi(indInd,1),mi(indInd,2),mi(indInd,3),:)));
            end

            % average all voxels in left space for every timepoint -> timecourse
            timecourse = zeros(1,size(mask_voxels,1));
            for indT = 1:size(mask_voxels,1)
                timecourse(indT) = mean(mask_voxels(indT,:));
            end

            % filter timecourse
            mean_timecourse = mean(timecourse);
            timecourse_filtered=filtfilt(b,a, timecourse)+mean_timecourse;

            % scale timeseries according to online processing (scaleTimeSeries.m)
            sortTimeSeries = sort(timecourse_filtered);
            nrElem = round(0.05*length(sortTimeSeries));
            tmp_max = median(sortTimeSeries(end-nrElem:end));
            tmp_min = median(sortTimeSeries(1:nrElem+1));
            timecourse_scaled = (timecourse_filtered - tmp_min) / (tmp_max - tmp_min);

%             pl = plot(timecourse,'r');
%             hold on;
%             %
%             %
%             %
%             plot(timecourse_filtered,'b')
%             filename_fig = fullfile(output_path, 'timecourse_plots', sprintf('timecourse_mask-%s_sub-%d_ses-%d_task-%s_run-%d.png', mask_output_name, subjects(indSubject), current_session, current_task, indRun));
%             saveas(pl, filename_fig)
%             hold off;
%             clear pl;
            %pl = plot(timecourse_scaled,'r');
            %filename_fig = fullfile(output_path, 'timecourse_plots', sprintf('timecourse_scaled_mask-%s_sub-%d_ses-%d_task-%s_run-%d.png', mask_output_name, subjects(indSubject), current_session, current_task, indRun));
            %saveas(pl, filename_fig)
            %clear pl;



            output_timecourse.(current_subject)(current_run).timecourse = timecourse_filtered;
            output_timecourse.(current_subject)(current_run).timecourse_scaled = timecourse_scaled;
            output_timecourse.(current_subject)(current_run).run = current_run;
            output_timecourse.(current_subject)(current_run).feedback_group = group(indSubject);
            output_timecourse.(current_subject)(current_run).subject = subjects(indSubject);
            output_timecourse.(current_subject)(current_run).subject_token = subjects_token(indSubject);

            % now load on/offsets of conditions
            % load all params for conditions in 1st level analysis -
            % on/offsets and duration for all available conditions
            fname_conditions = dir(fullfile(data_bids_path, ['sub-' mat2str(subjects(indSubject))], ['ses-' mat2str(current_session)], 'beh' ,['*_run-' mat2str(indRun) '_condsOnOff_beh_task-' current_task_acronym '.json']));
            fid = fopen(fullfile(fname_conditions.folder, fname_conditions.name));
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);
            conditions_raw = jsondecode(str);
            inds_up =   [];
            inds_down = [];
            inds_rest = [];
            inds_fix = [];
            for indBlock = 1:length(conditions_raw.Bas)-1
                inds_up = [inds_up conditions_raw.NFup(indBlock,1):conditions_raw.NFup(indBlock,2)];
                inds_down = [inds_down conditions_raw.NFdown(indBlock,1):conditions_raw.NFdown(indBlock,2)];
                % last baseline block is only to finish last regulation
                % block, so we don't need it here
                inds_rest = [inds_rest conditions_raw.Bas(indBlock,1):conditions_raw.Bas(indBlock,2)];
                if (strcmp('NFTraining', current_task))
                    inds_fix = [inds_fix conditions_raw.Fix(indBlock,1):conditions_raw.Fix(indBlock,2)];
                end
                length_of_blocks_up = conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1;
                length_of_blocks_down = conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1;
                length_of_blocks_rest = conditions_raw.Bas(:,2)-conditions_raw.Bas(:,1)+1;
            end
            % add the last rest block separately
            inds_rest = [inds_rest conditions_raw.Bas(indBlock+1,1):conditions_raw.Bas(indBlock+1,2)];
            %
            %             % percent signal changes UP-DOWN per regulation
            %             % save it to a struct
            %
            percent_signal_change_blockwise = [];
            up_values_blockwise = [];
            down_values_blockwise = [];
            baseline_values_blockwise = [];
            up_fbvalues_blockwise = [];
            down_fbvalues_blockwise = [];
            up_fbramp_blockwise = [];
            down_fbramp_blockwise = [];
            
            % make an array for all TR values of 8 blocks of each run with
            % max length of 10 to collect for average
            up_trwise_meanblocks(1:length(length_of_blocks_up), 1:max(length_of_blocks_up)) = NaN(length(length_of_blocks_up),max(length_of_blocks_up));
            down_trwise_meanblocks(1:length(length_of_blocks_down), 1:max(length_of_blocks_down)) = NaN(length(length_of_blocks_down),max(length_of_blocks_down));
            rest_trwise_meanblocks(1:length(length_of_blocks_rest), 1:max(length_of_blocks_rest)) = NaN(length(length_of_blocks_rest),max(length_of_blocks_rest));
            up_trwise_meanrun = [];
            down_trwise_meanrun = [];
            rest_trwise_meanrun = [];

            current_start_ind_up = 1;
            current_start_ind_down = 1;
            current_start_ind_rest = 1;
            for indBlock = 1:length(conditions_raw.Bas)-1
                % inds_xxx is a vector, hrfDelay a scalar. the hrfDelay of 3 will
                % so be added to all indices.
                current_timecourse_up = timecourse_scaled(inds_up(current_start_ind_up:current_start_ind_up+length_of_blocks_up(indBlock)-1)); % + hrfDelay
                current_timecourse_down = timecourse_scaled(inds_down(current_start_ind_down:current_start_ind_down+length_of_blocks_down(indBlock)-1)); % + hrfDelay
                current_timecourse_rest = timecourse_scaled(inds_rest(current_start_ind_rest:current_start_ind_rest+length_of_blocks_rest(indBlock)-1)); % + hrfDelay
                    
                up_values_blockwise(indBlock) = mean(current_timecourse_up);
                down_values_blockwise(indBlock) = mean(current_timecourse_down);
                baseline_values_blockwise(indBlock) = mean(current_timecourse_rest);
                current_upvsdown_perc_signalchange(indBlock) = ((mean(current_timecourse_up)-mean(current_timecourse_down)) / mean(current_timecourse_rest)) *100;
                
                up_trwise_meanblocks(indBlock, 1:length(current_timecourse_up)) = current_timecourse_up;
                down_trwise_meanblocks(indBlock, 1:length(current_timecourse_down)) = current_timecourse_down;
                rest_trwise_meanblocks(indBlock, 1:length(current_timecourse_rest)) = current_timecourse_rest;

                %Calc feedback value from last three TRs of each
                %block, substract previous baseline and scale according to
                %online procedure nfbCalc.m
                current_up_fbvalue = (timecourse_scaled(inds_up(current_start_ind_up+length_of_blocks_up(indBlock)-1))*0.5 + timecourse_scaled(inds_up(current_start_ind_up+length_of_blocks_up(indBlock)-2))*0.25  + timecourse_scaled(inds_up(current_start_ind_up+length_of_blocks_up(indBlock)-3))*0.25);
                last_three = [timecourse_scaled(inds_up(current_start_ind_up+length_of_blocks_up(indBlock)-1)), timecourse_scaled(inds_up(current_start_ind_up+length_of_blocks_up(indBlock)-2)), timecourse_scaled(inds_up(current_start_ind_up+length_of_blocks_up(indBlock)-3))];
                fit_ramp = polyfit(1:3, last_three, 1);
                up_fbramp_blockwise(indBlock) = fit_ramp(2);
                current_down_fbvalue = (timecourse_scaled(inds_down(current_start_ind_down+length_of_blocks_down(indBlock)-1))*0.5 + timecourse_scaled(inds_down(current_start_ind_down+length_of_blocks_down(indBlock)-2))*0.25  + timecourse_scaled(inds_down(current_start_ind_down+length_of_blocks_down(indBlock)-3))*0.25);
                last_three = [timecourse_scaled(inds_down(current_start_ind_down+length_of_blocks_down(indBlock)-1)), timecourse_scaled(inds_down(current_start_ind_down+length_of_blocks_down(indBlock)-2)), timecourse_scaled(inds_down(current_start_ind_down+length_of_blocks_down(indBlock)-3))];
                fit_ramp = polyfit(1:3, last_three, 1);
                down_fbramp_blockwise(indBlock) = fit_ramp(2);
                if current_up_fbvalue>mean(current_timecourse_rest)
                    up_fbvalues_blockwise(indBlock) = (current_up_fbvalue - mean(current_timecourse_rest))/(1-mean(current_timecourse_rest));
                else
                    up_fbvalues_blockwise(indBlock) = (current_up_fbvalue - mean(current_timecourse_rest))/(mean(current_timecourse_rest));
                end
                if current_down_fbvalue>mean(current_timecourse_rest)
                    down_fbvalues_blockwise(indBlock) = (current_down_fbvalue - mean(current_timecourse_rest))/(1-mean(current_timecourse_rest));
                else
                    down_fbvalues_blockwise(indBlock) = (current_down_fbvalue - mean(current_timecourse_rest))/(mean(current_timecourse_rest));
                end
                current_start_ind_up = current_start_ind_up + length_of_blocks_up(indBlock);
                current_start_ind_down = current_start_ind_down + length_of_blocks_down(indBlock);
                current_start_ind_rest = current_start_ind_rest + length_of_blocks_rest(indBlock);
            end

            output_blockwise.(current_subject)(current_run).upvsdown_percent_signal_change = current_upvsdown_perc_signalchange;
            output_blockwise.(current_subject)(current_run).up_values_blockwise = up_values_blockwise;
            output_blockwise.(current_subject)(current_run).down_values_blockwise = down_values_blockwise;
            output_blockwise.(current_subject)(current_run).baseline_values_blockwise = baseline_values_blockwise;
            output_blockwise.(current_subject)(current_run).up_fb_values = up_fbvalues_blockwise*100;
            output_blockwise.(current_subject)(current_run).down_fb_values = down_fbvalues_blockwise*100;
            output_blockwise.(current_subject)(current_run).up_fbramp_values = up_fbramp_blockwise;
            output_blockwise.(current_subject)(current_run).down_fbramp_values = down_fbramp_blockwise;
            output_blockwise.(current_subject)(current_run).up_trwise_meanblocks = mean(up_trwise_meanblocks,'omitnan');
            output_blockwise.(current_subject)(current_run).down_trwise_meanblocks = mean(down_trwise_meanblocks,'omitnan');
            output_blockwise.(current_subject)(current_run).rest_trwise_meanblocks = mean(rest_trwise_meanblocks,'omitnan');
            output_blockwise.(current_subject)(current_run).run = current_run;
            output_blockwise.(current_subject)(current_run).feedback_group = group(indSubject);
            output_blockwise.(current_subject)(current_run).subject = subjects(indSubject);
            output_blockwise.(current_subject)(current_run).subject_token = subjects_token(indSubject);

            fbvalues_trwise = [];
            current_baseline_to_use = [];
            bool_new_baseline = 1;
            for indTR = 1:length(timecourse_filtered)

                if (1 == ismember(indTR, inds_rest))
                    if (1 == bool_new_baseline)
                        current_baseline_to_use = [];
                        bool_new_baseline = 0;
                    end
                    fbvalues_trwise(indTR) = 0;
                    current_baseline_to_use(indTR) = timecourse_scaled(indTR);
                elseif (1 == ismember(indTR, inds_fix))
                    fbvalues_trwise(indTR) = 0;
                else
                    current_baseline_mean = mean(current_baseline_to_use(current_baseline_to_use>0));

                    %Calc feedback value from last three TRs of each
                    %TR, substract previous baseline and scale according to
                    %online procedure
                    current_fbvalue = (timecourse_scaled(indTR)*0.5 + timecourse_scaled(indTR-1)*0.25  + timecourse_scaled(indTR-2)*0.25);
                    if current_fbvalue>current_baseline_mean
                        fbvalues_trwise(indTR) = (current_fbvalue - current_baseline_mean)/(1-current_baseline_mean);
                    else
                        fbvalues_trwise(indTR) = (current_fbvalue - current_baseline_mean)/(current_baseline_mean);
                    end
                    bool_new_baseline = 1;
                end
            end
            output_trwise.(current_subject)(current_run).offline_fb_values = fbvalues_trwise;
            output_trwise.(current_subject)(current_run).run = current_run;
            output_trwise.(current_subject)(current_run).feedback_group = group(indSubject);
            output_trwise.(current_subject)(current_run).subject = subjects(indSubject);
            output_trwise.(current_subject)(current_run).subject_token = subjects_token(indSubject);


        end % end of run
    end% end of session


    
end % end of subjects

save(fullfile(output_path, ['timecourses_' mask_output_name '_task-' current_task '_summary.mat']), 'output_timecourse');
writetable(struct2table(struct2array(output_timecourse)), fullfile(output_path, ['timecourses_' mask_output_name  '_task-' current_task '_summary.csv']))
save(fullfile(output_path, ['blockwiseValues_' mask_output_name '_task-' current_task '_summary.mat']), 'output_blockwise');
writetable(struct2table(struct2array(output_blockwise)), fullfile(output_path, ['blockwiseValues_' mask_output_name  '_task-' current_task '_summary.csv']))
save(fullfile(output_path, ['trwiseValues_' mask_output_name '_task-' current_task '_summary.mat']), 'output_trwise');
writetable(struct2table(struct2array(output_trwise)), fullfile(output_path, ['trwiseValues' mask_output_name  '_task-' current_task '_summary.csv']))
