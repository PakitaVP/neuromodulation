function [jobfiles] = create_firstlevel_jobs_NFTask_regulation_only_regright_3_concat(data_preproc_path, data_bids_path, stat_dir, first_level_folder, table_firstlevel_subjects, bool_overwrite_1stlevels, tParams)

% load the template
matlabbatch = firstlevel_NFTask_template();

jobfiles = cell(numel(table_firstlevel_subjects.subjectID_BIDS),1);
% do the rest of filling out the matlabbatch

for indSubjects = 1:numel(table_firstlevel_subjects.subjectID_BIDS)
    
    current_subject = table_firstlevel_subjects.subjectID_BIDS(indSubjects);
    current_session = table_firstlevel_subjects.day(indSubjects);
    current_nr_of_runs = table_firstlevel_subjects.nr_of_runs(indSubjects);
    current_available_runs = 0;
    % to collect data from all runs to put it into matlabbatch at once 
    run_lengths = []; % to add in concats
    files_concat = [];
    confounds_regressor = [];
    
    conditions_1stLevels = struct();

    for indSessions = 1:numel(current_session)
        for indRuns = 1:current_nr_of_runs
            
            bool_onsets_available = false;
            if (1 == indRuns)
                bool_onsets_available = table_firstlevel_subjects.NFTask_onsets_available_1(indSubjects);
            elseif (2 == indRuns)
                bool_onsets_available = table_firstlevel_subjects.NFTask_onsets_available_2(indSubjects);
            elseif (3 == indRuns)
                bool_onsets_available = table_firstlevel_subjects.NFTask_onsets_available_3(indSubjects);
            end
            if (false == bool_onsets_available)
                continue;
            else
                current_available_runs = current_available_runs + 1;
            end
            str = fprintf('Create 1st level file for Subject: %s', ['sub-' mat2str(current_subject)]);
            disp(str);
            
             % load preprocessed file and put into structure
            
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'NFTask', 'run', mat2str(indRuns), 'desc', 'swrapreproc', 'ext', '_bold.nii');
            files = spm_select('ExtFPList', fullfile(data_preproc_path, filepath), filename,Inf);
            run_lengths(indRuns) = size(files,1);
            files_concat = [files_concat; cellstr(files)];
            
            % load all params for conditions in 1st level analysis -
            % on/offsets and duration for all available conditions
            fname_conditions = dir(fullfile(data_bids_path, ['sub-' mat2str(current_subject)], ['ses-' mat2str(current_session)], 'beh' ,['*_run-' mat2str(indRuns) '_condsOnOff_beh_task-NFAdapt.json']));
            fid = fopen(fullfile(fname_conditions.folder, fname_conditions.name));
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);
            conditions_raw = jsondecode(str);

            % load boolean info whether block regulated in right direction
            fname_boolregrightup = dir(fullfile(data_preproc_path, ['sub-' mat2str(current_subject)], ['ses-' mat2str(current_session)], 'beh' ,['*task-NFTask_run-' mat2str(indRuns) '_desc-boolregrightup.csv']));
            bool_regright_up = readtable(fullfile(fname_boolregrightup.folder, fname_boolregrightup.name));
            fname_boolregrightdown = dir(fullfile(data_preproc_path, ['sub-' mat2str(current_subject)], ['ses-' mat2str(current_session)], 'beh' ,['*task-NFTask_run-' mat2str(indRuns) '_desc-boolregrightdown.csv']));
            bool_regright_down = readtable(fullfile(fname_boolregrightdown.folder, fname_boolregrightdown.name));

            if (1 == indRuns)
                conditions_1stLevels.Onsets.BASELINE = conditions_raw.Bas(:,1);
                conditions_1stLevels.Duration.BASELINE = conditions_raw.Bas(:,2)-conditions_raw.Bas(:,1)+1;
                conditions_1stLevels.Onsets.NFUp_regright = conditions_raw.NFup(bool_regright_up.x==1,2)-2;
                conditions_1stLevels.Duration.NFUp_regright = 3;
                conditions_1stLevels.Onsets.NFDown_regright = conditions_raw.NFdown(bool_regright_down.x==1,2)-2;
                conditions_1stLevels.Duration.NFDown_regright = 3;
                % split up into right and wrong regulation success
                conditions_1stLevels.Onsets.NFUp_regwrong = conditions_raw.NFup(bool_regright_up.x==0,2)-2;
                conditions_1stLevels.Duration.NFUp_regwrong = 3;
                conditions_1stLevels.Onsets.NFDown_regwrong = conditions_raw.NFdown(bool_regright_down.x==0,2)-2;
                conditions_1stLevels.Duration.NFDown_regwrong = 3;
            elseif (2 == indRuns)
                conditions_1stLevels.Onsets.BASELINE = [conditions_1stLevels.Onsets.BASELINE; conditions_raw.Bas(:,1)+run_lengths(1)];
                conditions_1stLevels.Duration.BASELINE = [conditions_1stLevels.Duration.BASELINE; conditions_raw.Bas(:,2)-conditions_raw.Bas(:,1)+1];

                conditions_1stLevels.Onsets.NFUp_regright = [conditions_1stLevels.Onsets.NFUp_regright; conditions_raw.NFup(bool_regright_up.x==1,2)-2+run_lengths(1)];
                conditions_1stLevels.Duration.NFUp_regright = 3;
                conditions_1stLevels.Onsets.NFDown_regright = [conditions_1stLevels.Onsets.NFDown_regright; conditions_raw.NFdown(bool_regright_down.x==1,2)-2+run_lengths(1)];
                conditions_1stLevels.Duration.NFDown_regright = 3;

                conditions_1stLevels.Onsets.NFUp_regwrong = [conditions_1stLevels.Onsets.NFUp_regwrong; conditions_raw.NFup(bool_regright_up.x==0,2)-2+run_lengths(1)];
                conditions_1stLevels.Duration.NFUp_regwrong = 3;
                conditions_1stLevels.Onsets.NFDown_regwrong = [conditions_1stLevels.Onsets.NFDown_regwrong; conditions_raw.NFdown(bool_regright_down.x==0,2)-2+run_lengths(1)];
                conditions_1stLevels.Duration.NFDown_regwrong = 3;
                
            elseif (3 == indRuns)
                conditions_1stLevels.Onsets.BASELINE = [conditions_1stLevels.Onsets.BASELINE; conditions_raw.Bas(:,1)+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Duration.BASELINE = [conditions_1stLevels.Duration.BASELINE; conditions_raw.Bas(:,2)-conditions_raw.Bas(:,1)+1];

                conditions_1stLevels.Onsets.NFUp_regright = [conditions_1stLevels.Onsets.NFUp_regright; conditions_raw.NFup(bool_regright_up.x==1,2)-2+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Duration.NFUp_regright = 3;
                conditions_1stLevels.Onsets.NFDown_regright = [conditions_1stLevels.Onsets.NFDown_regright; conditions_raw.NFdown(bool_regright_down.x==1,2)-2+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Duration.NFDown_regright = 3;

                conditions_1stLevels.Onsets.NFUp_regwrong = [conditions_1stLevels.Onsets.NFUp_regwrong; conditions_raw.NFup(bool_regright_up.x==0,2)-2+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Duration.NFUp_regwrong = 3;
                conditions_1stLevels.Onsets.NFDown_regwrong = [conditions_1stLevels.Onsets.NFDown_regwrong; conditions_raw.NFdown(bool_regright_down.x==0,2)-2+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Duration.NFDown_regwrong = 3;
            end    
            
            % combine regressors motion and physio partly
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'NFTask', 'run', mat2str(indRuns), 'desc', 'confounds', 'ext', '_physio.tsv');
            physio_regressors_raw = readtable(fullfile(data_preproc_path,filepath, filename), 'FileType', 'delimitedtext', 'delimiter', '\t');
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'NFTask', 'run', mat2str(indRuns), 'desc', 'confounds', 'ext', '_motion.tsv');
            motion_regressors = readtable(fullfile(data_preproc_path,filepath, filename), 'FileType', 'delimitedtext', 'delimiter', '\t');
            % discard some of these params
            physio_regressors = [];
            physio_regressors = [physio_regressors physio_regressors_raw(:, 1:2)];
            physio_regressors = [physio_regressors physio_regressors_raw(:, 9:10)];
            physio_regressors = [physio_regressors physio_regressors_raw(:, 15:20)];
            % combine a few physio thingies (columns 1:2 9:10 15:18 19:20) and write back a file to
            % subject folder that will be used in 1st level analysis
            
            confounds_regressor = [confounds_regressor; [motion_regressors physio_regressors]];
            [outfilename, outfilepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'NFTask', 'desc', 'confounds', 'ext', '_motionphysio_concat.txt');
            writetable(confounds_regressor, fullfile(data_preproc_path, outfilepath, outfilename), 'FileType', 'text', 'Delimiter','\t', 'WriteVariableNames',0);
            current_nr_of_physio_regressors = 16;
            
        end   
            
        % ########################
        % now combine stuff from three runs and put batch together
        % onsets
        
        
        output_path = fullfile(stat_dir);
        
        
        current_stat_dir = fullfile(output_path, first_level_folder, ['sub-' mat2str(current_subject)]);
        
        if (~exist(current_stat_dir, 'dir'))
            mkdir(current_stat_dir);
        end
        
        % specify session directory
        matlabbatch{1}.spm.stats.fmri_spec.dir = {current_stat_dir};
        
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = tParams.TR;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = tParams.mic_res;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = tParams.mic_onset;
        
        
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = files_concat;
        
        
        % load all params for cond
        % load from condsOnOff
        % load from task logs the decision


        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'REST';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = conditions_1stLevels.Onsets.BASELINE;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = conditions_1stLevels.Duration.BASELINE;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;

        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'NFUp_regright';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = conditions_1stLevels.Onsets.NFUp_regright;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = conditions_1stLevels.Duration.NFUp_regright;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;

        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name = 'NFDown_regright';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset = conditions_1stLevels.Onsets.NFDown_regright;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = conditions_1stLevels.Duration.NFDown_regright;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).orth = 1;

        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).name = 'NFUp_regwrong';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).onset = conditions_1stLevels.Onsets.NFUp_regwrong;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).duration = conditions_1stLevels.Duration.NFUp_regwrong;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).orth = 1;

        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).name = 'NFDown_regwrong';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).onset = conditions_1stLevels.Onsets.NFDown_regwrong;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).duration = conditions_1stLevels.Duration.NFDown_regwrong;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).orth = 1;

        %%
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
        
        
        % load multiple regressors? if yes, then do it
        if strcmp(tParams.motion_regress,'yes')
            [confounds_filename, confounds_filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'NFTask', 'desc', 'confounds', 'ext', '_motionphysio_concat.txt');
            reg_file = spm_select('FPList', fullfile(data_preproc_path,confounds_filepath,confounds_filename));
        else
            reg_file = [];
        end
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {fullfile(data_preproc_path,confounds_filepath,confounds_filename)};
        
        % give concat info to re-estimate SPM.mat
        matlabbatch{2} = struct();
        matlabbatch{2}.cfg_basicio.run_ops.call_matlab.inputs{1}.evaluated(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{2}.cfg_basicio.run_ops.call_matlab.inputs{2}.evaluated = [run_lengths(1) run_lengths(2) run_lengths(3)];
        matlabbatch{2}.cfg_basicio.run_ops.call_matlab.outputs = cell(1, 0);
        matlabbatch{2}.cfg_basicio.run_ops.call_matlab.fun = 'spm_fmri_concatenate';
        
        
        % estimate now due to concate call before
        matlabbatch{3} = struct();
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        
        matlabbatch{3}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
        
        % define the contrasts
        current_nr_of_regressors = 5;
        matlabbatch{4} = struct();
        matlabbatch{4}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
       
        matlabbatch{4}.spm.stats.con.consess{1}.fcon.name = 'eoi';
        matlabbatch{4}.spm.stats.con.consess{1}.fcon.weights = [eye(current_nr_of_regressors) zeros(current_nr_of_regressors,current_nr_of_physio_regressors)];
        matlabbatch{4}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
        
        
            contrast_basic_names = {'UP_REGRIGHT-REST','UP_REGWRONG-REST',...
                                    'DOWN_REGRIGHT-REST','DOWN_REGWRONG-REST'};
            contrast_weights = {[-1 1 0 0 0], [-1 0 0 1 0],...
                                [-1 0 1 0 0], [-1 0 0 0 1]};
        
        contrast_index = 1;
        for indContrast = 1:numel(contrast_basic_names)
            contrast_index = contrast_index + 1;
            contrast_name = sprintf('%s%d', cell2mat(contrast_basic_names(indContrast)), indRuns);
            matlabbatch{4}.spm.stats.con.consess{contrast_index}.tcon.name = contrast_name;
            weight = [cell2mat(contrast_weights(indContrast)) zeros(1, current_nr_of_physio_regressors)];
            matlabbatch{4}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{4}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        end
        
        
        batch_file_name = strcat('firstLev_batch_NFTask_regulation_only_regright_3_concat.mat');
        if (~exist(fullfile(current_stat_dir, batch_file_name), 'file'))
            mkdir(current_stat_dir);
            save(fullfile(current_stat_dir,batch_file_name),'matlabbatch');
            jobfiles(indSubjects) = {fullfile(current_stat_dir,batch_file_name)};
        end
        if (0 == bool_overwrite_1stlevels && exist(current_stat_dir, 'dir'))
            if exist(fullfile(current_stat_dir,'SPM.mat'), 'file')==2
                jobfiles(indSubjects) = '';
            else
                jobfiles(indSubjects) = {fullfile(current_stat_dir,batch_file_name)};
            end
        elseif ((1 == bool_overwrite_1stlevels) && exist(current_stat_dir, 'dir'))
            if exist(fullfile(current_stat_dir,'SPM.mat'), 'file')==2
                delete(fullfile(current_stat_dir,'SPM.mat'));
            end
            save(fullfile(current_stat_dir,batch_file_name),'matlabbatch');
            jobfiles(indSubjects) = {fullfile(current_stat_dir,batch_file_name)};
        end
        
        
    end
    
end

end

