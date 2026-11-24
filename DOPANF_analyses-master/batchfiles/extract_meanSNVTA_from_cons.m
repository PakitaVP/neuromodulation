

close all;
clear all;
addpath('C:\Users\lhellr\Documents\MATLAB\Toolboxes\NIfTI_20140122\');

data_path = '';
data_filenames = '';
stats_path = '';

% choose task
% NFTask, BLTask, NFTraining
current_task = 'NFTraining';
condition = [];
if (strcmp('NFTraining', current_task))
    data_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\';
    data_filenames = {'con_0002', 'con_0003', 'con_0004', 'con_0005','con_0006', 'con_0007', 'con_0008', 'con_0009','con_0010','con_0020', 'con_0021', 'con_0022', 'con_0023','con_0024', 'con_0025', 'con_0026', 'con_0027','con_0028','con_0029', 'con_0030', 'con_0031', 'con_0032','con_0033', 'con_0034', 'con_0035', 'con_0036','con_0037'};
    %stats_path = 'task-NFTraining';
    stats_path = 'task-NFTraining_wmcsf_confounder_blocksplit';
    nr_of_runs = 9;
    condition = [condition, repmat({'UP'},1,nr_of_runs), repmat({'DOWN'},1,nr_of_runs), repmat({'UP-DOWN'},1,nr_of_runs)];
    runs = repmat(1:nr_of_runs,1,3);
elseif (strcmp('NFTask', current_task))
    data_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\';
    data_filenames = {'con_0002', 'con_0003'};
    stats_path = 'task-NFTask\stats_task-NFTask_regulation_and_decisions_upar_downar_concat_fm';
elseif (strcmp('BLTask', current_task))
    disp('For baseline task no up and down regulations exist. This is not possible')
    return;
else
    disp('No task chosen. Dunno which contrasts to choose!')
    return;
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

output_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\extract_from_cons';
if (0 == exist(output_path,'dir'))
    mkdir(output_path)
end

% subjects
[current_path,~,~] = fileparts(mfilename('fullpath'));
if (strcmp('NFTraining', current_task))
    subjects_description = readtable(fullfile(current_path, '..', 'NFTraining_only_firstlevel_subjects.csv'), 'Delimiter',',','ReadVariableNames',true);
    subjects = subjects_description.subjectID_BIDS(1:2:end);
    group = subjects_description.feedback_group(1:2:end);
elseif (strcmp('NFTask', current_task))
    subjects_description = readtable(fullfile(current_path, '..', 'NFTask_only_firstlevel_subjects.csv'), 'Delimiter',',','ReadVariableNames',true);
    subjects = subjects_description.subjectID_BIDS(:);
    group = subjects_description.feedback_group(:);
else
    disp('No task chosen. Dunno which subjects to choose!')
    return;
end


% init output variable
slope_nfruns_m_weighted = zeros(1, length(subjects));
slope_nfruns_intercept_weighted = zeros(1, length(subjects));
slope_nfruns_m = zeros(1, length(subjects));
slope_nfruns_intercept = zeros(1, length(subjects));

output = struct();
for indSubject = 1:numel(subjects)
    
    current_sub = ['sub_' mat2str(subjects(indSubject))];
    % Maske MNI SPace
    mask_file = fullfile(mask_path, mask_filename);
    mask_data = load_nii(mask_file);
    
    for indSession = 1:length(data_filenames)
        file_path = fullfile(data_path, stats_path, ['sub-' mat2str(subjects(indSubject))], [cell2mat(data_filenames(indSession)) '.nii']);
        con_data = load_nii(file_path);
        
        
        % mult epi * mask
        [mix,miy,miz]=ind2sub(size(mask_data.img),find(mask_data.img > 0));
        mi=[mix,miy,miz];
        mask_voxels = [];
        mask_weights = [];
        for indInd=1:size(mi,1)
            mask_voxels(:,indInd) = double(squeeze(con_data.img(mi(indInd,1),mi(indInd,2),mi(indInd,3),:)));
            mask_weights(:,indInd) = double(squeeze(mask_data.img(mi(indInd,1),mi(indInd,2),mi(indInd,3),:)));
        end
        mask_voxels_weighted = mask_voxels .* mask_weights;

        q50 = quantile(mask_voxels, 0.5);
        

        output.(current_sub)(indSession).statistical_mean_q50 = mean(mask_voxels(mask_voxels > q50));
        output.(current_sub)(indSession).statistical_std_q50 = std(mask_voxels(mask_voxels > q50));
        output.(current_sub)(indSession).mean = nanmean(mask_voxels);
        output.(current_sub)(indSession).std = nanstd(mask_voxels);
        output.(current_sub)(indSession).mean_thresh05 = nanmean(mask_voxels(mask_weights>0.5));
        output.(current_sub)(indSession).std_thresh05 = nanstd(mask_voxels(mask_weights>0.5));
        output.(current_sub)(indSession).weighted_mean = nanmean(mask_voxels_weighted)/nanmean(mask_weights);
        output.(current_sub)(indSession).weighted_std = nanstd(mask_voxels_weighted);
        output.(current_sub)(indSession).feedback_group = group(indSubject);
        output.(current_sub)(indSession).subject = subjects(indSubject);
        output.(current_sub)(indSession).run = runs(indSession);
        output.(current_sub)(indSession).condition = condition(indSession);
        
        
    end % end of session
    
    
end % end of subjects

save(fullfile(output_path, ['con_extractions_' mask_output_name '_task-' current_task '_wmcsf_confounder_rest-down_blocksplit_summary.mat']), 'output'); %_wmcsf_confounder
writetable(struct2table(struct2array(output)), fullfile(output_path, ['con_extractions_' mask_output_name  '_task-' current_task '_wmcsf_confounder_rest-down_blocksplit_summary.csv'])) %_wmcsf_confounder


%% make stats about this using correlations

% first, take data james from this script
tmp_nam = fieldnames(output);
% i = sessionNr
if (strcmp('NFTraining', current_task))
    
    for indCondition = 1:length(unique(condition))

        cond_name = condition{(indCondition-1)*nr_of_runs+1};


        slope_thresh05  = cell2mat(cellfun(@(x) (polyfit(1:5, ...
            [output.(x)((indCondition-1)*nr_of_runs + 2).statistical_mean_q50 output.(x)((indCondition-1)*nr_of_runs + 3).statistical_mean_q50 output.(x)((indCondition-1)*nr_of_runs + 4).statistical_mean_q50 output.(x)((indCondition-1)*nr_of_runs + 7).statistical_mean_q50 output.(x)((indCondition-1)*nr_of_runs + 8).statistical_mean_q50]...
            ,1)),tmp_nam,'UniformOutput',false));

        DRT1 = cell2mat(cellfun(@(x)(output.(x)((indCondition-1)*nr_of_runs + 5).statistical_mean_q50),tmp_nam,'UniformOutput',false))-cell2mat(cellfun(@(x)(output.(x)((indCondition-1)*nr_of_runs + 1).statistical_mean_q50),tmp_nam,'UniformOutput',false));
        DRT2 = cell2mat(cellfun(@(x)(output.(x)((indCondition-1)*nr_of_runs + 9).statistical_mean_q50),tmp_nam,'UniformOutput',false))-cell2mat(cellfun(@(x)(output.(x)((indCondition-1)*nr_of_runs + 6).statistical_mean_q50),tmp_nam,'UniformOutput',false));
        DRT12 = cell2mat(cellfun(@(x)(output.(x)((indCondition-1)*nr_of_runs + 9).statistical_mean_q50),tmp_nam,'UniformOutput',false))-cell2mat(cellfun(@(x)(output.(x)((indCondition-1)*nr_of_runs + 1).statistical_mean_q50),tmp_nam,'UniformOutput',false));

        DRT1slope = [DRT1, DRT2, DRT12, slope_thresh05(:,1), slope_thresh05(:,2), subjects, group];

        table1 = array2table(DRT1slope);
        table1.Properties.VariableNames(1:7) = {'DRT1','DRT2','DRT12', 'slope', 'intercept', 'subject', 'group'};
        outputfile = fullfile(output_path, ['DRTslope_ses-all_condition_' cond_name '_mask-' mask_output_name '_task-' current_task '_wmcsf_confounder_rest-down_blocksplit_statmean.csv']); %_wmcsf_confounder
        writetable(table1,outputfile);

        [r,p] = corrcoef(DRT1slope)
        

    end %indCondition
end



% 
% [r,p] = corrcoef(mat_INT_slope)
% [r,p] = corrcoef(mat_CON_slope)
% 
% % Kruskal Wallis for DORT between groups
% groups = [ones(length(dort_CON),1); 2*ones(length(dort_INT_MK),1); 3*ones(length(dort_INT)-length(dort_INT_MK),1)];
% dorts = [dort_CON; dort_INT_MK; dort(1:14)];
% [p, anova,stats] = kruskalwallis(dorts,groups,'off')
