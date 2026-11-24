function [jobfiles] = create_firstlevel_jobs_BLTask(data_preproc_path, data_bids_path, stat_dir, first_level_folder, table_firstlevel_subjects, bool_overwrite_1stlevels, tParams)
                      
% load the template
matlabbatch = firstlevel_BLTask_template();

jobfiles = cell(numel(table_firstlevel_subjects.subjectID_BIDS),1);
% do the rest of filling out the matlabbatch

for indSubjects = 1:numel(table_firstlevel_subjects.subjectID_BIDS)
    
    current_subject = table_firstlevel_subjects.subjectID_BIDS(indSubjects);
    current_session = table_firstlevel_subjects.day(indSubjects);
    current_nr_of_runs = table_firstlevel_subjects.nr_of_runs(indSubjects);
    current_available_runs = 0;
    for indSessions = 1:numel(current_session)
        for indRuns = 1:current_nr_of_runs
            
            bool_onsets_available = false;
            if (1 == indRuns)
                bool_onsets_available = table_firstlevel_subjects.BLTask_onsets_available_1(indSubjects);
            elseif (2 == indRuns)
                bool_onsets_available = table_firstlevel_subjects.BLTask_onsets_available_2(indSubjects);
            end
            if (false == bool_onsets_available)
                continue;
            else
                current_available_runs = current_available_runs + 1;
            end
            
            str = fprintf('Create 1st level file for Subject: %s run %.0f', ['sub-' mat2str(current_subject)], indRuns);
            disp(str);
            conditions_1stLevels = struct();
            % load all params for conditions in 1st level analysis -
            % on/offsets and duration for all available conditions
            % they need to be re-formatted and/or combined with additional
            % information from task logs (decision behavior)
            % load from condsOnOff file raw information of conditions
            fname_conditions = dir(fullfile(data_bids_path, ['sub-' mat2str(current_subject)], ['ses-' mat2str(current_session)], 'beh' ,['*indiff*_run-' mat2str(indRuns) '_task-DecMakBL.mat']));
            
            conditions_raw = load(fullfile(fname_conditions.folder, fname_conditions.name));
            
            % load from task logs the decision
            % the first line in the logfile contains the start time of the
            % experiment, which has to be substracted as reference for each
            % value
            % for an unknown reason, the logs have been done after the
            % decision, therefore the sixth column containing the RT time
            % has to be substracted from each value
            % TODO: CHANGE VARIABLE NAMING IN WRAPPER TO AVOID THIS
            if isfield(conditions_raw, 'indiff_logfile')
                conditions_1stLevels.Onsets.Decisions_accepted = conditions_raw.indiff_logfile.decision_logs(conditions_raw.indiff_logfile.decision_logs(:,5)==1,8)-conditions_raw.indiff_logfile.decision_logs(1,8)-conditions_raw.indiff_logfile.decision_logs(conditions_raw.indiff_logfile.decision_logs(:,5)==1,6);
                conditions_1stLevels.Duration.Decisions_accepted = 0;
                conditions_1stLevels.Onsets.Decisions_rejected = conditions_raw.indiff_logfile.decision_logs(conditions_raw.indiff_logfile.decision_logs(:,5)==0,8)-conditions_raw.indiff_logfile.decision_logs(1,8)-conditions_raw.indiff_logfile.decision_logs(conditions_raw.indiff_logfile.decision_logs(:,5)==0,6);
                conditions_1stLevels.Duration.Decisions_rejected = 0;
            else
                conditions_1stLevels.Onsets.Decisions_accepted = (conditions_raw.decision_logs(conditions_raw.decision_logs(:,5)==1,8)-conditions_raw.decision_logs(1,8)-conditions_raw.decision_logs(conditions_raw.decision_logs(:,5)==1,6));
                conditions_1stLevels.Duration.Decisions_accepted = 0;
                conditions_1stLevels.Onsets.Decisions_rejected = (conditions_raw.decision_logs(conditions_raw.decision_logs(:,5)==0,8)-conditions_raw.decision_logs(1,8)-conditions_raw.decision_logs(conditions_raw.decision_logs(:,5)==0,6));
                conditions_1stLevels.Duration.Decisions_rejected = 0;
            end
            
            % combine regressors motion and physio partly
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'BLTask', 'run', mat2str(indRuns), 'desc', 'confounds', 'ext', '_physio.tsv');
            physio_regressors_raw = readtable(fullfile(data_preproc_path,filepath, filename), 'FileType', 'delimitedtext', 'delimiter', '\t');
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'BLTask', 'run', mat2str(indRuns), 'desc', 'confounds', 'ext', '_motion.tsv');
            motion_regressors = readtable(fullfile(data_preproc_path,filepath, filename), 'FileType', 'delimitedtext', 'delimiter', '\t');
            % discard some of these params
            physio_regressors = [];
            physio_regressors = [physio_regressors physio_regressors_raw(:, 1:2)];
            physio_regressors = [physio_regressors physio_regressors_raw(:, 9:10)];
            physio_regressors = [physio_regressors physio_regressors_raw(:, 15:20)];
            % combine a few physio thingies (columns 1:2 9:10 15:18 19:20) and write back a file to
            % subject folder that will be used in 1st level analysis
            confounds_regressor = [motion_regressors physio_regressors];
            [outfilename, outfilepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'BLTask', 'run', mat2str(indRuns), 'desc', 'confounds', 'ext', '_motionphysio.txt');
            writetable(confounds_regressor, fullfile(data_preproc_path, outfilepath, outfilename), 'FileType', 'text', 'Delimiter','\t', 'WriteVariableNames',0);
                
            
            
            %########################
            
            output_path = fullfile(stat_dir);
                       
            
            current_stat_dir = fullfile(output_path, first_level_folder, ['sub-' mat2str(current_subject)]);
            
            % specify session directory
            matlabbatch{1}.spm.stats.fmri_spec.dir = {current_stat_dir};
            
            matlabbatch{1}.spm.stats.fmri_spec.timing.RT = tParams.TR;
            matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = tParams.mic_res;
            matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = tParams.mic_onset;
            
            % load preprocessed file and put into structure
            
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'BLTask', 'run', mat2str(indRuns), 'desc', 'swrapreproc', 'ext', '_bold.nii');
            
            files = spm_select('ExtFPList', fullfile(data_preproc_path, filepath), filename,Inf);
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).scans = cellstr(files);
            
            
            % load all params for cond
            % load from condsOnOff
            % load from task logs the decision
            
            %%
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).name = 'Decision_accepted';
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).onset = conditions_1stLevels.Onsets.Decisions_accepted;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).duration = conditions_1stLevels.Duration.Decisions_accepted;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).hpf = 128;
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).name = 'Decision_rejected';
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).onset = conditions_1stLevels.Onsets.Decisions_rejected;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).duration = conditions_1stLevels.Duration.Decisions_rejected;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).hpf = 128;
            
            % load multiple regressors? if yes, then do it
            if strcmp(tParams.motion_regress,'yes')
                [confounds_filename, confounds_filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'BLTask', 'run', mat2str(indRuns), 'desc', 'confounds', 'ext', '_motionphysio.txt');
                reg_file = spm_select('FPList', fullfile(data_preproc_path,confounds_filepath,confounds_filename));
            else
                reg_file = [];
            end
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi_reg = {fullfile(data_preproc_path,confounds_filepath,confounds_filename)};
         end
