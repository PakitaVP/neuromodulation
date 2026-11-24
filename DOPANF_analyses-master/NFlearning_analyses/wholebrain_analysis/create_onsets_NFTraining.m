function create_onsets_NFTraining()

    %Base dir containing subject folders
    baseDir = '';
    
    % define folders according to analysis
    
    data_input_path = '';
    current_path = pwd;
    if (1 == ismac)
        addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/bids-matlab'));
        addpath(genpath('/Users/lhellr/Just\ Data/Development/fmrwhy'));
        data_bids_path = '/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA';
        data_preproc_path = '/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc';
    elseif (1 == ispc)
        addpath(genpath('C:\Users\lhellr\Documents\MATLAB\Add-Ons\Toolboxes\bids-matlab'));
        addpath(genpath('C:\Development\fMRwhy\fmrwhy'));
        data_bids_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA';
        data_preproc_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc';
    end
    
    % subjects
    BIDS_dataset = bids.layout(data_bids_path);
    subjects_dataset = bids.query(BIDS_dataset, 'subjects');
    nr_of_sessions = bids.query(BIDS_dataset, 'sessions');
    
    % what to do
    bool_do_create_onset_files = 1;
    
    % 
    if (1 == bool_do_create_onset_files)
        extract_onsets(data_preproc_path, data_bids_path, subjects_dataset, nr_of_sessions);
    end


    
end