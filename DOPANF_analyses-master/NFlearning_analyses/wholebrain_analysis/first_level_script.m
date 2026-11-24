function create_onsets_NFTraining()

    % 1st Level stats for DOPANF
    %

    addpath('/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/preproc_playground');

    %Base dir containing subject folders
    baseDir = '';
    
    % define folders according to analysis
    
    data_input_path = '';
    current_path = pwd;
    if (1 == ismac)
        addpath(genpath('/Users/malimaurer/Documents/MATLAB/zusaetzlich/bids-matlab'));
        addpath(genpath('/Users/malimaurer/Documents/Development/fMRwhy'));
        data_bids_path = '/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA';
        data_preproc_path = '/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/preproc_playground';
    elseif (1 == ispc)
        addpath(genpath('C:/Users/malimaurer/Documents/MATLAB/zusaetzlich/bids-matlab'));
        addpath(genpath('C:\Development\fMRwhy\fmrwhy'));
        data_bids_path = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA';
        data_preproc_path = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/preproc_playground';
    end
    
    % subjects
    BIDS_dataset = bids.layout(data_bids_path);
    subjects_dataset = bids.query(BIDS_dataset, 'subjects');
    nr_of_sessions = bids.query(BIDS_dataset, 'sessions');
    
    for indSubjects = 1:numel(subjects_dataset)
    
    current_subject = subjects_dataset{indSubjects};
    current_nr_of_runs = [5 4];
    
   
    %% 
    for indSessions = 1:numel(nr_of_sessions)
        for indRuns = 1:current_nr_of_runs(indSessions)
            
            matlabbatch{1}.spm.stats.fmri_spec.dir = {'/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/preproc_playground'};
            matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
            matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
            matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
            matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

                                %%
            % load onset/duration files
            onsets = readtable('/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/preproc_playground/sub-34697/ses-1/beh/sub-34697_ses-1_task-NFTraining_run-1_desc-onsets.csv');
            durations = readtable('/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/preproc_playground/sub-34697/ses-1/beh/sub-34697_ses-1_task-NFTraining_run-1_desc-durations.csv');
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = onsets.BASELINE(~isnan(onsets.BASELINE));
            %%
            %%
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = durations.BASELINE(~isnan(durations.BASELINE));
            %%
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'UP';
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = onsets.NFUp(~isnan(onsets.NFUp));
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = durations.NFUp(~isnan(durations.NFUp));
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name = 'FIX';
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset = onsets.Fix(~isnan(onsets.Fix));
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = durations.Fix(~isnan(durations.Fix));
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).name = 'DOWN';
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).onset = onsets.NFDown(~isnan(onsets.NFDown));
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).duration = durations.NFDown(~isnan(durations.NFDown));
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).orth = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {'/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/preproc_playground/sub-34697/ses-1/func/rp_temp_sub-34697_ses-1_task-NFTraining_run-1_bold.txt'};
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;

