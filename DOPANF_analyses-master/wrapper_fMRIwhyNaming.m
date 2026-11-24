%clear all 

% 
addpath('utils');
current_OS = OS.MACOS;
Config = Configuration_renaming;
logObj = mlog.Logger("ChangelogDiary");
logObj.RotationPeriod = 'instance';
logObj.FileThreshold = "TRACE";

% defintion of all variables and their translations - task names, etc.
path_to_table = '';
path_to_sequence_descr = '';
if (1 == ismac)
    addpath(genpath('/Volumes/JustData/Development/DOPANF_analyses/utils'));
    addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/bids-matlab'));
    addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/raincloud_plot'));
    addpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/spm12');
    addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/tapas'));
    addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/dicm2nii'));
    path_to_table = '/Volumes/JustData-1/Projects/DOPANF/Documents/Organisation';
    path_to_sequence_descr = '/Volumes/JustData-1/Projects/DOPANF/DataDescription';
    logObj.LogFolder = Config.paths.copy_to;
elseif (1 == ispc)
    addpath(genpath('C:\Development\DOPANF_analyses\Development\DOPANF_analyses\utils'));
    addpath(genpath('C:\Users\lhellr\Documents\MATLAB\Toolboxes\bids-matlab'));
    addpath(genpath('C:\Users\lhellr\Documents\MATLAB\Toolboxes\raincloud_plot'));
    addpath('C:\Users\lhellr\Documents\MATLAB\Toolboxes\spm12');
    addpath(genpath('C:\Users\lhellr\Documents\MATLAB\Toolboxes\tapas'));
    addpath(genpath('C:\Users\lhellr\Documents\MATLAB\Toolboxes\dicm2nii'));
    path_to_table = 'Z:\Projects\DOPANF\Documents\Organisation';
    path_to_sequence_descr = 'Z:\Projects\DOPANF\Documents\DataDescription';
    logObj.LogFolder = Config.paths.copy_to_pc;
end





% addpath of bids toolbox
% https://ch.mathworks.com/matlabcentral/fileexchange/93740-bids-matlab

% read the table with overview 
table_particpants = readtable(fullfile(path_to_table, 'Participants.xlsx'),'Sheet','Participants', 'Format', 'auto');
table_particpants = renamevars(table_particpants,["attribute_1_SubjectID_", "Status_Note_Pilot_Study_in_Study_out_"],...
                    ["SubjectID", "Status"]);

% just take IDs from participants that are in
participants_studyin = table_particpants.SubjectID(find(strcmp('Study_in',table_particpants.Status)));

% read the table with description of the acquisition numbers for each run
table_sequences = readtable(fullfile(path_to_sequence_descr, 'DOPANF_SequencesPerSubjectDescription.xlsx'),'Sheet','Tabelle1', 'Format', 'auto');
table_sequences = renamevars(table_sequences,["SubjID"],...
                    ["SubjectID"]);

% just little helpers during debugging
bool_BIDS_Folder_loaded = 0;
bool_perform_copying = 1;
                
% get the BIDS data structure
if (0 == bool_BIDS_Folder_loaded)
    if (1 == ismac)
        BIDS_folder = bids.layout(Config.paths.input_bids);
    else
        BIDS_folder = bids.layout(Config.paths.input_bids_pc);
    end
    bool_BIDS_Folder_loaded = 1;
end
% copy metadata files
current_filelist = dir(fullfile(BIDS_folder.dir, '*'));
current_filelist = current_filelist(~([current_filelist.isdir]));
temp_namelist = {current_filelist.name};
temp_namelist(startsWith(temp_namelist, '.')) = [];   % removes files starting with . 
if (~exist(Config.paths.copy_to, 'dir'))
    mkdir(Config.paths.copy_to);
end
for indFile = 1:length(temp_namelist)
    copyfile(fullfile(BIDS_folder.dir, temp_namelist{indFile}), Config.paths.copy_to);
end

if (1 == bool_perform_copying)
    [out] = manual_qa_corrections(Config.paths.manual_corrections_pc, BIDS_folder, logObj);
    
end
                
