function first_level_batch()

    % 1st Level stats for DOPANF
    %

    addpath('../utils');
    %Base dir containing subject folders
    baseDir = '';
    global spmpath;

    tasks_to_analyze = {'NFTask'};
   
    % define folders according to analysis
    if (strcmp(tasks_to_analyze, 'BLTask'))
        analysis_folder = 'task-BLTask';
        first_level_folder = 'stats_task-BLTask_basic_decisions_splitted';
    elseif (strcmp(tasks_to_analyze, 'NFTask'))
        analysis_folder = 'task-NFTask';
        first_level_folder = 'stats_task-NFTask_regulation_and_decisions_upar_downar_concat_restimplicit';
    else
       disp('Which task shall be analyzed???')
       return;
    end
    
    data_input_path = '';
    analysis_path = '';
    current_path = pwd;
    if (1 == ismac)
        addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/bids-matlab'));
        spmpath = '/Users/lhellr/Documents/MATLAB/AdditionalStuff/spm12';
        addpath(genpath('/Volumes/JustData/Development/fMRwhy/fmrwhy'));
        data_bids_path = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA';
        data_input_path = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc';
        analysis_path = fullfile('/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats', analysis_folder);

    elseif (1 == ispc)
        addpath(genpath('C:\Users\lhellr\Documents\MATLAB\Toolboxes\bids-matlab'));
        addpath(genpath('C:\Development\fMRwhy\fmrwhy'));
        spmpath = 'C:\Users\lhellr\Documents\MATLAB\Toolboxes\spm12';
        data_bids_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA';
        data_input_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc';
        analysis_path = fullfile('Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats', analysis_folder);
    end
    addpath(spmpath);


    
    % subjects
    BIDS_dataset = bids.layout(data_bids_path);
    subjects_dataset = bids.query(BIDS_dataset, 'subjects');
    
    table_firstlevel_subjects = [];
    if (any(strcmp(tasks_to_analyze, 'NFTask')))
        table_firstlevel_subjects = readtable(fullfile(current_path, '../NFTask_only_firstlevel_subjects.csv'));
    elseif (any(strcmp(tasks_to_analyze, 'BLTask')))
        table_firstlevel_subjects = readtable(fullfile(current_path, '../BLTask_only_firstlevel_subjects.csv'));
    end
    subjects = intersect(str2num(vertcat(subjects_dataset{:})), table_firstlevel_subjects.subjectID_BIDS);
    
    
    % what to do
    bool_do_create_jobfiles = 1;
    bool_do_run_jobfiles = 1;
    bool_append_contrast = 0;
    bool_overwrite_1stlevels = 0;
    bool_change_path = 0;

    % params for analysis
    params.motion_regress = 'yes';
    params.TR = 2;
    params.mic_res = 16;
    params.mic_onset = 8;

    % initialise spm
    spm('defaults', 'fmri');
    spm_get_defaults('stats.maxmem', 2^32);

    % create job files
    jobfiles = {};
    if (1 == bool_do_create_jobfiles)
        
        if (any(strcmp(tasks_to_analyze, 'NFTask')))
            %jobfiles = create_firstlevel_jobs_NFTask(data_input_path, data_bids_path, analysis_path, first_level_folder, table_firstlevel_subjects, bool_overwrite_1stlevels, params );
            jobfiles = create_firstlevel_jobs_NFTask_regulation_and_decisions_concat(data_input_path, data_bids_path, analysis_path, first_level_folder, table_firstlevel_subjects, bool_overwrite_1stlevels, params );
        elseif (any(strcmp(tasks_to_analyze, 'BLTask')))
            jobfiles = create_firstlevel_jobs_BLTask(data_input_path, data_bids_path, analysis_path, first_level_folder, table_firstlevel_subjects, bool_overwrite_1stlevels, params );
        end
        
    else
        % just load available jobfiles
        % save mat file and run job
        jobfiles = cell(numel(subjects),1);
        
        for indSubjects = 1:numel(subjects)
            current_stat_dir = fullfile(analysis_path, first_level_folder, ['sub-' num2str(subjects(indSubjects))]);
            batch_file_name = dir(fullfile(current_stat_dir, 'firstLev_batch_NFTask_regulation_and_decisions_upar_downar_concat.mat'));
            if (1 == bool_overwrite_1stlevels && 2 == exist(fullfile(current_stat_dir, 'SPM.mat'), 'file'))
                delete(fullfile(current_stat_dir,'SPM.mat'));
            elseif(0 == bool_overwrite_1stlevels && 2 == exist(fullfile(current_stat_dir, 'SPM.mat'), 'file'))
                batch_file_name='';
            end
            if (0 == isempty(batch_file_name))
                jobfiles(indSubjects) = {fullfile(batch_file_name.folder,batch_file_name.name)};
            else
                jobfiles(indSubjects) = {''};
            end
            celldisp(jobfiles);
        end
    end

    % run jobfiles
    if (1 == bool_do_run_jobfiles)
        for indJob = 1:numel(jobfiles)
            if (0 == isempty(jobfiles{indJob}))
                fprintf('%s', char(jobfiles(indJob)));
                spm_jobman ('run',jobfiles(indJob));
            end
        end
    end

    % change path in all SPM design files
    if (1 == bool_change_path)
        for indSubjects = 1:numel(subjects)
            current_stat_dir = fullfile(analysis_path, first_level_folder, ['sub-' num2str(subjects(indSubjects))]);
            if (2 == exist(fullfile(current_stat_dir, 'SPM.mat'), 'file'))
                spm_changepath('SPM.mat','Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc\DOPANF_stats\task-NFTask\stats_task-NFTask_regulations_and_decisions_concat','Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTask\stats_task-NFTask_regulations_and_decisions_concat');
            end
        end
    end
        

   
end

