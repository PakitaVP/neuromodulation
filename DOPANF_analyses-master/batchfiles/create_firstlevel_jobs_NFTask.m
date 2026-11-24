function [jobfiles] = create_firstlevel_jobs_NFTask(data_preproc_path, data_bids_path, stat_dir, first_level_folder, table_firstlevel_subjects, bool_overwrite_1stlevels, tParams)

% load the template
matlabbatch = firstlevel_NFTask_template();

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
            conditions_1stLevels = struct();
            % load all params for conditions in 1st level analysis -
            % on/offsets and duration for all available conditions
            % they need to be re-formatted and/or combined with additional
            % information from task logs (decision behavior)
            % load from condsOnOff file raw information of conditions
            fname_conditions = dir(fullfile(data_bids_path, ['sub-' mat2str(current_subject)], ['ses-' mat2str(current_session)], 'beh' ,['*_run-' mat2str(indRuns) '_condsOnOff_beh_task-NFAdapt.json']));
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
            fname_onsets = dir(fullfile(data_preproc_path, ['sub-' mat2str(current_subject)], ['ses-' mat2str(current_session)], 'beh' ,['*task-NFTask_run-' mat2str(indRuns) '_desc-onsets.csv']));
            opts = detectImportOptions(fullfile(fname_onsets.folder, fname_onsets.name)); 
            opts = setvartype(opts, 'char');
            onsets = readtable(fullfile(fname_onsets.folder, fname_onsets.name), opts);
            fname_pmods = dir(fullfile(data_preproc_path, ['sub-' mat2str(current_subject)], ['ses-' mat2str(current_session)], 'beh' ,['*task-NFTask_run-' mat2str(indRuns) '_desc-pmods.csv']));
            opts = detectImportOptions(fullfile(fname_pmods.folder, fname_pmods.name)); 
            opts = setvartype(opts, 'char');
            pmods = readtable(fullfile(fname_pmods.folder, fname_pmods.name), opts);
            %conditions_1stLevels.Onsets.Decisions_accepted = str2double(onsets.accepted_above_25(~isnan(str2double(onsets.accepted_above_25))));
            conditions_1stLevels.Onsets.Decisions_accepted = str2double(onsets.accepted_above_0(~isnan(str2double(onsets.accepted_above_0))));
            %conditions_1stLevels.Onsets.Decisions_accepted = str2double(onsets.accepted_all(~isnan(str2double(onsets.accepted_all))));
            conditions_1stLevels.Duration.Decisions_accepted = 0;
            
            %conditions_1stLevels.Pmods.Decisions_accepted = str2double(pmods.accepted_above_25(~isnan(str2double(pmods.accepted_above_25))));
            conditions_1stLevels.Pmods.Decisions_accepted = str2double(pmods.accepted_above_0(~isnan(str2double(pmods.accepted_above_0))));
            %conditions_1stLevels.Pmods.Decisions_accepted = str2double(pmods.accepted_all(~isnan(str2double(pmods.accepted_all))));
            
            %conditions_1stLevels.Onsets.Decisions_rejected = str2double(onsets.rejected_below_25(~isnan(str2double(onsets.rejected_below_25))));
            conditions_1stLevels.Onsets.Decisions_rejected = str2double(onsets.rejected_below_0(~isnan(str2double(onsets.rejected_below_0))));
            %conditions_1stLevels.Onsets.Decisions_rejected = str2double(onsets.rejected_all(~isnan(str2double(onsets.rejected_all))));
            conditions_1stLevels.Duration.Decisions_rejected = 0;
            
            %conditions_1stLevels.Pmods.Decisions_rejected = str2double(pmods.rejected_below_25(~isnan(str2double(pmods.rejected_below_25))));
            conditions_1stLevels.Pmods.Decisions_rejected = str2double(pmods.rejected_below_0(~isnan(str2double(pmods.rejected_below_0))));
            %conditions_1stLevels.Pmods.Decisions_rejected = str2double(pmods.rejected_all(~isnan(str2double(pmods.rejected_all))));
                        
            conditions_1stLevels.Onsets.Others = str2double(onsets.others(~isnan(str2double(onsets.others_regwrong))));
            conditions_1stLevels.Duration.Others = 0;
            conditions_1stLevels.Pmods.Others = str2double(pmods.others(~isnan(str2double(pmods.others_regwrong))));
            
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
            confounds_regressor = [motion_regressors physio_regressors];
            [outfilename, outfilepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'NFTask', 'run', mat2str(indRuns), 'desc', 'confounds', 'ext', '_motionphysio.txt');
            writetable(confounds_regressor, fullfile(data_preproc_path, outfilepath, outfilename), 'FileType', 'text', 'Delimiter','\t', 'WriteVariableNames',0);
            
            
            
            %########################
            
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
            
            % load preprocessed file and put into structure
            
            [filename, filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'NFTask', 'run', mat2str(indRuns), 'desc', 'swrapreproc', 'ext', '_bold.nii');
            
            files = spm_select('ExtFPList', fullfile(data_preproc_path, filepath), filename,Inf);
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).scans = cellstr(files);
            
            
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
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(4).pmod = struct('name', 'FB',...
                                                                                   'param', conditions_1stLevels.Pmods.Decisions_accepted,...
                                                                                   'poly', 1);
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(4).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).hpf = 128;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).name = 'Decision_rejected';
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).onset = conditions_1stLevels.Onsets.Decisions_rejected;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).duration = conditions_1stLevels.Duration.Decisions_rejected;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).pmod = struct('name', 'FB',...
                                                                                   'param', conditions_1stLevels.Pmods.Decisions_rejected,...
                                                                                   'poly', 1);
             matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(5).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).hpf = 128;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(6).name = 'Others';
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(6).onset = conditions_1stLevels.Onsets.Others;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(6).duration = conditions_1stLevels.Duration.Others;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(6).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(6).pmod = struct('name', 'FB',...
                                                                                   'param', conditions_1stLevels.Pmods.Others,...
                                                                                   'poly', 1);
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).cond(6).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).hpf = 128;

            
            % load multiple regressors? if yes, then do it
            if strcmp(tParams.motion_regress,'yes')
                [confounds_filename, confounds_filepath] = fmrwhy_bids_constructFilename('func', 'sub', mat2str(current_subject), 'ses', mat2str(current_session), 'task', 'NFTask', 'run', mat2str(indRuns), 'desc', 'confounds', 'ext', '_motionphysio.txt');
                reg_file = spm_select('FPList', fullfile(data_preproc_path,confounds_filepath,confounds_filename));
            else
                reg_file = [];
            end
            matlabbatch{1}.spm.stats.fmri_spec.sess(indRuns).multi_reg = {fullfile(data_preproc_path,confounds_filepath,confounds_filename)};
        end
        
        % define the contrasts
        current_nr_of_regressors = 9;
        current_nr_of_physio_regressors = 16;
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'eoi';
        if (1 == current_available_runs)
            matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [eye(current_nr_of_regressors) zeros(current_nr_of_regressors,current_nr_of_runs*current_nr_of_physio_regressors+(current_nr_of_runs-1)*current_nr_of_regressors)];
        elseif (2 == current_available_runs)
            matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [eye(current_nr_of_regressors) ...
                                                                    zeros(current_nr_of_regressors,current_nr_of_runs*current_nr_of_physio_regressors+(current_nr_of_runs-1)*current_nr_of_regressors);...
                                                                    zeros(current_nr_of_regressors,current_nr_of_physio_regressors+current_nr_of_regressors)...
                                                                    eye(current_nr_of_regressors)...
                                                                    zeros(current_nr_of_regressors,current_available_runs*current_nr_of_physio_regressors+current_nr_of_regressors)];
        elseif (3 == current_available_runs)
            matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [eye(current_nr_of_regressors)...
                                                                    zeros(current_nr_of_regressors,current_nr_of_runs*current_nr_of_physio_regressors+(current_nr_of_runs-1)*current_nr_of_regressors);...
                                                                    zeros(current_nr_of_regressors,current_nr_of_physio_regressors+current_nr_of_regressors)...
                                                                    eye(current_nr_of_regressors)...
                                                                    zeros(current_nr_of_regressors,(current_available_runs-1)*current_nr_of_physio_regressors+current_nr_of_regressors);...
                                                                    zeros(current_nr_of_regressors,(current_available_runs-1)*current_nr_of_physio_regressors+(current_available_runs-1)*current_nr_of_regressors)...
                                                                    eye(current_nr_of_regressors)...
                                                                    zeros(current_nr_of_regressors,current_nr_of_physio_regressors);...
                                                                    zeros(current_nr_of_regressors,current_nr_of_runs*current_nr_of_physio_regressors+(current_nr_of_runs-1)*current_nr_of_regressors+current_nr_of_regressors)];
        end
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
        
        contrast_basic_names = {'NFUP-NFBL', 'NFDOWN-NFBL', 'NFBL-NFDOWN', 'NFUP-NFDOWN', 'ACCEPT-DECLINE', 'PMOD_ACCEPT-DECLINE'};
        contrast_weights = {[-1 1 0 0 0 0 0 0 0], [-1 0 1 0 0 0 0 0 0], [1 0 -1 0 0 0 0 0 0], [0 1 -1 0 0 0 0 0 0], [0 0 0 1 0 -1 0 0 0], [0 0 0 0 1 0 -1 0 0]};
        %contrast_weights = {[-1 1 0 0 0 0 0 ], [-1 0 1 0 0 0 0 ], [1 0 -1 0 0 0 0 ], [0 1 -1 0 0 0 0 ], [0 0 0 1 0 -1 0], [0 0 0 0 1 0 -1]};
        contrast_index = 1;
        for indContrast = 1:numel(contrast_basic_names)
            for indRuns = 1:current_available_runs
                contrast_index = (indContrast -1 )* current_available_runs + indRuns + 1;
                contrast_name = sprintf('%s%d', cell2mat(contrast_basic_names(indContrast)), indRuns);
                matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = contrast_name;
                weight = [zeros(1, (indRuns-1)*current_nr_of_physio_regressors) zeros(1, (indRuns-1)*current_nr_of_regressors) cell2mat(contrast_weights(indContrast)) zeros(1, (numel(current_session)-indRuns+1)*current_nr_of_physio_regressors + (numel(current_session)-indRuns)*current_nr_of_regressors)];
                matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
                matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
            end
        end
        
        % add contrasts over all runs at the end
        contrast_index = contrast_index + 1;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'ACCEPT-DECLINE_allruns';
        con_vec = [0 0 0 1 0 -1 0 0 0];
        if (1 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (2 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (3 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,16) con_vec zeros(1,current_nr_of_physio_regressors)];
        end
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        
        contrast_index = contrast_index + 1;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'PMOD_ACCEPT-DECLINE_allruns';
        con_vec = [0 0 0 0 1 0 -1 0 0];
        if (1 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (2 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (3 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        end
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        
        contrast_index = contrast_index + 1;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'NFUP-NFBL_allruns';
        con_vec = [-1 1 0 0 0 0 0 0 0];
        if (1 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (2 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (3 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        end
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        
        contrast_index = contrast_index + 1;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'NFDOWN-NFBL_allruns';
        con_vec = [-1 0 1 0 0 0 0 0 0];
        if (1 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (2 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (3 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,16) con_vec zeros(1,current_nr_of_physio_regressors)];
        end
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        
        contrast_index = contrast_index + 1;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'NFBL-NFDOWN_allruns';
        con_vec = [1 0 -1 0 0 0 0 0 0];
        if (1 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (2 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (3 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        end
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        
        contrast_index = contrast_index + 1;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'NFUP-NFDOWN_allruns';
        con_vec = [0 1 -1 0 0 0 0 0 0];
        if (1 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (2 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        elseif (3 == current_available_runs)
            weight = [con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
        end
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
        
        
        batch_file_name = strcat('firstLev_batch_NFTask_decision_regright.mat');
        if (~exist(current_stat_dir, 'dir'))
            mkdir(current_stat_dir);
            save(fullfile(current_stat_dir,batch_file_name),'matlabbatch');
            jobfiles(indSubjects) = {fullfile(current_stat_dir,batch_file_name)};
        elseif (0 == bool_overwrite_1stlevels && exist(current_stat_dir, 'dir'))
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