for indSubj = 1:length(participants_studyin)
    % get the next SubjectID - Note: This is MRIKey
    current_id = participants_studyin{indSubj};
    % get sequence description of both sessions
    current_sequence_description = table_sequences(strcmp(table_sequences.SubjectID, current_id),:);
    
    for indSessions = 1:length(current_sequence_description.Session)
        current_session_description = current_sequence_description(current_sequence_description.Session==indSessions,:);
        
        switch indSessions
            case 1
                % copy anat folder
                current_anat_files = bids.query(BIDS_folder,'data','sub',current_sequence_description.BIDS_subID,'type','T1w','rec','1');
                new_fname = rename_file(current_anat_files{1}, ...
                    Config.paths.copy_to,...
                    'sub', current_sequence_description.BIDS_subID{indSessions},...
                    'ses', num2str(indSessions),...
                    'acq','',...
                    'rec','');
                new_path = fileparts(new_fname);
                split_fname_nifti = strsplit(current_anat_files{1},'.nii.');
                fname_json = [split_fname_nifti{1},'.json'];
                fname_par = [split_fname_nifti{1},'.par'];
                new_fname_json = rename_file(fname_json, ...
                    Config.paths.copy_to,...
                    'sub', current_sequence_description.BIDS_subID{indSessions},...
                    'ses', num2str(indSessions),...
                    'acq','',...
                    'rec','');
                new_fname_par = rename_file(fname_par, ...
                    Config.paths.copy_to,...
                    'sub', current_sequence_description.BIDS_subID{indSessions},...
                    'ses', num2str(indSessions),...
                    'acq','',...
                    'rec','');
                
                if (0 == isfile(new_fname))
                    if (~exist(new_path, 'dir'))
                        mkdir(new_path);
                    end
                    if (1 == bool_perform_copying)
                        copyfile(current_anat_files{1}, new_fname);
                        message(logObj, "Renaming T1 data: %s %s", current_anat_files{1}, new_fname);
                        copyfile(fname_json, new_fname_json);
                        message(logObj, "Renaming T1 json data: %s %s", fname_json, new_fname_json);
                        copyfile(fname_par, new_fname_par);
                        message(logObj, "Renaming T1 par data: %s %s", fname_par, fname_par);
                    end
                end
                
            case 2
                
        end
        
        %current_session_description = current_sequence_description(current_sequence_description.Session==indSessions,:);
        % get all NIFTI task files from ALL sessions
        current_nifti_files = bids.query(BIDS_folder,'data','sub',current_sequence_description.BIDS_subID,'ses',current_session_description.BIDS_sesID,'task','rt','type','bold');
        % get metadata of data
        current_metadata = bids.query(BIDS_folder,'metadata','sub',current_sequence_description.BIDS_subID,'ses',current_session_description.BIDS_sesID,'task','rt','type','bold');
            
        current_physio_files = bids.query(BIDS_folder,'data','sub',current_sequence_description.BIDS_subID,'ses',current_session_description.BIDS_sesID,'task','rt','type','physio');
        for indTask = 1:length(Config.task_naming)
            
            % over all tasks and runs
            current_acq_nr = eval(['current_session_description.',Config.task_naming{indTask}]);
            if (isnan(current_acq_nr))
                continue;
            end
            bool_found_acq_nr = false;
            % check each file if acqNr is in
            for indFile = 1:length(current_nifti_files)
                if (~isempty(strfind(current_nifti_files{indFile},sprintf('_acq-%d',current_acq_nr))))
                    % split the task name since new name middel part
                    split_task_name = strsplit(Config.task_naming{indTask},'_');
                    % replace '_task-rt' with '_task-NFTraining' & '_run-20' with '_run-#'
                    
                    new_fname_nifti = rename_file(current_nifti_files{indFile}, ...
                        Config.paths.copy_to,...
                        'sub', current_sequence_description.BIDS_subID{indSessions},...
                        'task', split_task_name{2},...
                        'run', strrep(split_task_name{3}, 'Run',''),...
                        'ses', num2str(indSessions),...
                        'acq','',...
                        'rec','');
                    
                    [new_path] = fileparts(new_fname_nifti);
                    % do same renaming for corresponding files - json and
                    % par
                    split_fname_nifti = strsplit(current_nifti_files{indFile},'.nii.');
                    fname_json = [split_fname_nifti{1},'.json'];
                    fname_par = [split_fname_nifti{1},'.par'];
                    
                    new_fname_json = rename_file([split_fname_nifti{1},'.json'], ...
                        Config.paths.copy_to,...
                        'sub', current_sequence_description.BIDS_subID{indSessions},...
                        'task', split_task_name{2},...
                        'run', strrep(split_task_name{3}, 'Run',''),...
                        'ses', num2str(indSessions),...
                        'acq','',...
                        'rec','');                     
                    new_fname_par = rename_file([split_fname_nifti{1},'.par'], ...
                         Config.paths.copy_to,...
                         'sub', current_sequence_description.BIDS_subID{indSessions},...
                        'task', split_task_name{2},...
                        'run', strrep(split_task_name{3}, 'Run',''),...
                        'ses', num2str(indSessions),...
                        'acq','',...
                        'rec','');                     

                    
                    % create the copy if not yet existing
                    if (0 == isfile(new_fname_nifti))
                        if (~exist(new_path, 'dir'))
                            mkdir(new_path);
                        end
                        if (1 == bool_perform_copying)
                            copyfile(current_nifti_files{indFile}, new_fname_nifti);
                            message(logObj, "Renaming nifti data: %s %s", current_nifti_files{indFile}, new_fname_nifti);
                            copyfile(fname_json, new_fname_json);
                            message(logObj, "Renaming nifti json data: %s %s", fname_json, new_fname_json);
                            copyfile(fname_par, new_fname_par);
                            message(logObj, "Renaming nifti par data: %s %s", fname_par, fname_par);
                        end
                    end
                    
                    % Do a QA correction for # TRs:
                    % The scanner has been stopped manualle during the
                    % NFAdapt task - this can cause that number of TRs
                    % (Dynamics) is incorrect in json file compared to real nii header, but this
                    % information is used later for processing, so we have
                    % to correct for this with a little dirty hack
                    nr_dynamics_metadata = max(current_metadata{indFile}.DynamicScanNumber);% that's in json file
                    nii_header = niftiinfo(current_nifti_files{indFile});
                    nr_dynamics_niiheader = nii_header.ImageSize(4);% that's in nii header and is the truth!
                    if (nr_dynamics_metadata ~= nr_dynamics_niiheader)
                        % overwrite this number in QA copy of json file
                        struct_new_json = loadjson(new_fname_json);
                        struct_new_json.DynamicScanNumber = [1:nr_dynamics_niiheader];
                        struct_new_json. MaxDynamics = nr_dynamics_niiheader;
                        savejson('',struct_new_json,new_fname_json);
                        message(logObj, "Change of header information about TR: from %d to %d %s", nr_dynamics_metadata, nr_dynamics_niiheader, new_fname_json);
                    end
                    % do a QA correction for participant 45671 with some
                    % broken slices (reason fully unknown), i.e. calc
                    % average of pre/post slices 
                    if (strcmp(current_sequence_description.BIDS_subID{indSessions}, '45671') && strcmp(split_task_name{2}, 'BLTask') && strcmp(strrep(split_task_name{3}, 'Run',''),'1'))
                        % ...current_sequence_description.BIDS_subID
                        nii_image = niftiread(nii_header);
                        slice_pre = nii_image(:,:,:,96);
                        slice_post = nii_image(:,:,:,100);
                        slice_mean = imadd(slice_pre, slice_post)/2;
                        nii_image(:,:,:,97) = slice_mean;
                        nii_image(:,:,:,98) = slice_mean;
                        nii_image(:,:,:,99) = slice_mean;
                        slice_pre = nii_image(:,:,:,134);
                        slice_post = nii_image(:,:,:,140);
                        slice_mean = imadd(slice_pre, slice_post)/2;
                        nii_image(:,:,:,135) = slice_mean;
                        nii_image(:,:,:,136) = slice_mean;
                        nii_image(:,:,:,137) = slice_mean;
                        nii_image(:,:,:,138) = slice_mean;
                        nii_image(:,:,:,139) = slice_mean;
                        % SAVE FILE
                        new_niiname = split(new_fname_nifti,'.');
                        niftiwrite(nii_image, new_niiname{1}, nii_header);
                        message(logObj, "Mean average in nifti data slices: %s ", new_niiname{1});
