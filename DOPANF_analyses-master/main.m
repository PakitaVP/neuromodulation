function main()
    
   
    addpath('utils', 'batchfiles');
    current_OS = OS.MACOS;
    
    %Base dir containing subject folders
    baseDir = '';
    global spmpath;

    
    if ("MACOS" == current_OS)
        addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/bids-matlab'));
        spmpath = '/Users/lhellr/Documents/MATLAB/AdditionalStuff/spm12';
        baseDir = '//Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_PREPROC';
    elseif ("WINDOWS" == current_OS)
        addpath(genpath('C:\Users\lhellrung\Documents\MATLAB\Add-Ons\Toolboxes\bids-matlab'));
        spmpath = 'C:\Users\lhellrung\Documents\MATLAB\Add-Ons\Toolboxes\spm12';
        baseDir = '\\lhnas.econ.uzh.ch\JustData\Projects\DOPANF\Data\DOPANF_PREPROC';   
    end
        addpath(genpath(spmpath));

    

    BIDS_folder = bids.layout(baseDir);
    participants_list = bids.query(BIDS_folder, 'subjects');
    %current_filelist = dir(fullfile(BIDS_folder.dir,'*'));
    %current_filelist = current_filelist(~([current_filelist.isdir]));
    %temp_namelist = {current_filelist.name};
    %temp_namelist(startsWith(temp_namelist, '.')) = [];   % removes files starting with . 
    % processing options
    % {'VDM', 'SLICETIME', 'REALIGN', 'SEGMENT', 'NORMALIZE', 'SMOOTH', 'PHYSIO'}
    whatToDo =  {'SEGMENT'}; % , 'PHYSIO'}; %  {'VDM', 'SLICETIME', 'REALIGN'};

    % parallelization
    paralellize_sessions = false; % if false, then only paralelizing per subject
    workers = 5; % number of workers for matlab parpool parallel processing
    
    %% SEGMENTATION (done before all other processing for each subject
    new_processing_list = {};
    for indParticipant=1:length(participants_list) % TODO: possibly parfor
        
        current_anat_file = bids.query(BIDS_folder,'data','sub',participants_list{indParticipant},'type','T1w');

        % check if T1 exists and get filename
        if isempty(current_anat_file{1}) && any(strcmp(whatToDo, 'SEGMENT'))
            ME = MException('myerror:filenotfounderror', 'T1 file not found. You have specified SEGMENT in the processing list, but for this the T1 is required. Check you ana directory for the T1 file.');
            throw(ME);
        end
        assert(length(current_anat_file)==1, "no t1 found or several matching files");
        
        [t1_path,t1_file,t1_ext] = fileparts(current_anat_file{1});
        
        % PROCESS T1 (if necessary)
        if exist(fullfile(t1_path, ['y_' strcat(t1_file,t1_ext)]), 'file') && exist(fullfile(t1_path, 'Brain.nii'), 'file')
            disp("segment exists already");
        else
            disp("segment does not exist so far");
            if any(strcmp(whatToDo, 'SEGMENT')) % RUN SEGMENT
                disp("Run segment for subject ");
                disp(participants_list(indParticipant));
                run_segment(t1_path, strcat(t1_file,t1_ext));
                disp("Finished segment");
            elseif ~any(strcmp(whatToDo, 'SEGMENT')) && (any(strcmp(whatToDo, 'SMOOTH')) || any(strcmp(whatToDo, 'NORMALIZE')))
                ME = MException('myerror:filenotfounderror', 'Segmented T1 does not exist so far. However, you have specified SMOOTH or NORMALIZE in the processing list which depend on SEGMENT. Please add SEGMENT to processing list or delete NORMALIZE/SMOOTH from it.');
                throw(ME);
            end
        end
%######################
%         % make list of subject-session pairs with additional infos
%         for j=1:length(sessions)
%             info_obj.t1_path = t1_path;
%             info_obj.t1_file = strcat(t1_file,t1_ext);
%             sess_row = subject_rows(strcmp(subject_rows.Session, sessions(j)),:);
%             info_obj.runs = [sess_row.EPI_Run1, sess_row.EPI_Run2, sess_row.EPI_Run3];
%             info_obj.fmaps = [sess_row.EPI_Fieldmap_Magnitude_Run1, sess_row.EPI_Fieldmap_Phase_Run1];
%             subj_sess_entry = {subjectID, sessions(j), info_obj}; % string array % new_val = [char(subjectID) ' ' char(sessions(j)) ' ' char(t1_path) ' ' char(t1_file)];
%             new_processing_list{c} = subj_sess_entry;
%             c = c+1;
%         end
    end

    tic;
    %% RUN PREPROCESSING
    % either in parallel over sessions
    if paralellize_sessions        
        % possibly parfor --> parellizing sessions
        parfor(indParticipant=1:length(new_processing_list), workers)
            infos = new_processing_list{indParticipant};
            fprintf(1,'==================================\n');
            fprintf(1,'New session... \n');
            fprintf(1,'==================================\n');  
            disp("Subject:");
            disp(infos{1});
            disp("Session:");
            disp(infos{2});
            % base_dir contains the path for current subject and session
            sess_dir = [baseDir filesep 'sub-' char(infos{1}) filesep 'ses-' char(infos{2})];
            processSession(sess_dir, infos{3}, whatToDo); % MAIN STEP
            disp("Finished session");
            disp("-------------------------------");
        end
    % or in parallel over subjects only
    else
        % possibly parfor --> only parellizing subjects
        parfor(indParticipant=1:length(participants_list), workers)
            subj = participants_list{indParticipant};
            for j=1:length(new_processing_list)
                infos = new_processing_list{j};
                if strcmp(infos{1}, subj)
                    fprintf(1,'==================================\n');
                    fprintf(1,'New session... \n');
                    fprintf(1,'==================================\n');  
                    disp("Subject:");
                    disp(infos{1});
                    disp("Session:");
                    disp(infos{2});
                    % base_dir contains the path for current subject and session
                    sess_dir = [baseDir filesep 'sub-' char(infos{1}) filesep 'ses-' char(infos{2})];
                    processSession(sess_dir, infos{3}, whatToDo); % MAIN STEP
                    disp("Finished session");
                    disp("-------------------------------");
                end
            end
        end
    end
    disp("Time for whole processing:");
    disp(toc);
end