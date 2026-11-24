function [jobfiles] = create_firstlevel_jobs_mni_allruns( data_preproc_path, data_bids_path, stat_dir, first_level_folder, subjects, tasks, sessions, runs, tParams, conOpt )
                      
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% load the template
matlabbatch = firstlevel_NFTask_template();

jobfiles = cell(numel(subjects),1);
% do the rest of filling out the matlabbatch
for indSubjects = 1:numel(subjects)
    for indSessions = 1:numel(sessions)
        for indRuns = 1:numel(runs)
            conditions_1stLevels = struct();
            % load all params for conditions in 1st level analysis -
            % on/offsets and duration for all available conditions
            % they need to be re-formatted and/or combined with additional
            % information from task logs (decision behavior)
            % load from condsOnOff file raw information of conditions
            fname_conditions = dir(fullfile(data_bids_path, ['sub-' subjects{indSubjects}], ['ses-' sessions{indSessions}], 'beh' ,['*_run-0' runs{indRuns} '_condsOnOff_beh_task-NFAdapt.json']));
            fid = fopen(fullfile(fname_conditions.folder, fname_conditions.name));
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);
            conditions_raw = jsondecode(str);
            
            conditions_1stLevels.Onsets.BASELINE = conditions_raw.Bas(:,1);
            conditions_1stLevels.Duration.BASELINE = conditions_raw.Bas(:,2)-conditions_raw.Bas(:,1)+1;
            conditions_1stLevels.Onsets.NFUp = conditions_raw.NFup(:,1);
            conditions_1stLevels.Duration.NFUp = conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1;
            conditions_1stLevels.Onsets.NFDown = conditions_raw.NFdown(:,1);
            conditions_1stLevels.Duration.NFDown = conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1;
            conditions_1stLevels.Onsets.Decisions_all = conditions_raw.Task(:,1);
            conditions_1stLevels.Duration.Decisions_all = 0;
            
            
            % load from task logs the decision
            fname_tasklogs = dir(fullfile(data_bids_path, ['sub-' subjects{indSubjects}], ['ses-' sessions{indSessions}], 'beh' ,['*_run-0' runs{indRuns} '_taskResults_task-NFAdapt.csv']));
            tasklogs_raw = readtable(fullfile(fname_tasklogs.folder, fname_tasklogs.name));
            conditions_1stLevels.Onsets.Decisions_accepted = conditions_raw.Task(tasklogs_raw.choice == 1);
            conditions_1stLevels.Duration.Decisions_accepted = 0;
            conditions_1stLevels.Onsets.Decisions_rejected = conditions_raw.Task(tasklogs_raw.choice == 0);
            conditions_1stLevels.Duration.Decisions_rejected = 0;
            
            % combine regressors motion and physio partly
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', subjects{indSubjects}, 'ses', sessions{indSessions}, 'task', 'NFTask', 'run', runs{indRuns}, 'desc', 'confounds', 'ext', '_physio.tsv');
            physio_regressors_raw = readtable(fullfile(data_preproc_path,filepath, filename), 'FileType', 'delimitedtext', 'delimiter', '\t')
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', subjects{indSubjects}, 'ses', sessions{indSessions}, 'task', 'NFTask', 'run', runs{indRuns}, 'desc', 'confounds', 'ext', '_motion.tsv');
            motion_regressors = readtable(fullfile(data_preproc_path,filepath, filename), 'FileType', 'delimitedtext', 'delimiter', '\t')
            % discard some of these params
            physio_regressors = [];
            physio_regressors = [physio_regressors physio_regressors_raw(:, 1:2)];
            physio_regressors = [physio_regressors physio_regressors_raw(:, 9:10)];
            physio_regressors = [physio_regressors physio_regressors_raw(:, 15:20)];
            % combine a few physio thingies (columns 1:2 9:10 15:18 19:20) and write back a file to
            % subject folder that will be used in 1st level analysis
            confounds_regressor = [motion_regressors physio_regressors];
            [outfilename, outfilepath] = fmrwhy_bids_constructFilename('func', 'sub', subjects{indSubjects}, 'ses', sessions{indSessions}, 'task', 'NFTask', 'run', runs{indRuns}, 'desc', 'confounds', 'ext', '_motionphysio.tsv');
            writetable(confounds_regressor, fullfile(data_preproc_path, outfilepath, outfilename), 'FileType', 'text', 'Delimiter','\t');
                
            
            
            %########################
            
            output_path = fullfile(stat_dir);
                       
            
            current_stat_dir = fullfile(output_path, first_level_folder, subjects{indSubjects});
            if (~exist(current_stat_dir, 'dir'))
                mkdir(current_stat_dir);
            end
            
            cd(current_stat_dir);
            
            % specify session directory
            matlabbatch{1}.spm.stats.fmri_spec.dir = {current_stat_dir};
            
            matlabbatch{1}.spm.stats.fmri_spec.timing.RT = tParams.TR;
            matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = tParams.mic_res;
            matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = tParams.mic_onset;
            
            % load preprocessed file and put into structure
            
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', subjects{indSubjects}, 'ses', sessions{indSessions}, 'task', 'NFTask', 'run', runs{indRuns}, 'desc', 'swrapreproc', 'ext', '_bold.nii');
            
            files = spm_select('ExtFPList', fullfile(filepath, filename,Inf);
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(indSessions).scans = cellstr(files);
            
            
            % load all params for cond
            % load from condsOnOff
            % load from task logs the decision
            
            %%
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).name = 'BASELINE';
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).onset = conditions_1stLevels.Onsets.BASELINE;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).duration = conditions_1stLevels.Duration.BASELINE;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(1).orth = 1;
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).name = 'NFup';
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).onset = conditions_1stLevels.Onsets.NFUp;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).duration = conditions_1stLevels.Duration.NFUp;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(2).orth = 1;
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(3).name = 'NFDown';
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(3).onset = conditions_1stLevels.Onsets.NFDown;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(3).duration = conditions_1stLevels.Duration.NFDown;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(3).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(3).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).hpf = 128;
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(4).name = 'Decision_accepted';
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(4).onset = conditions_1stLevels.Onsets.Decisions_accepted;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(4).duration = conditions_1stLevels.Duration.Decisions_accepted;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(4).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(4).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).hpf = 128;
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).name = 'Decision_rejected';
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).onset = conditions_1stLevels.Onsets.Decisions_rejected;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).duration = conditions_1stLevels.Duration.Decisions_rejected;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).hpf = 128;
            
            % load multiple regressors? if yes, then do it
            if strcmp(tParams.motion_regress,'yes')
                [confounds_filename, confounds_filepath] = fmrwhy_bids_constructFilename('func', 'sub', subjects{indSubjects}, 'ses', sessions{indSessions}, 'task', 'NFTask', 'run', runs{indRuns}, 'desc', 'confounds', 'ext', '_motionphysio.tsv');
                reg_file = spm_select('FPList', fullfile(data_preproc_path,confounds_filepath,confounds_filename));
            else
                reg_file = [];
            end
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi_reg = {reg_file};
        end
        
        % define the contrasts
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'eoi';
        if (4 == numel(sessions))
            matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [eye(3) zeros(3,57); zeros(3,15) eye(3) zeros(3,42); zeros(3,30) eye(3) zeros(3,27); zeros(3,45) eye(3) zeros(3,12)];
        elseif(5 == numel(sessions))
            matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [eye(3) zeros(3,72); zeros(3,15) eye(3) zeros(3,57); zeros(3,30) eye(3) zeros(3,42); zeros(3,45) eye(3) zeros(3,27); zeros(3,60) eye(3) zeros(3,12)];
        end
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
        
        
        contrast_basic_names = {'UP_r', 'DOWN_r', 'UP-DOWN_r'};
        contrast_weights = {[0 0 1], [0 1 0], [0 -1 1]};
        contrast_index = 1;
        for indContrast = 1:numel(contrast_basic_names)
            for indSessions = 1:numel(sessions)
                contrast_index = (indContrast -1 )* numel(sessions) + indSessions + 1;
                contrast_name = sprintf('%s%d', cell2mat(contrast_basic_names(indContrast)), indSessions);
                matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = contrast_name;
                weight = [zeros(1, (indSessions-1)*12) zeros(1, (indSessions-1)*3) cell2mat(contrast_weights(indContrast)) zeros(1, (numel(sessions)-indSessions+1)*12 + (numel(sessions)-indSessions)*3)];
                matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
                matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
            end
        end
        
        % add four contrasts at the end
        contrast_index = contrast_index + 1;
        if (4 == numel(sessions))
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP_r4-r1';
            weight = [[0 0 -1] zeros(1,42) [0 0 1] zeros(1,12)];
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        else
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP_r5-r1';
            weight = [[0 0 -1] zeros(1,42) [0 0 1] zeros(1,12)];
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        end
        
        contrast_index = contrast_index + 1;
        if (4 == numel(sessions))
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DOWN_r4-r1';
            weight = [[0 -1 0] zeros(1,42) [0 1 0] zeros(1,12)];
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        else
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DOWN_r5-r1';
            weight = [[0 -1 ] zeros(1,57) [0 1 0] zeros(1,12)];
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        end
        
        contrast_index = contrast_index + 1;
        if (4 == numel(sessions))
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP-DOWN_allruns';
            weight = [[0 -1 1] zeros(1,12) [0 -1 1] zeros(1,12) [0 -1 1] zeros(1,12) [0 -1 1] zeros(1,12)];
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        else
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP-DOWN_allruns';
            weight = [[0 -1 1] zeros(1,12) [0 -1 1] zeros(1,12) [0 -1 1] zeros(1,12) [0 -1 1] zeros(1,12) [0 -1 1] zeros(1,12)];
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        end
        
        contrast_index = contrast_index + 1;
        if (4 == numel(sessions))
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP-DOWN_r4-r1';
            weight = [[0 1 -1] zeros(1,42) [0 -1 1] zeros(1,12)];
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        else
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP-DOWN_r5-r1';
            weight = [[0 1 -1] zeros(1,57) [0 -1 1] zeros(1,12)];
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        end
        
        
        % save mat file and run job
        batch_file_name = strcat('firstLev_batch_mni_allruns.mat');
        save(fullfile(current_stat_dir,batch_file_name),'matlabbatch');
        jobfiles(indSubjects) = {fullfile(current_stat_dir,batch_file_name)};
    end
    
end

end