%                           delete(new_fname_nifti);
%                           delete(new_fname_json);
%                           delete(new_fname_par);
%                           message(logObj, "45671 BLTask run 2 had to be removed due to corrupt data (reason unknown) ");
                    end
                        
                    
                    if (~isempty(strfind(current_physio_files{indFile},sprintf('_acq-%d',current_acq_nr))))
                        % do same for corresponding physio file and
                        % corresponding json and par
                       
                        new_fname_physio = rename_file(current_physio_files{indFile}, ...
                           Config.paths.copy_to,...
                           'sub', current_sequence_description.BIDS_subID{indSessions},...
                           'task', split_task_name{2},...
                           'run', strrep(split_task_name{3}, 'Run',''),...
                           'ses', num2str(indSessions),...
                           'acq','',...
                           'rec','');
                       % do same renaming for corresponding files - json and
                        % log
                        split_fname_physio = strsplit(current_physio_files{indFile},'.tsv.');
                        fname_json = [split_fname_physio{1},'.json'];
                        fname_log = [split_fname_physio{1},'.log'];
                        
                        new_fname_json = rename_file([split_fname_physio{1},'.json'], ...
                            Config.paths.copy_to,...
                            'sub', current_sequence_description.BIDS_subID{indSessions},...
                            'task', split_task_name{2},...
                            'run', strrep(split_task_name{3}, 'Run',''),...
                            'ses', num2str(indSessions),...
                            'acq','',...
                            'rec','');
                        new_fname_log = rename_file([split_fname_physio{1},'.log'], ...
                            Config.paths.copy_to,...
                            'sub', current_sequence_description.BIDS_subID{indSessions},...
                            'task', split_task_name{2},...
                            'run', strrep(split_task_name{3}, 'Run',''),...
                            'ses', num2str(indSessions),...
                            'acq','',...
                            'rec','');
                        
                        if (0 == isfile(new_fname_physio) && 1 == bool_perform_copying)
                            copyfile(current_physio_files{indFile}, new_fname_physio);
                            message(logObj, "Renaming physio data: %s %s", current_physio_files{indFile}, new_fname_physio);
                            copyfile(fname_json, new_fname_json);
                            message(logObj, "Renaming physio json data: %s %s", fname_json, new_fname_json);
                            copyfile(fname_log, new_fname_log);
                            message(logObj, "Renaming physio log data: %s %s", fname_log, new_fname_log);
                        end
                    else
                        str = sprintf('WARNING! Physio data missing: Subject %s, Session: %d, BIDS sub: %s, AcqNr: %d', ...
                                current_session_description.SubjectID{1}, ...
                                current_session_description.Session, ...
                                current_session_description.BIDS_subID{1}, ...
                                current_acq_nr);
                        disp(str);
                        warning(logObj, str);
                    end
                    bool_found_acq_nr = true;
                    continue;
                end
            end
            if (true == bool_found_acq_nr)
                str = sprintf('File with acquisition nr renamed: Subject %s, Session: %d, BIDS sub: %s, AcqNr: %d', ...
                                current_session_description.SubjectID{1}, ...
                                current_session_description.Session, ...
                                current_session_description.BIDS_subID{1}, ...
                                current_acq_nr);              
                disp(str);
                message(logObj, str);
            else
                str = sprintf('WARNING! File with acquisition nr missing: Subject %s, Session: %d, BIDS sub: %s, AcqNr: %d', ...
                    current_session_description.SubjectID{1}, ...
                    current_session_description.Session, ...
                    current_session_description.BIDS_subID{1}, ...
                    current_acq_nr);
                disp(str);
                warning(logObj, str);
            end
                      
            % get fmap files, NOTE: ONLY Phase Images given here, seems to be
            % an open issue in bids-matlab that magnitude cannot be loaded
            % over all tasks and runs
            current_fmap_files = bids.query(BIDS_folder,'data','sub',current_sequence_description.BIDS_subID,'ses',current_session_description.BIDS_sesID,'modality','fmap');
            current_acq_nr_fieldmap = eval(['current_session_description.',Config.fieldmap_naming{indTask}]);
            if (isnan(current_acq_nr_fieldmap))
                continue;
            end
            bool_found_acq_nr_fieldmap = false;
            
            %#### rename fieldmaps files accordingly #####
            for indFile = 1:length(current_fmap_files)
                
                for indFileType = 1:length(current_fmap_files{indFile})
                    
                    if (~isempty(strfind(current_fmap_files{indFile}{indFileType},sprintf('_acq-%d',current_acq_nr_fieldmap))))
                        % split the task name since new name middel part
                        split_task_name = strsplit(Config.task_naming{indTask},'_');
                        % replace '_task-rt' with '_task-NFTraining' & '_run-20' with '_run-#'
                        
                        new_fname_fmap_phase = rename_file(current_fmap_files{indFile}{indFileType}, ...
                            Config.paths.copy_to,...
                            'sub', current_sequence_description.BIDS_subID{indSessions},...
                            'task', split_task_name{2},...
                            'run', strrep(split_task_name{3}, 'Run',''),...
                            'ses', num2str(indSessions),...
                            'acq','',...
                            'rec','');
                        % due to the issue with the magnitude files, we
                        % have to make up that name on our own
                        current_fmap_magnitude_file = strrep(current_fmap_files{indFile}{indFileType},'phase','magnitude');
                        
                        new_fname_fmap_magnitude = rename_file(current_fmap_magnitude_file, ...
                            Config.paths.copy_to,...
                            'sub', current_sequence_description.BIDS_subID{indSessions},...
                            'task', split_task_name{2},...
                            'run', strrep(split_task_name{3}, 'Run',''),...
                            'ses', num2str(indSessions),...
                            'acq','',...
                            'rec','');
                        
                        [new_path] = fileparts(new_fname_fmap_phase);
                        % do same renaming for corresponding files - json and
                        % par
                        split_fname_fmap = strsplit(current_fmap_files{indFile}{indFileType},'.nii.');
                        fname_json = [split_fname_fmap{1},'.json'];
                        fname_par = [split_fname_fmap{1},'.par'];
                        % par only exists for phase images
                        new_fname_json = rename_file([split_fname_fmap{1},'.json'], ...
                            Config.paths.copy_to,...
                            'sub', current_sequence_description.BIDS_subID{indSessions},...
                            'task', split_task_name{2},...
                            'run', strrep(split_task_name{3}, 'Run',''),...
                            'ses', num2str(indSessions),...
                            'acq','',...
                            'rec','');
                        % 
                        new_fname_par = rename_file([split_fname_fmap{1},'.par'], ...
                            Config.paths.copy_to,...
                            'sub', current_sequence_description.BIDS_subID{indSessions},...
                            'task', split_task_name{2},...
                            'run', strrep(split_task_name{3}, 'Run',''),...
                            'ses', num2str(indSessions),...
                            'acq','',...
                            'rec','');
                        
                        
                        % create the copy if not yet existing
                        if (0 == isfile(new_fname_fmap_phase))
                            if (~exist(new_path, 'dir'))
                                mkdir(new_path);
                            end
                            if (1 == bool_perform_copying)
                                if (2 == exist(current_fmap_files{indFile}{indFileType}, 'file'))
                                    copyfile(current_fmap_files{indFile}{indFileType}, new_fname_fmap_phase);
                                    message(logObj, "Renaming fmap data: %s %s", current_fmap_files{indFile}{indFileType}, new_fname_fmap_phase);
                                end
                                if (2 == exist(current_fmap_magnitude_file, 'file'))
                                    copyfile(current_fmap_magnitude_file, new_fname_fmap_magnitude);
                                    message(logObj, "Renaming fmap data: %s %s", current_fmap_magnitude_file, new_fname_fmap_magnitude);
                                end
                                if (2 == exist(fname_json, 'file'))
                                    copyfile(fname_json, new_fname_json);
                                    message(logObj, "Renaming fmap json data: %s %s", fname_json, new_fname_json);
                                end
                                if (2 == exist(fname_par, 'file'))
                                    copyfile(fname_par, new_fname_par);
                                    message(logObj, "Renaming fmap par data: %s %s", fname_par, fname_par);
                                end
                            end
                        end
                    end
                end
            end
        end
        % copy full folder with behavioral data to QA folder, already renamed,
        % just session-wise
        current_folder_beh = fullfile(Config.paths.input_bids, sprintf('sub-%s',current_sequence_description.BIDS_subID{indSessions}),sprintf('ses-%s',current_sequence_description.BIDS_sesID{indSessions}),'BEH');
        new_folder_beh = fullfile(Config.paths.copy_to,sprintf('sub-%s',current_sequence_description.BIDS_subID{indSessions}),sprintf('ses-%s', num2str(indSessions)),'beh');
        if (exist(new_folder_beh, 'dir') && (1 == bool_perform_copying))
            delete(fullfile(new_folder_beh, '*'));
        elseif (~exist(new_folder_beh, 'dir') && (1 == bool_perform_copying))
            mkdir(new_folder_beh);
        end
        if (1 == bool_perform_copying)
            copyfile(current_folder_beh, new_folder_beh);
            [out] = rename_behavioral_files(new_folder_beh, current_sequence_description.BIDS_subID{indSessions}, num2str(indSessions), logObj);
            if (2 == indSessions)
                check_for_file_duplicates(new_folder_beh, logObj);
                [out] = correct_onsets_in_indiff_logfiles(new_folder_beh, Config.paths.input_bids, Config.subjects_onsets_from_DecMakBL_edfs, current_session_description.BIDS_subID, current_session_description.BIDS_sesID, logObj);
            end
        end
    end