%         
        % define the contrasts
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'eoi';
        if (1 == current_available_runs)
            matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [eye(2) zeros(2,16)];
        elseif (2 == current_available_runs)
            matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [eye(2) zeros(2,34); zeros(2,18) eye(2) zeros(2,16)];
        end
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
        
        contrast_basic_names = {'DECACCEPT-DECDECLINE'};
        contrast_weights = {[1 -1]};
        contrast_index = 1;
        for indContrast = 1:numel(contrast_basic_names)
            for indRuns = 1:current_available_runs
                contrast_index = (indContrast -1 )* numel(current_nr_of_runs) + indRuns + 1;
                contrast_name = sprintf('%s%d', cell2mat(contrast_basic_names(indContrast)), indRuns);
                matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = contrast_name;
                weight = [zeros(1, (indRuns-1)*16) zeros(1, (indRuns-1)*2) cell2mat(contrast_weights(indContrast)) zeros(1, (numel(current_session)-indRuns+1)*16 + (numel(current_session)-indRuns)*2)];
                matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
                matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
            end
        end
        
        % add four contrasts at the end
         contrast_index = contrast_index + 1;
         matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DECACCEPT-DECDECLINE_allruns';
         weight = [];
         if (1 == current_available_runs)
            weight = [[1 -1] zeros(1,16)];
         elseif (2 == current_available_runs)
             weight = [[1 -1] zeros(1,16) [1 -1] zeros(1,16)];
         end
         matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
         matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
         
         % add four contrasts at the end
         contrast_index = contrast_index + 1;
         matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DECALL_allruns';
         weight = [];
         if (1 == current_available_runs)
            weight = [[1 1] zeros(1,16)];
         elseif (2 == current_available_runs)
             weight = [[1 1] zeros(1,16) [1 1] zeros(1,16)];
         end
         matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
         matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';


        % save mat file and run job
        batch_file_name = strcat('firstLev_batch_BLTask_decision_split2.mat');
        if (~exist(fullfile(current_stat_dir, batch_file_name), 'file'))
            mkdir(current_stat_dir);
            save(fullfile(current_stat_dir,batch_file_name),'matlabbatch');
            jobfiles(indSubjects) = {fullfile(current_stat_dir,batch_file_name)};
        end
        if (0 == bool_overwrite_1stlevels && exist(current_stat_dir, 'dir'))
            if (2 == exist(fullfile(current_stat_dir,'SPM.mat'), 'file'))
                jobfiles(indSubjects) = {''};
            else
                jobfiles(indSubjects) = {fullfile(current_stat_dir,batch_file_name)};
            end
        elseif ((1 == bool_overwrite_1stlevels) && exist(current_stat_dir, 'dir'))
            if (2 == exist(fullfile(current_stat_dir,'SPM.mat'), 'file'))
                delete(fullfile(current_stat_dir,'SPM.mat'));
            end
            save(fullfile(current_stat_dir,batch_file_name),'matlabbatch');
            jobfiles(indSubjects) = {fullfile(current_stat_dir,batch_file_name)};
        end


        

        
     end
    
end

end

