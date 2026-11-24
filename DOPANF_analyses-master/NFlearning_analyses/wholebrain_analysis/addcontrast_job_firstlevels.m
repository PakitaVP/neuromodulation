% subjects
subjects_description = readtable('C:\Development\DOPANF_analyses\NFTraining_only_firstlevel_subjects.csv', 'Delimiter',',','ReadVariableNames',true);
sub_dirs = unique(subjects_description.subjectID_BIDS(:));


for subject_index = 2:numel(sub_dirs)
    clear SPM matlabbatch
    current_subject = mat2str(sub_dirs(subject_index));

    disp("runs for " + current_subject)

    %-----------------------------------------------------------------------
    % Job saved on 08-Nov-2017 05:48:21 by cfg_util (rev $Rev: 6460 $)
    % spm SPM - SPM12 (6906)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    if (1 == ismac)
        current_stats_path = '/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder';
        load(fullfile(current_stats_path,['sub-' current_subject],'/SPM.mat'));
        matlabbatch{1}.spm.stats.con.spmmat = {fullfile(current_stats_path,['sub-' current_subject],'/SPM.mat')};
        
        SPM.xCon = [];
        save(fullfile(current_stats_path,['sub-' current_subject], 'SPM.mat'), 'SPM')
    elseif (1 == ispc)
        current_stats_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder';
        load(fullfile(current_stats_path,['sub-' current_subject],'\SPM.mat'));
        matlabbatch{1}.spm.stats.con.spmmat = {fullfile(current_stats_path,['sub-' current_subject],'\SPM.mat')};
        %SPM.xCon = [];
        %save(fullfile(current_stats_path,['sub-' current_subject], 'SPM.mat'), 'SPM')
        %load(fullfile(current_stats_path,['sub-' current_subject],'\SPM.mat'));
    end


%     matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = '(UP-DOWN)_BLTR_TRses2-BLses1';
%     matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [-1 1 zeros(1,16) zeros(1,126) 1 -1 zeros(1,16)];
%     matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
%     matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = '(UP-DOWN)_BLTR_TRses1-BLses1';
%     matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [-1 1 zeros(1,16) zeros(1,54) 1 -1 zeros(1,16) zeros(1,72)];
%     matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
%     matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = '(UP-DOWN)_BLTR_TRses2-BLses2';
%     matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [zeros(1,90) -1 1 zeros(1,16) zeros(1,36) 1 -1 zeros(1,16)];
%     matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
%     matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = '(UP-DOWN)_all_trainingsruns';
%     matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 zeros(1,16) 1 -1 zeros(1,16) 1 -1 zeros(1,16) 1 -1 zeros(1,16) 0 0 zeros(1,16) 0 0 zeros(1,16) 1 -1 zeros(1,16) 1 -1 zeros(1,16) 0 0 zeros(1,16)];
%     matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
% 
%     current_nr_of_regressors = 13;
%     current_nr_of_physio_regressors = 16;
%         matlabbatch{4} = struct();
%         matlabbatch{4}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
%        
%         matlabbatch{4}.spm.stats.con.consess{1}.fcon.name = 'eoi';
%         matlabbatch{4}.spm.stats.con.consess{1}.fcon.weights = [eye(current_nr_of_regressors) zeros(current_nr_of_regressors,current_nr_of_physio_regressors)];
%         matlabbatch{4}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
%         
%         if (1 == bool_include_regulations)
%             contrast_basic_names = {'UP-REST','DOWN-REST',...
%                                     'UP_ACCEPTED-REST','DOWN_REJECTED-REST','UP_REJECTED-REST', 'DOWN_ACCEPTED-REST',...
%                                     'PMOD_UP_ACCEPTED', 'PMOD_DOWN_REJECTED', 'PMOD_UP_REJECTED', 'PMOD_DOWN_ACCEPTED',...
%                                     'UP_ACC-REJ', 'DOWN_ACC-REJ', 'PMOD_UP_ACC-REJ', 'PMOD_DOWN_ACC-REJ'};
%             contrast_weights = {[-1 1 0 0 0 0 0 0 0 0 0 0 0], [-1 0 1 0 0 0 0 0 0 0 0 0 0],...
%                                 [-1 0 0 1 0 0 0 0 0 0 0 0 0], [-1 0 0 0 0 1 0 0 0 0 0 0 0], [-1 0 0 0 0 0 0 1 0 0 0 0 0], [-1 0 0 0 0 0 0 0 0 1 0 0 0],...
%                                 [0 0 0 0 1 0 0 0 0 0 0 0 0],  [0 0 0 0 0 0 1 0 0 0 0 0 0],  [0 0 0 0 0 0 0 0 1 0 0 0 0],  [0 0 0 0 0 0 0 0 0 0 1 0 0],...
%                                 [0 0 0 1 0 0 0 -1 0 0 0 0 0], [0 0 0 0 0 -1 0 0 0 1 0 0 0], [0 0 0 0 1 0 0 0 -1 0 0 0 0], [0 0 0 0 0 0 -1 0 0 0 1 0 0]};
%         
%         else
%             contrast_basic_names = {'UP_ACCEPTED','DOWN_REJECTED','UP_REJECTED', 'DOWN_ACCEPTED', 'PMOD_UP_ACCEPTED', 'PMOD_DOWN_REJECTED', 'PMOD_UP_REJECTED', 'PMOD_DOWN_ACCEPTED', 'UP_ACC-REJ', 'DOWN_ACC-REJ'};
%             contrast_weights = {[1 0 0 0 0 0 0 0 0 0], [0 0 1 0 0 0 0 0 0 0], [0 0 0 0 1 0 0 0 0 0], [0 0 0 0 0 0 1 0 0 0], [0 1 0 0 0 0 0 0 0 0], [0 0 0 1 0 0 0 0 0 0], [0 0 0 0 0 1 0 0 0 0], [0 0 0 0 0 0 0 1 0 0], [1 0 -1 0 0 0 0 0 0 0], [0 -1 0 1 0 0 0 0 0 0]};
%         
%         end
%         contrast_index = 1;
%         for indContrast = 1:numel(contrast_basic_names)
%             contrast_index = contrast_index + 1;
%             contrast_name = sprintf('%s%d', cell2mat(contrast_basic_names(indContrast)), indRuns);
%             matlabbatch{4}.spm.stats.con.consess{contrast_index}.tcon.name = contrast_name;
%             weight = [cell2mat(contrast_weights(indContrast)) zeros(1, current_nr_of_physio_regressors)];
%             matlabbatch{4}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
%             matlabbatch{4}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
%         end
%         


    %###########
    % define the contrasts
    current_nr_of_regressors = 4;
    current_nr_of_physio_regressors = 18;
    run_identifier=9;

    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = '(REST-DOWN)_BLTR_TRses2-BLses1';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [-1 0 0 1 zeros(1,7*current_nr_of_regressors+8*current_nr_of_physio_regressors) 1 0 0 -1 zeros(1,current_nr_of_physio_regressors)];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

    matlabbatch{1}.spm.stats.con.delete = 0;