end

% rename all beh files 
function out = rename_behavioral_files(new_folder_beh, subID, session, logObj)
    % search all files from beh folder
    
    filelist_beh = dir([new_folder_beh filesep '*.*']);
    filelist_beh = filelist_beh(~startsWith({filelist_beh.name}, '.'));
    filelist_beh = filelist_beh(~startsWith({filelist_beh.name}, 'recoded_trial_levels'));
    filelist_beh = filelist_beh(~startsWith({filelist_beh.name}, 'sub-'));
    filelist_beh = filelist_beh(~contains({filelist_beh.name}, 'BackupAfterError'));
    for indFile = 1:length(filelist_beh)
        [~, filename, ~] = fileparts(filelist_beh(indFile).name);
        filename_split = strsplit(filename, '_');
        disp(filelist_beh(indFile).name);
        % task and run shall be used as given already in filename, couldn't
        % makeup any other workaround than this one
        index_task = find(contains(filename_split,'task-'));
        index_run = find(contains(filename_split,'run-'));
        new_fname = rename_file(filelist_beh(indFile).name, ...
            filelist_beh(indFile).folder,...
            'sub', subID, ...
            'task', strrep(filename_split{index_task}, 'task-',''),...
            'run', strrep(filename_split{index_run}, 'run-0',''),... %
            'ses', session,...
            'acq','',...
            'rec','');
        movefile(fullfile(filelist_beh(indFile).folder, filelist_beh(indFile).name), fullfile(filelist_beh(indFile).folder, new_fname))
        message(logObj, "Renaming behavioral file: %s %s", fullfile(filelist_beh(indFile).folder, filelist_beh(indFile).name), fullfile(filelist_beh(indFile).folder, new_fname));
    end

    out = 1;
