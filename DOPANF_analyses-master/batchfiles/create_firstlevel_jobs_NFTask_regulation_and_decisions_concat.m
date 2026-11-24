function [jobfiles] = create_firstlevel_jobs_NFTask_regulation_and_decisions_concat(data_preproc_path, data_bids_path, stat_dir, first_level_folder, table_firstlevel_subjects, bool_overwrite_1stlevels, tParams)

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
    conditions_1stLevels.Pmods.Decisions_up_accepted = [];
    conditions_1stLevels.Pmods.Decisions_up_rejected = [];
    conditions_1stLevels.Pmods.Decisions_down_rejected = [];
    conditions_1stLevels.Pmods.Decisions_down_accepted = [];
    conditions_1stLevels.Pmods.Others = [];
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
            
            if (1 == indRuns)
                conditions_1stLevels.Onsets.BASELINE = conditions_raw.Bas(:,1);
                conditions_1stLevels.Duration.BASELINE = conditions_raw.Bas(:,2)-conditions_raw.Bas(:,1)+1;
                conditions_1stLevels.Onsets.NFUp = conditions_raw.NFup(:,1);
                conditions_1stLevels.Duration.NFUp = conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1;
                conditions_1stLevels.Onsets.NFDown = conditions_raw.NFdown(:,1);
                conditions_1stLevels.Duration.NFDown = conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1;
            elseif (2 == indRuns)
                conditions_1stLevels.Onsets.BASELINE = [conditions_1stLevels.Onsets.BASELINE; conditions_raw.Bas(:,1)+run_lengths(1)];
                conditions_1stLevels.Duration.BASELINE = [conditions_1stLevels.Duration.BASELINE; conditions_raw.Bas(:,2)-conditions_raw.Bas(:,1)+1];
                conditions_1stLevels.Onsets.NFUp = [conditions_1stLevels.Onsets.NFUp; conditions_raw.NFup(:,1)+run_lengths(1)];
                conditions_1stLevels.Duration.NFUp = [conditions_1stLevels.Duration.NFUp; conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1];
                conditions_1stLevels.Onsets.NFDown = [conditions_1stLevels.Onsets.NFDown; conditions_raw.NFdown(:,1)+run_lengths(1)];
                conditions_1stLevels.Duration.NFDown = [conditions_1stLevels.Duration.NFDown; conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1];
                
            elseif (3 == indRuns)
                conditions_1stLevels.Onsets.BASELINE = [conditions_1stLevels.Onsets.BASELINE; conditions_raw.Bas(:,1)+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Duration.BASELINE = [conditions_1stLevels.Duration.BASELINE; conditions_raw.Bas(:,2)-conditions_raw.Bas(:,1)+1];
                conditions_1stLevels.Onsets.NFUp = [conditions_1stLevels.Onsets.NFUp; conditions_raw.NFup(:,1)+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Duration.NFUp = [conditions_1stLevels.Duration.NFUp; conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1];
                conditions_1stLevels.Onsets.NFDown = [conditions_1stLevels.Onsets.NFDown; conditions_raw.NFdown(:,1)+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Duration.NFDown = [conditions_1stLevels.Duration.NFDown; conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1];
            end    
            
           
            
            % load from task logs the decision
            fname_onsets = dir(fullfile(data_preproc_path, ['sub-' mat2str(current_subject)], ['ses-' mat2str(current_session)], 'beh' ,['*task-NFTask_run-' mat2str(indRuns) '_desc-onsets.csv']));
            opts = detectImportOptions(fullfile(fname_onsets.folder, fname_onsets.name)); 
            opts = setvartype(opts, 'char');
            onsets = readtable(fullfile(fname_onsets.folder, fname_onsets.name), opts);
            fname_pmods = dir(fullfile(data_preproc_path, ['sub-' mat2str(current_subject)], ['ses-' mat2str(current_session)], 'beh' ,['*task-NFTask_run-' mat2str(indRuns) '_desc-pmods.csv']));
            opts = detectImportOptions(fullfile(fname_pmods.folder, fname_pmods.name)); 
            opts = setvartype(opts, 'char');
            pmods = readtable(fullfile(fname_pmods.folder, fname_pmods.name), opts);
            if (1 == indRuns)
                %conditions_1stLevels.Onsets.Decisions_accepted = str2double(onsets.accepted_above_0(~isnan(str2double(onsets.accepted_above_0))));
                %conditions_1stLevels.Onsets.Decisions_rejected = str2double(onsets.rejected_below_0(~isnan(str2double(onsets.rejected_below_0))));
                %conditions_1stLevels.Onsets.Others = str2double(onsets.others_regwrong(~isnan(str2double(onsets.others_regwrong))));
                conditions_1stLevels.Onsets.Decisions_up_accepted = str2double(onsets.accepted_above_25(~isnan(str2double(onsets.accepted_above_25))));
                conditions_1stLevels.Onsets.Decisions_up_rejected = str2double(onsets.rejected_above_25(~isnan(str2double(onsets.rejected_above_25))));
                conditions_1stLevels.Onsets.Decisions_down_rejected = str2double(onsets.rejected_below_25(~isnan(str2double(onsets.rejected_below_25))));
                conditions_1stLevels.Onsets.Decisions_down_accepted = str2double(onsets.accepted_below_25(~isnan(str2double(onsets.accepted_below_25))));
                conditions_1stLevels.Onsets.Others = str2double(onsets.others2(~isnan(str2double(onsets.others2))));
            elseif (2 == indRuns)
                %conditions_1stLevels.Onsets.Decisions_accepted = [conditions_1stLevels.Onsets.Decisions_accepted; str2double(onsets.accepted_above_0(~isnan(str2double(onsets.accepted_above_0))))+run_lengths(1)];
                %conditions_1stLevels.Onsets.Decisions_rejected = [conditions_1stLevels.Onsets.Decisions_rejected; str2double(onsets.rejected_below_0(~isnan(str2double(onsets.rejected_below_0))))+run_lengths(1)];
                %conditions_1stLevels.Onsets.Others = [conditions_1stLevels.Onsets.Others; str2double(onsets.others_regwrong(~isnan(str2double(onsets.others_regwrong))))+run_lengths(1)];
                conditions_1stLevels.Onsets.Decisions_up_accepted = [conditions_1stLevels.Onsets.Decisions_up_accepted; str2double(onsets.accepted_above_25(~isnan(str2double(onsets.accepted_above_25))))+run_lengths(1)];
                conditions_1stLevels.Onsets.Decisions_up_rejected = [conditions_1stLevels.Onsets.Decisions_up_rejected; str2double(onsets.rejected_above_25(~isnan(str2double(onsets.rejected_above_25))))+run_lengths(1)];
                conditions_1stLevels.Onsets.Decisions_down_rejected = [conditions_1stLevels.Onsets.Decisions_down_rejected; str2double(onsets.rejected_below_25(~isnan(str2double(onsets.rejected_below_25))))+run_lengths(1)];
                conditions_1stLevels.Onsets.Decisions_down_accepted = [conditions_1stLevels.Onsets.Decisions_down_accepted; str2double(onsets.accepted_below_25(~isnan(str2double(onsets.accepted_below_25))))+run_lengths(1)];
                conditions_1stLevels.Onsets.Others = [conditions_1stLevels.Onsets.Others; str2double(onsets.others2(~isnan(str2double(onsets.others2))))+run_lengths(1)];
            elseif (3 == indRuns)
                %conditions_1stLevels.Onsets.Decisions_accepted = [conditions_1stLevels.Onsets.Decisions_accepted; str2double(onsets.accepted_above_0(~isnan(str2double(onsets.accepted_above_0))))+run_lengths(1)+run_lengths(2)];
                %conditions_1stLevels.Onsets.Decisions_rejected = [conditions_1stLevels.Onsets.Decisions_rejected; str2double(onsets.rejected_below_0(~isnan(str2double(onsets.rejected_below_0))))+run_lengths(1)+run_lengths(2)];
                %conditions_1stLevels.Onsets.Others = [conditions_1stLevels.Onsets.Others; str2double(onsets.others_regwrong(~isnan(str2double(onsets.others_regwrong))))+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Onsets.Decisions_up_accepted = [conditions_1stLevels.Onsets.Decisions_up_accepted; str2double(onsets.accepted_above_25(~isnan(str2double(onsets.accepted_above_25))))+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Onsets.Decisions_down_rejected = [conditions_1stLevels.Onsets.Decisions_down_rejected; str2double(onsets.rejected_below_25(~isnan(str2double(onsets.rejected_below_25))))+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Onsets.Decisions_up_rejected = [conditions_1stLevels.Onsets.Decisions_up_rejected; str2double(onsets.rejected_above_25(~isnan(str2double(onsets.rejected_above_25))))+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Onsets.Decisions_down_accepted = [conditions_1stLevels.Onsets.Decisions_down_accepted; str2double(onsets.accepted_below_25(~isnan(str2double(onsets.accepted_below_25))))+run_lengths(1)+run_lengths(2)];
                conditions_1stLevels.Onsets.Others = [conditions_1stLevels.Onsets.Others; str2double(onsets.others2(~isnan(str2double(onsets.others2))))+run_lengths(1)+run_lengths(2)];
            end
            conditions_1stLevels.Duration.Decisions_up_accepted = 0;
            conditions_1stLevels.Duration.Decisions_up_rejected = 0;
            %conditions_1stLevels.Pmods.Decisions_accepted = [conditions_1stLevels.Pmods.Decisions_accepted; str2double(pmods.accepted_above_0(~isnan(str2double(pmods.accepted_above_0))))];
            conditions_1stLevels.Pmods.Decisions_up_accepted = [conditions_1stLevels.Pmods.Decisions_up_accepted; str2double(pmods.accepted_above_25(~isnan(str2double(pmods.accepted_above_25))))];
            conditions_1stLevels.Pmods.Decisions_up_rejected = [conditions_1stLevels.Pmods.Decisions_up_rejected; str2double(pmods.rejected_above_25(~isnan(str2double(pmods.rejected_above_25))))];
            conditions_1stLevels.Duration.Decisions_down_rejected = 0;
            conditions_1stLevels.Duration.Decisions_down_accepted = 0;
            %conditions_1stLevels.Pmods.Decisions_rejected = [conditions_1stLevels.Pmods.Decisions_rejected; str2double(pmods.rejected_below_0(~isnan(str2double(pmods.rejected_below_0))))];
            conditions_1stLevels.Pmods.Decisions_down_rejected = [conditions_1stLevels.Pmods.Decisions_down_rejected; str2double(pmods.rejected_below_25(~isnan(str2double(pmods.rejected_below_25))))];
            conditions_1stLevels.Pmods.Decisions_down_accepted = [conditions_1stLevels.Pmods.Decisions_down_accepted; str2double(pmods.accepted_below_25(~isnan(str2double(pmods.accepted_below_25))))];
            conditions_1stLevels.Duration.Others = 0;
            %conditions_1stLevels.Pmods.Others = [conditions_1stLevels.Pmods.Others; str2double(pmods.others_regwrong(~isnan(str2double(pmods.others_regwrong))))];
            conditions_1stLevels.Pmods.Others = [conditions_1stLevels.Pmods.Others; str2double(pmods.others2(~isnan(str2double(pmods.others2))))];
                
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

        bool_include_regulations = 1;
        bool_restimplicit = 1;
        substract_regulations = 0;
        if (1 == bool_include_regulations && 0 == bool_restimplicit)
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'REST';
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = conditions_1stLevels.Onsets.BASELINE;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = conditions_1stLevels.Duration.BASELINE;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;

            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'NFup';
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = conditions_1stLevels.Onsets.NFUp;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = conditions_1stLevels.Duration.NFUp;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;

            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name = 'NFDown';
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset = conditions_1stLevels.Onsets.NFDown;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = conditions_1stLevels.Duration.NFDown;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).orth = 1;
            substract_regulations = 0;
        elseif (1 == bool_include_regulations && 1 == bool_restimplicit)
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'NFup';
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = conditions_1stLevels.Onsets.NFUp;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = conditions_1stLevels.Duration.NFUp;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;

            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'NFDown';
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = conditions_1stLevels.Onsets.NFDown;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = conditions_1stLevels.Duration.NFDown;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;
            substract_regulations = 1;
        else
            substract_regulations = 3;
        end
            %%
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4-substract_regulations).name = 'UP_accepted';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4-substract_regulations).onset = conditions_1stLevels.Onsets.Decisions_up_accepted;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4-substract_regulations).duration = conditions_1stLevels.Duration.Decisions_up_accepted;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4-substract_regulations).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4-substract_regulations).pmod = struct('name', 'FB',...
            'param', conditions_1stLevels.Pmods.Decisions_up_accepted,...
            'poly', 1);
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4-substract_regulations).orth = 1;
        
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5-substract_regulations).name = 'DOWN_rejected';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5-substract_regulations).onset = conditions_1stLevels.Onsets.Decisions_down_rejected;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5-substract_regulations).duration = conditions_1stLevels.Duration.Decisions_down_rejected;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5-substract_regulations).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5-substract_regulations).pmod = struct('name', 'FB',...
            'param', conditions_1stLevels.Pmods.Decisions_down_rejected,...
            'poly', 1);
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5-substract_regulations).orth = 1;
        

        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(6-substract_regulations).name = 'UP_rejected';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(6-substract_regulations).onset = conditions_1stLevels.Onsets.Decisions_up_rejected;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(6-substract_regulations).duration = conditions_1stLevels.Duration.Decisions_up_rejected;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(6-substract_regulations).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(6-substract_regulations).pmod = struct('name', 'FB',...
            'param', conditions_1stLevels.Pmods.Decisions_up_rejected,...
            'poly', 1);
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(6-substract_regulations).orth = 1;
                
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(7-substract_regulations).name = 'DOWN_accepted';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(7-substract_regulations).onset = conditions_1stLevels.Onsets.Decisions_down_accepted;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(7-substract_regulations).duration = conditions_1stLevels.Duration.Decisions_down_accepted;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(7-substract_regulations).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(7-substract_regulations).pmod = struct('name', 'FB',...
            'param', conditions_1stLevels.Pmods.Decisions_down_accepted,...
            'poly', 1);
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(7-substract_regulations).orth = 1;
                
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(8-substract_regulations).name = 'Others';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(8-substract_regulations).onset = conditions_1stLevels.Onsets.Others;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(8-substract_regulations).duration = conditions_1stLevels.Duration.Others;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(8-substract_regulations).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(8-substract_regulations).pmod = struct('name', 'FB',...
            'param', conditions_1stLevels.Pmods.Others,...
            'poly', 1);
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(8-substract_regulations).orth = 1;
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
        current_nr_of_regressors = 13-substract_regulations;
        matlabbatch{4} = struct();
        matlabbatch{4}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
       
        matlabbatch{4}.spm.stats.con.consess{1}.fcon.name = 'eoi';
        matlabbatch{4}.spm.stats.con.consess{1}.fcon.weights = [eye(current_nr_of_regressors) zeros(current_nr_of_regressors,current_nr_of_physio_regressors)];
        matlabbatch{4}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
        
        if (1 == bool_include_regulations && 0 == bool_restimplicit)
            contrast_basic_names = {'UP-REST','DOWN-REST', 'REST-DOWN',...
                                    'UP_ACCEPTED-REST','DOWN_REJECTED-REST','UP_REJECTED-REST', 'DOWN_ACCEPTED-REST','REST-DOWN_REJECTED', 'REST-DOWN_ACCEPTED',...
                                    'PMOD_UP_ACCEPTED', 'PMOD_DOWN_REJECTED', 'PMOD_UP_REJECTED', 'PMOD_DOWN_ACCEPTED',...
                                    'UP_ACC-REJ', 'DOWN_ACC-REJ', 'PMOD_UP_ACC-REJ', 'PMOD_DOWN_ACC-REJ'};
            contrast_weights = {[-1 1 0 0 0 0 0 0 0 0 0 0 0], [-1 0 1 0 0 0 0 0 0 0 0 0 0], [1 0 -1 0 0 0 0 0 0 0 0 0 0],...
                                [-1 0 0 1 0 0 0 0 0 0 0 0 0], [-1 0 0 0 0 1 0 0 0 0 0 0 0], [-1 0 0 0 0 0 0 1 0 0 0 0 0], [-1 0 0 0 0 0 0 0 0 1 0 0 0], [1 0 0 0 0 -1 0 0 0 0 0 0 0], [1 0 0 0 0 0 0 0 0 -1 0 0 0],...
                                [0 0 0 0 1 0 0 0 0 0 0 0 0],  [0 0 0 0 0 0 1 0 0 0 0 0 0],  [0 0 0 0 0 0 0 0 1 0 0 0 0],  [0 0 0 0 0 0 0 0 0 0 1 0 0],...
                                [0 0 0 1 0 0 0 -1 0 0 0 0 0], [0 0 0 0 0 -1 0 0 0 1 0 0 0], [0 0 0 0 1 0 0 0 -1 0 0 0 0], [0 0 0 0 0 0 -1 0 0 0 1 0 0]};
        elseif (1 == bool_include_regulations && 1 == bool_restimplicit)
            contrast_basic_names = {'UP-REST','DOWN-REST', 'REST-DOWN',...
                                    'UP_ACCEPTED-REST','DOWN_REJECTED-REST','UP_REJECTED-REST', 'DOWN_ACCEPTED-REST','REST-DOWN_REJECTED', 'REST-DOWN_ACCEPTED',...
                                    'PMOD_UP_ACCEPTED', 'PMOD_DOWN_REJECTED', 'PMOD_UP_REJECTED', 'PMOD_DOWN_ACCEPTED',...
                                    'UP_ACC-REJ', 'DOWN_ACC-REJ', 'PMOD_UP_ACC-REJ', 'PMOD_DOWN_ACC-REJ'};
            contrast_weights = {[1 0 0 0 0 0 0 0 0 0 0 0], [0 1 0 0 0 0 0 0 0 0 0 0], [0 -1 0 0 0 0 0 0 0 0 0 0],...
                                [0 0 1 0 0 0 0 0 0 0 0 0], [0 0 0 0 1 0 0 0 0 0 0 0], [0 0 0 0 0 0 1 0 0 0 0 0], [0 0 0 0 0 0 0 0 1 0 0 0], [0 0 0 0 -1 0 0 0 0 0 0 0], [0 0 0 0 0 0 0 0 -1 0 0 0],...
                                [0 0 0 1 0 0 0 0 0 0 0 0],  [0 0 0 0 0 1 0 0 0 0 0 0],  [0 0 0 0 0 0 0 1 0 0 0 0],  [0 0 0 0 0 0 0 0 0 1 0 0],...
                                [0 0 1 0 0 0 -1 0 0 0 0 0], [0 0 0 0 -1 0 0 0 1 0 0 0], [0 0 0 1 0 0 0 -1 0 0 0 0], [0 0 0 0 0 -1 0 0 0 1 0 0]};
        
        elseif (0 == bool_include_regulations)
            contrast_basic_names = {'UP_ACCEPTED','DOWN_REJECTED','UP_REJECTED', 'DOWN_ACCEPTED', 'PMOD_UP_ACCEPTED', 'PMOD_DOWN_REJECTED', 'PMOD_UP_REJECTED', 'PMOD_DOWN_ACCEPTED', 'UP_ACC-REJ', 'DOWN_ACC-REJ'};
            contrast_weights = {[1 0 0 0 0 0 0 0 0 0], [0 0 1 0 0 0 0 0 0 0], [0 0 0 0 1 0 0 0 0 0], [0 0 0 0 0 0 1 0 0 0], [0 1 0 0 0 0 0 0 0 0], [0 0 0 1 0 0 0 0 0 0], [0 0 0 0 0 1 0 0 0 0], [0 0 0 0 0 0 0 1 0 0], [1 0 -1 0 0 0 0 0 0 0], [0 -1 0 1 0 0 0 0 0 0]};
        end
        contrast_index = 1;
        for indContrast = 1:numel(contrast_basic_names)
            contrast_index = contrast_index + 1;
            contrast_name = sprintf('%s%d', cell2mat(contrast_basic_names(indContrast)), indRuns);
            matlabbatch{4}.spm.stats.con.consess{contrast_index}.tcon.name = contrast_name;
            weight = [cell2mat(contrast_weights(indContrast)) zeros(1, current_nr_of_physio_regressors)];
            matlabbatch{4}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
            matlabbatch{4}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        end
        
        
        batch_file_name = strcat('firstLev_batch_NFTask_regulation_and_decisions_upar_downar_concat.mat');
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