%     matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = 'eoi';
% 
%     %TODO: check auf 9 runs
%     matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights = [eye(current_nr_of_regressors)...
%         zeros(current_nr_of_regressors,run_identifier*current_nr_of_physio_regressors+(run_identifier-1)*current_nr_of_regressors);...
% 
%         zeros(current_nr_of_regressors,current_nr_of_physio_regressors+current_nr_of_regressors)...
%         eye(current_nr_of_regressors)...
%         zeros(current_nr_of_regressors,(run_identifier-1)*current_nr_of_physio_regressors+7*current_nr_of_regressors);...
% 
%         zeros(current_nr_of_regressors,2*current_nr_of_physio_regressors+2*current_nr_of_regressors)...
%         eye(current_nr_of_regressors)...
%         zeros(current_nr_of_regressors,(run_identifier-2)*current_nr_of_physio_regressors+6*current_nr_of_regressors)...
% 
%         zeros(current_nr_of_regressors,3*current_nr_of_physio_regressors+3*current_nr_of_regressors)...
%         eye(current_nr_of_regressors)...
%         zeros(current_nr_of_regressors,(run_identifier-3)*current_nr_of_physio_regressors+5*current_nr_of_regressors)...
% 
%         zeros(current_nr_of_regressors,4*current_nr_of_physio_regressors+4*current_nr_of_regressors)...
%         eye(current_nr_of_regressors)...
%         zeros(current_nr_of_regressors,(run_identifier-4)*current_nr_of_physio_regressors+4*current_nr_of_regressors)...
% 
%         zeros(current_nr_of_regressors,5*current_nr_of_physio_regressors+5*current_nr_of_regressors)...
%         eye(current_nr_of_regressors)...
%         zeros(current_nr_of_regressors,(run_identifier-5)*current_nr_of_physio_regressors+3*current_nr_of_regressors)...
% 
%         zeros(current_nr_of_regressors,6*current_nr_of_physio_regressors+6*current_nr_of_regressors)...
%         eye(current_nr_of_regressors)...
%         zeros(current_nr_of_regressors,(run_identifier-6)*current_nr_of_physio_regressors+2*current_nr_of_regressors)...
% 
%         zeros(current_nr_of_regressors,7*current_nr_of_physio_regressors+7*current_nr_of_regressors)...
%         eye(current_nr_of_regressors)...
%         zeros(current_nr_of_regressors,(run_identifier-7)*current_nr_of_physio_regressors+current_nr_of_regressors)...
% 
%         zeros(current_nr_of_regressors,8*current_nr_of_physio_regressors+8*current_nr_of_regressors)...
%         eye(current_nr_of_regressors)...
%         zeros(current_nr_of_regressors,(run_identifier-8)*current_nr_of_physio_regressors)...
% 
%         zeros(current_nr_of_regressors,run_identifier*current_nr_of_physio_regressors+(run_identifier-1)*current_nr_of_regressors+current_nr_of_regressors)];
% 
% 
%     matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
% 
%     contrast_basic_names = {'UP-REST', 'DOWN-REST', 'REST-DOWN', 'UP-DOWN'};
%     contrast_weights = {[-1 1 0 0], [-1 0 0 1], [1 0 0 -1], [0 1 0 -1]};
%     contrast_index = 1;
%     %TODO: check ob noetig
%     current_session=[1];
%     for indContrast = 1:numel(contrast_basic_names)
%         for indRuns = 1:run_identifier
%             contrast_index = (indContrast -1 )* run_identifier + indRuns + 1;
%             contrast_name = sprintf('%s%d', cell2mat(contrast_basic_names(indContrast)), indRuns);
%             matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.name = contrast_name;
%             weight = [zeros(1, (indRuns-1)*current_nr_of_physio_regressors) zeros(1, (indRuns-1)*current_nr_of_regressors) cell2mat(contrast_weights(indContrast)) zeros(1, (numel(current_session)-indRuns+1)*current_nr_of_physio_regressors + (numel(current_session)-indRuns)*current_nr_of_regressors)];
%             matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
%             matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
%         end
%     end
% 
%     % add contrasts over all runs at the end
%     contrast_index = contrast_index + 1;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP-REST_allruns';
%     con_vec = [-1 1 0 0];
% 
% 
%     weight = repmat([con_vec zeros(1,current_nr_of_physio_regressors)], 1, run_identifier);
% 
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
% 
%     contrast_index = contrast_index + 1;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.name = 'DOWN-REST_allruns';
%     con_vec = [-1 0 0 1];
% 
% 
%     weight = repmat([con_vec zeros(1,current_nr_of_physio_regressors)], 1, run_identifier);
% 
% 
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
% 
%     contrast_index = contrast_index + 1;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.name = 'REST-DOWN_allruns';
%     con_vec = [1 0 0 -1];
% 
%     weight = repmat([con_vec zeros(1,current_nr_of_physio_regressors)], 1, run_identifier);
% 
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
% 
%     contrast_index = contrast_index + 1;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP-DOWN_allruns';
%     con_vec = [0 1 0 -1];
% 
%     weight = repmat([con_vec zeros(1,current_nr_of_physio_regressors)], 1, run_identifier);
% 
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
% 
%     contrast_index = contrast_index + 1;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)_BLTR_TRses2-BLses1';
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.weights = [0 -1 0 1 zeros(1,7*current_nr_of_regressors+8*current_nr_of_physio_regressors) 0 1 0 -1 zeros(1,current_nr_of_physio_regressors)];
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
% 
%     contrast_index = contrast_index + 1;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)_BLTR_TRses1-BLses1';
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.weights = [0 -1 0 1 zeros(1,3*current_nr_of_regressors+4*current_nr_of_physio_regressors) 0  1 0 -1 zeros(1,4*current_nr_of_regressors+5*current_nr_of_physio_regressors)];
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
% 
%     contrast_index = contrast_index + 1;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)_BLTR_TRses2-BLses2';
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5*current_nr_of_regressors+5*current_nr_of_physio_regressors) 0 -1 0 1 zeros(1,2*current_nr_of_regressors+3*current_nr_of_physio_regressors) 0 1 0 -1 zeros(1,current_nr_of_physio_regressors)];
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
% 
%     contrast_index = contrast_index + 1;
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)_all_trainingsruns';
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,4) zeros(1,current_nr_of_physio_regressors) 0 1 0 -1 zeros(1,current_nr_of_physio_regressors) 0 1 0 -1 zeros(1,current_nr_of_physio_regressors) 0 1 0 -1 zeros(1,current_nr_of_physio_regressors) 0 0 0 0 zeros(1,current_nr_of_physio_regressors) 0 0 0 0 zeros(1,current_nr_of_physio_regressors) 0 1 0 -1 zeros(1,current_nr_of_physio_regressors)  0 1 0 -1 zeros(1,current_nr_of_physio_regressors) 0 0 0 0 zeros(1,current_nr_of_physio_regressors)];
%     matlabbatch{1}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
%     matlabbatch{1}.spm.stats.con.delete = 0;



    spm_jobman('run', matlabbatch);
end