end

function check_for_file_duplicates(new_folder_beh, logObj)
    % check for repetitions of indiff runs, which caused more than two
    % logfiles (each saved as csv and mat, so overall 4 files); this should be detected here befor it causes errors while
    % loading for 1st levels later
    filelist_beh = dir([new_folder_beh filesep '*indiff*task-DecMakBL.*']);
    filelist_beh = filelist_beh(~startsWith({filelist_beh.name}, '.'));
    if (1 == isempty(filelist_beh))
        print_msg = sprintf('IMPORTANT WARNING: Subject has NO indiff task!!! \n Check this folder: %s \n Otherwise the 1st levels will crash later!!', new_folder_beh);
        warndlg(print_msg, 'Warning');
        disp('Program execution resumed');
        warning(logObj, print_msg);
    elseif (4 < length(filelist_beh))
        print_msg = sprintf('IMPORTANT WARNING: Subject has too many indiff files!!! \n Check this folder: %s \n Otherwise the 1st levels will crash later!!', new_folder_beh);
        warndlg(print_msg, 'Warning');
        disp('Program execution resumed');
        warning(logObj, print_msg);
    end
end
    

% % define rename function
%
%     
function out = rename_file(fname,path,varargin)
   defaultSub = '';
   defaultTask = '';
   defaultRun = '';
   defaultSes = '';
   defaultAcq = '';
   defaultRec = '';
   
   p = inputParser;
   addRequired(p,'fname',@ischar);
   addRequired(p,'path',@ischar);
   p2 = inputParser;
   
   % the parser will sort its fileds in alphabtical order, therefore we
   % need a second order element to add later to the filename in BIDS
   % related order
   addParameter(p2,'sub',defaultSub,@ischar);
   addParameter(p2,'ses',defaultSes,@ischar);
   addParameter(p2,'task',defaultTask,@ischar);
   addParameter(p2,'acq',defaultAcq,@ischar);
   addParameter(p2,'rec',defaultRec,@ischar);
   addParameter(p2,'run',defaultRun,@ischar);
   entities_to_be_check_in_correct_order = {'sub', 'ses', 'task', 'acq', 'rec', 'run'};
   
   parse(p,fname,path);
   parse(p2, varargin{:});
   %fields = fieldnames(p2.Results);
   [fname_folder, fname_file, ext] = fileparts(p.Results.fname);
   filename_split = strsplit(fname_file,'_');
   for indPar = 1:length(entities_to_be_check_in_correct_order)
       index_currentfilename = find(contains(filename_split,[entities_to_be_check_in_correct_order{indPar} '-']));
       index_entity = find(contains(entities_to_be_check_in_correct_order,entities_to_be_check_in_correct_order{indPar}));
       value = p2.Results.(entities_to_be_check_in_correct_order{indPar});
       if (1 == isempty(value) && 1 == isempty(index_currentfilename))
           continue;
       end
       if (1 == isempty(value) && 0 == isempty(index_currentfilename)) % kick out this field
          filename_split(index_currentfilename) = [];
       elseif (0 == isempty(value) && 1 == isempty(index_currentfilename)) % insert at ordered position when field is not in filename but a value has been chosen
          filename_split = [filename_split(1:indPar-1), {sprintf('%s-%s',entities_to_be_check_in_correct_order{indPar}, value)}, filename_split(indPar:end)];
