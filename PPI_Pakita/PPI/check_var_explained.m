%%check the explained variance

% Settings 

data_dir   = '/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder_restimplicit_gPPI';
ppi_subdir = 'PPI_VOI_SN_VTA_gPPI';

subjects_description = readtable('/Users/pavanp/PhD/NeuroFeedback/PPI_Pakita/PPI/NFTraining_only_firstlevel_subjects.csv', ...
    'Delimiter', ',', 'ReadVariableNames', true);

% Get unique subject IDs and build folder names like 'sub-30823'
unique_ids = unique(subjects_description.subjectID_BIDS);          
n_subjects = length(unique_ids);


% Main loop  
%
r2_values   = nan(n_subjects, 1);
subject_ids = strings(n_subjects, 1);   % to store labels for plotting

for i = 1:n_subjects
    subj_num = unique_ids(i);
    subj_id  = sprintf('sub-%d', subj_num);        % e.g. 'sub-30823'
    subject_ids(i) = subj_id;
    
    spm_path = fullfile(data_dir, subj_id, ppi_subdir, 'SPM.mat');
    
    if ~exist(spm_path, 'file')
        fprintf('WARNING: SPM.mat not found for %s\n', subj_id);
        continue
    end
    
    load(spm_path);  % loads SPM struct
    
    trRV  = SPM.xX.trRV;
    trMVX = SPM.xX.trMVX;
    r2_values(i) = trMVX / (trMVX + trRV);
    
    fprintf('Subject %s: R² = %.3f\n', subj_id, r2_values(i));
end

% Summary
fprintf('\n--- Summary ---\n');
fprintf('N subjects found:  %d\n', sum(~isnan(r2_values)));
fprintf('Mean R²:           %.3f\n', nanmean(r2_values));
fprintf('Min R²:            %.3f\n', nanmin(r2_values));
fprintf('Max R²:            %.3f\n', nanmax(r2_values));

% Flag low R² subjects
low_r2_idx = find(r2_values < 0.05);
if ~isempty(low_r2_idx)
    fprintf('\nSubjects with R² < 0.05 — inspect these:\n');
    disp(subject_ids(low_r2_idx))
else
    fprintf('\nNo subjects with R² < 0.05.\n');
end

% Plot
figure;
bar(r2_values);
xticks(1:n_subjects);
xticklabels(subject_ids);
xtickangle(45);
xlabel('Subject');
ylabel('R²');
title('PPI Model R² per Subject');
yline(0.05, 'r--', 'Low R² threshold');