%        elseif (0 == isempty(value) && 0 == isempty(index_currentfilename) && index_currentfilename ~= index_entity)
%            filename_split = [filename_split(1:indPar-1), {sprintf('%s-%s',entities_to_be_check_in_correct_order{indPar}, value)}, filename_split(indPar:end)];
%            if (index_entity < index_currentfilename)
%                filename_split = [filename_split(1:index_currentfilename-1), filename_split(index_currentfilename+1:end)];
%            else
%                filename_split = [filename_split(1:index_currentfilename), filename_split(index_currentfilename+2:end)];
%            end
       else
          filename_split(index_currentfilename) = {sprintf('%s-%s',entities_to_be_check_in_correct_order{indPar}, value)}; % replace value of this field name
       end
   end
   
   % set new path 
   base_path = strsplit(fname_folder, [filesep 'sub']);
   fname_folder_new = strrep(fname_folder, base_path{1}, path);
   folder_split = strsplit(fname_folder_new, filesep);
   
   % check session number in path
   index_currentfilename = find(contains(folder_split,'ses'));
   if (0 == isempty(index_currentfilename))
       folder_split(index_currentfilename) = {sprintf('ses-%s', p2.Results.ses)};
   end
   new_foldername = strjoin(folder_split,filesep);
   new_filename = strjoin(filename_split, '_');
   out = fullfile(new_foldername, [new_filename ext]);
end


function out = correct_onsets_in_indiff_logfiles(new_folder_beh, input_path_edf, concerned_subjects, subject_id, session_id, logObj)
    % the trick here is to put together a logfile with the same logic than the other ones
    % the other ones have the issue that the onset time contains also the
    % RT, therefore we have to add that there
    % Second, the start time of the eye tracker is useless for us since
    % it's independent of scanner trigger
    % But, the first trial is always played at constant of 6 seconds,
    % that's our fixpoint here
    fixed_start_time_of_trial1 = 6000;
    filelist_beh = dir([new_folder_beh filesep '*indiff*task-DecMakBL.mat']);
    filelist_beh = filelist_beh(~startsWith({filelist_beh.name}, '.'));
    
    for indFile = 1:length(filelist_beh)
        [~, filename, ~] = fileparts(filelist_beh(indFile).name);
        filename_split = strsplit(filename, '_');
        index_sub = find(contains(filename_split,'sub'));
        current_sub = strrep(filename_split{index_sub}, 'sub-','');
        % check if subject is relevant at all for this QA procedure, otherwise
        % continue immediately
        if (1 == ~any(strcmp(concerned_subjects,current_sub))) 
            continue;
        end
        index_run = find(contains(filename_split,'run'));
        current_run = strrep(filename_split{index_run}, 'run-','');
        % load this logfile, this will create variable "decision_logs"
        % we'll write into
        % it's impossibe in Matlab to load this into a separate variable and write
        % this later, but the later loading of these file in 1st levels is
        % dependent on this naming
        load(fullfile(filelist_beh(indFile).folder, filelist_beh(indFile).name));
        rt_times_from_logfile = decision_logs(:,6);
        
        % search corresponsding edf file
       
        edf_logfile = dir(fullfile(input_path_edf, ['sub-' char(subject_id)], ['ses-' char(session_id)], 'PHYS' ,['*task-DecMakBL_run*' current_run, '*.edf']));
        if (1 == isempty(edf_logfile))
            print_msg = sprintf('IMPORTANT WARNING: Subject has no eyetracker logfile!!! \n Check this folder: %s \n Otherwise the 1st levels will crash later!!', fullfile(input_path_edf, ['sub-' char(subject_id)], ['ses-' char(session_id)], 'PHYS'));
            warndlg(print_msg, 'Warning');
            disp('Program execution resumed');
            warning(logObj, print_msg);
            continue;
        end
        edf_data = Edf2Mat(fullfile(edf_logfile.folder, edf_logfile.name));
        current_nr_of_trials = length(edf_data.Events.Messages.time(contains(edf_data.Events.Messages.info, 'Start Trial')));
        % onset_vector we will append later to the indiff file
        new_onset_vector = zeros(1, current_nr_of_trials+2);
        start_time_trial1 = edf_data.Events.Messages.time(contains(edf_data.Events.Messages.info, 'Start Trial 1 c'));
        new_onset_vector(1) = start_time_trial1-fixed_start_time_of_trial1;
        for indTrial = 1:current_nr_of_trials
            % calc onset according to other logfiles
            current_rt_time = rt_times_from_logfile(indTrial)*1000;
            current_start_time = edf_data.Events.Messages.time(contains(edf_data.Events.Messages.info, ['Start Trial ' num2str(indTrial) ' c'])) +  current_rt_time;
            new_onset_vector(indTrial+1) = current_start_time;
        end
        new_onset_vector(end) = edf_data.Events.Messages.time(contains(edf_data.Events.Messages.info, 'stop recording'));
        % append to struct and save to mat and csv file
        empty_row={decision_logs(2,1)};
        empty_row(1,end+1:end+size(decision_logs,2)-1) = {NaN};
        decision_logs = [[decision_logs(2,1) NaN(1,size(decision_logs,2)-1)]; decision_logs(:,:); [decision_logs(2,1) NaN(1,size(decision_logs,2)-1)]];
        decision_logs(:,end+1) = new_onset_vector/1000.0;
        %save updated variable decision_logs, will be reloaded during 1st
        %levels
        save(fullfile(filelist_beh(indFile).folder, filelist_beh(indFile).name), 'decision_logs');
        message(logObj, "Onsets created from eyetracking and logfile updated: %s %s", fullfile(filelist_beh(indFile).folder, filelist_beh(indFile).name));
        logfile_as_table = readtable(fullfile(filelist_beh(indFile).folder, [filename '.csv']));
        new_logfile_as_table = [empty_row; logfile_as_table; empty_row];
        new_logfile_as_table = [new_logfile_as_table array2table(new_onset_vector.', 'VariableNames', {'onset'})];
        writetable(new_logfile_as_table, fullfile(filelist_beh(indFile).folder, [filename '.csv']));
        % clean up for security to be ready for next round in loop
        clear decision_logs rt_times_from_logfile new_onset_vector edf_data current_nr_of_trials; 
    end
    
    
    
    out = 1; 
end
    
% for very unbelievable reasons there were a few corrupt data on the raw
% data server
% A few could be corrected by re-conversions fromn par/rec or rt data, but
% since this happened manually, these data are safed on my data server and
% will be copied into the BIDS dataset here and now
function out = manual_qa_corrections(in_folder, out_folder, logObj)
    
    % EPI newly converted from real-time data via SPM converter 3dto4D plus copy of geometry
    % vias fsl
    copyfile(fullfile(in_folder, 'sub-47134_ses-27730_task-rt_acq-9_rec-1_run-20_bold.nii.gz'), fullfile(out_folder, 'sub-47134_ses-27730_task-rt_acq-9_rec-1_run-20_bold.nii.gz'));
    message(logObj, "Overwritten manually corrected file in BIDS structure: sub-47134_ses-27730_task-rt_acq-9_rec-1_run-20_bold.nii.gz ");

    % manual edit (enter 0 instead of nullnullnull...) in line 77693 where bit was broken and file ASCII
    % unreadable by TapasToolbox
    copyfile(fullfile(in_folder, 'sub-47134_ses-27730_task-rt_acq-9_rec-1_run-20_recording-scanphys_physio.tsv.gz'), fullfile(out_folder, 'sub-47134_ses-27730_task-rt_acq-9_rec-1_run-20_recording-scanphys_physio.tsv.gz'));
    message(logObj, "Overwritten manually corrected file in BIDS structure:  sub-47134_ses-27730_task-rt_acq-9_rec-1_run-20_recording-scanphys_physio.tsv.gz");

    copyfile(fullfile(in_folder, 'sub-47134_ses-27730_task-rt_acq-9_rec-1_run-20_recording-scanphys_physio.log'), fullfile(out_folder, 'sub-47134_ses-27730_task-rt_acq-9_rec-1_run-20_recording-scanphys_physio.log'));
    message(logObj, "Overwritten manually corrected file in BIDS structure:  sub-47134_ses-27730_task-rt_acq-9_rec-1_run-20_recording-scanphys_physio.log");

    % EPI newly converted via rec2nifti from raw data server
    copyfile(fullfile(in_folder, 'sub-47134_ses-27730_task-rt_acq-8_rec-1_run-20_bold.nii.gz'), fullfile(out_folder, 'sub-47134_ses-27730_task-rt_acq-8_rec-1_run-20_bold.nii.gz'));
    message(logObj, "Overwritten manually corrected file in BIDS structure:  sub-47134_ses-27730_task-rt_acq-8_rec-1_run-20_bold.nii.gz");

    % EPI newly converted via rec2nifti from raw data server
    copyfile(fullfile(in_folder, 'sub-47134_ses-27730_task-rt_acq-6_rec-1_run-20_bold.nii.gz'), fullfile(out_folder, 'sub-47134_ses-27730_task-rt_acq-6_rec-1_run-20_bold.nii.gz'));
    message(logObj, "Overwritten manually corrected file in BIDS structure:  sub-47134_ses-27730_task-rt_acq-6_rec-1_run-20_bold.nii.gz");

    % fieldmap newly converted via rec2nifti from raw data server
    copyfile(fullfile(in_folder, 'sub-44052_ses-27766_acq-5_run-0_magnitude1.nii.gz'), fullfile(out_folder, 'sub-44052_ses-27766_acq-5_run-0_magnitude1.nii.gz'));
    message(logObj, "Overwritten manually corrected file in BIDS structure:  sub-44052_ses-27766_acq-5_run-0_magnitude1.nii.gz");

    copyfile(fullfile(in_folder, 'sub-44052_ses-27766_acq-5_run-0_phase1.nii.gz'), fullfile(out_folder, 'sub-44052_ses-27766_acq-5_run-0_phase1.nii.gz'));
    message(logObj, "Overwritten manually corrected file in BIDS structure:  sub-44052_ses-27766_acq-5_run-0_phase1.nii.gz");

    copyfile(fullfile(in_folder, 'sub-44052_ses-27766_acq-5_run-0_phase2.nii.gz'), fullfile(out_folder, 'sub-44052_ses-27766_acq-5_run-0_phase2.nii.gz'));
    message(logObj, "Overwritten manually corrected file in BIDS structure: sub-44052_ses-27766_acq-5_run-0_phase2.nii.gz ");

    copyfile(fullfile(in_folder, 'sub-44052_ses-27766_acq-5_run-0_magnitude2.nii.gz'), fullfile(out_folder, 'sub-44052_ses-27766_acq-5_run-0_magnitude2.nii.gz'));
    message(logObj, "Overwritten manually corrected file in BIDS structure:  sub-44052_ses-27766_acq-5_run-0_magnitude2.nii.gz");
    out = 1;
end 

