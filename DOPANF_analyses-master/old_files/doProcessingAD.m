%
% Params:
%    subjectID   - the MR-ID of the subject (also main data folder), e.g."HMLT"
%                  (if none is given the definitions inside this script are used)
%
%    whatToDo    - list containing subset of 'VDM', 'SLICETIME', 'REALIGN', 'SEGMENT', 'NORMALIZE', 'SMOOTH', 'PHYSIO'
%
function doProcessingAD(subjectID, whatToDo, baseDir, table_path)  

    fprintf(1,'==================================\n');
    fprintf(1,'New subject ... \n');
    fprintf(1,'==================================\n');  
  
  % work on moco data or original ones
  sub_dir = [baseDir filesep 'sub-' subjectID];
  
  % get sessions from table
  T = readtable(table_path); % TODO: path for table with runs
  subject_rows = T(strcmp(T.SubjID, subjectID),:);
  assert(height(subject_rows)>0, "Table does not contain the subjectID!");
  % [value, index] = min(str2num(cell2mat(subject_rows.Session))); % other method: minimum value of session ID
  anatSess = cell2mat(subject_rows(strcmp('Yes', subject_rows.Anatomy),:).Session); % subject_rows(index,:).Session;
  t1_path = [sub_dir filesep ['ses-' convertStringsToChars(anatSess)] filesep 'anat']; % T1
  % check if T1 existsand get filename
  t1_file = get_t1_exists(t1_path, whatToDo);
  sessions = subject_rows.Session;
  
  % Iterate over sessions and available runs
  for s=1:length(sessions)
        %% Load files for current session
        disp("----------------- NEW SESSION ------------------");
        if strcmp(sessions(s), anatSess)
            disp("anatsess - left out in processing");
            continue
        end
        disp(sessions(s));
        session_name = ['ses-' char(sessions(s))];
        disp(session_name);
        % Load values of runs from csv file
        sess_row = subject_rows(strcmp(subject_rows.Session, sessions(s)),:);
        run_numbers = [sess_row.EPI_Run1, sess_row.EPI_Run2, sess_row.EPI_Run3];
        % run_numbers = get_runs_from_table(table_path, subjectID);
        disp("RUN NUMBERS");
        disp(run_numbers);
        
        % specify main paths:
        func_path = [sub_dir filesep session_name filesep 'func'];
        fmap_path = [sub_dir filesep session_name filesep 'fmap']; % fieldmap processing / VDM
        
        % get the folder content: all files in func directory for this session
        folder_content = dir(func_path);
        file_array = struct2cell(folder_content);
        file_array = file_array(1,:); % get only file names
        
        % LOAD METAINFO AND PROCESS DATA FOR EACH RUN
        for run=1:length(run_numbers)
            if isnan(run_numbers(run))
                disp("Skipping run because no acq number available in excel file. Run:");
                disp(run);
                continue
            end
            disp("Getting metadata for current run with acquisition number:");
            disp(run_numbers(run));
            %% Get metainfo and file paths
            % metainfo is the main struct used in all processing steps for
            % file paths and parameters
            [metainfo, physioFile, boldFile, physio_exists] = getEPIandPhysioFiles(file_array, run_numbers(run), func_path);

            % throw exception if no physio
%             if ~physio_exists
%                 ME = MException('myerror:filenotfounderror', 'Physio file not found for session %s and run %i.', session_name, run_numbers(run));
%                 throw(ME);
%             end
            
            % add additional information to metainfo
            metainfo.funcDir = func_path;
            metainfo.fmapDir = fmap_path;
            metainfo.anaDir = t1_path;
            metainfo.t1File = char(t1_file(1));
            metainfo.physioFile = physioFile;
            metainfo.boldFile = boldFile;
            metainfo.realign_prefix = 'ra_';
            metainfo.slicetime_prefix = 'st_'; % TODO: change
            metainfo.vdm_prefix = 'u';
            metainfo.smooth_prefix = 'sm_';
            metainfo.normalize_prefix = 'no_';
            metainfo.brain_norm_index = 'bno_';
            
            % check if vdm exists already:
            vdm_acq_mag = sess_row.EPI_Fieldmap_Magnitude_Run1;
            vdm_acq_phase = sess_row.EPI_Fieldmap_Phase_Run1;
            vdm_files = get_files_with(fmap_path, 'vdm5_sc');
            vdm_files = vdm_files(contains(vdm_files, ['acq-' num2str(vdm_acq_mag)])); % select only the ones for the current session
            if ~isempty(vdm_files) % does exist already
                assert(length(vdm_files)==1, 'several vdm5 files found. please check why there are multiple');
                vdm_exists = 1;
                metainfo.vdmFile = fullfile(fmap_path, vdm_files(1)); 
                disp("vdm file exists already");
                disp(metainfo.vdmFile);
            else % does not exist yet
                vdm_exists = 0;
                metainfo.vdmFile = ' ';
                disp("VDM does not exist yet");
                if any(strcmp(whatToDo, 'VDM')) % does not exist but in whattodo: get relevant files to do it
                    [imagefiles, out_vdm] = get_vdm_files(metainfo.fmapDir, vdm_acq_mag, vdm_acq_phase);
                    metainfo.fm_files = imagefiles;
                    metainfo.vdmFile = out_vdm;
                    disp("found fieldmap files:");
                    disp(metainfo.fm_files);
                    disp(metainfo.vdmFile);
                elseif any(strcmp(whatToDo, 'REALIGN')) % not in whattodo, but dependency
                    ME = MException('myerror:filenotfounderror', 'VDM file does not exist so far. You have specified REALIGN in the processing list, but VDM is required for this step. Please add VDM to processing list or delete REALIGN from it.');
                    throw(ME);
                % if vdm does not exist but also not done --> do nothing
                end
            end

            % check if segment data exists already:
            if exist(fullfile(metainfo.anaDir, ['y_' metainfo.t1File]), 'file') && exist(fullfile(metainfo.anaDir, 'Brain.nii'), 'file')
                segment_exists=1;
                disp("segment exists already");
            else
                segment_exists=0;
                disp("segment does not exist so far");
                if ~any(strcmp(whatToDo, 'SEGMENT')) && (any(strcmp(whatToDo, 'SMOOTH')) || any(strcmp(whatToDo, 'NORMALIZE')))
                    ME = MException('myerror:filenotfounderror', 'Segmented T1 does not exist so far. However, you have specified SMOOTH or NORMALIZE in the processing list which depend on SEGMENT. Please add SEGMENT to processing list or delete NORMALIZE/SMOOTH from it.');
                    throw(ME);
                end
            end
                
            %%
            
            
            %% Start processing

            % Initialize spm and matlabbatch
            spm_jobman('initcfg');
            global defaults
            defaults.stats.maxmem   = 2^30;
            clear matlabbatch
            matlabbatch = {};
            
            % unzip current bold directory and save path
            if ~exist(fullfile(metainfo.funcDir, erase(metainfo.boldFile, '.gz')), 'file')
                gunzip(fullfile(metainfo.funcDir, metainfo.boldFile));
                metainfo.boldFile = erase(metainfo.boldFile, '.gz');
                disp("Unzipped EPI");
                disp(fullfile(metainfo.funcDir, metainfo.boldFile));
            else
                disp("EPI File is already unzipped");
                disp(fullfile(metainfo.funcDir, erase(metainfo.boldFile, '.gz')));
                % remove zip part from path name
                metainfo.boldFile = erase(metainfo.boldFile, '.gz');
            end
            
            % MAIN PART
            % Iterate over processing steps
            % (possibility to replace function doaction: something like any(strcmp(whattodo,'a'))
            for todo=1:length(whatToDo)
                action = whatToDo(todo);
                % skip VDM or SEGMENT if done already (done ones per session)
                if (strcmp(action, 'VDM') && vdm_exists) || (strcmp(action, 'SEGMENT') && segment_exists) % here, we skip VDM if it is already available
                    continue
                end
                matlabbatch = doaction(char(action), metainfo, matlabbatch); % call single scripts to fill the batch
            end
            % save batch
            save([metainfo.funcDir filesep 'run' num2str(run_numbers(run)) '_batch.mat'], 'matlabbatch');
            disp("Saved matlabbatch. Run job...");
            
            % Run
            if ~isempty(matlabbatch)
                spm_jobman('run',matlabbatch);
            end
            disp("Ran job successfully for run");
            disp(run_numbers(run));
            
            clear metainfo;
        end
        disp("Ran all jobs successfully for session");
        disp(session_name);
  end

end



%% HELPER FUNCTIONS
function [metainfo, physioFile, boldFile, physio_exists] = getEPIandPhysioFiles(file_array, run_number, func_path)
    % initialize
    physioFile = '';
    boldFile = '';
    physio_exists =false;
    metainfo = struct();
    
    for f=1:length(file_array)
        % find physio
        if contains(file_array(f), ['task-rt_acq-' num2str(run_number)]) && contains(file_array(f), 'physio.tsv.gz')
            physio_exists = true;
            physioFile = char(file_array(f)); % get name of gz directory for metainfo TODO: also erase(gz?)
        end
        % find EPI
        if contains(file_array(f), ['task-rt_acq-' num2str(run_number)]) && contains(file_array(f), 'bold.nii.gz')
            boldFile = char(file_array(f)); % get name of bold gz directory for metainfo
        end
        % find bold.json file
        if contains(file_array(f), ['task-rt_acq-' num2str(run_number)]) && contains(file_array(f), 'bold.json')
            metainfo = loadjson(fullfile(func_path, char(file_array(f))));
            assert(metainfo.AcqNr==run_number); % assert that correct metadata loaded
            % assert(length(metainfo.DynamicScanNumber)==metainfo.MaxDynamics); %TODO
            metainfo.AscDesc = getAscDesc(metainfo.SliceTiming);
        end
    end
end

function [imagefiles, out_vdm] = get_vdm_files(fmapDir, vdm_acq_mag, vdm_acq_phase)
    relevant_files = get_files_with(fmapDir, {['acq-' num2str(vdm_acq_mag)], ['acq-' num2str(vdm_acq_phase)]});
    relevant_files = relevant_files(contains(relevant_files, {'magnitude1.nii.gz', 'magnitude2.nii.gz', 'phase1.nii.gz', 'phase2.nii.gz'}));
    assert(length(relevant_files)==4, "The available fieldmap files are not correct. There should be exactly 4 files (2 magnitude and 2 phase)");
    for f=1:length(relevant_files)
        gunzip(fullfile(fmapDir, relevant_files(f)));
        name_split = strsplit(cell2mat(relevant_files(f)),'_');
        name = erase(cell2mat(name_split(end)), '.nii.gz');
        imagefiles.(name) = fullfile(fmapDir, erase(relevant_files(f), '.gz'));
        if f==3 % save phase1 name
            phase_name = erase(relevant_files(f), '.gz');
            out_vdm = ['vdm5_sc' char(phase_name)];
        end
    end
end

function t1_file = get_t1_exists(t1_path, whatToDo)
    t1_file = get_files_with(t1_path, 'splitsense.nii');
    if isempty(t1_file) && any(strcmp(whatToDo, 'SEGMENT'))
        ME = MException('myerror:filenotfounderror', 'T1 file not found. You have specified SEGMENT in the processing list, but for this the T1 is required. Check you ana directory for the T1 file.');
        throw(ME);
    end
    t1_file = t1_file(startsWith(t1_file, 'sn_'));
    assert(length(t1_file)==1, "no t1 found or several matching files");
end


function run_numbers = get_runs_from_table(table_path, subjectID)
    T = readtable(table_path); % TODO: path for table with runs
    subject_row = T(strcmp(T.subjectID, subjectID),:);
    run_numbers = subject_row(1,2:end).Variables;
    disp("Available runs:");
    disp(run_numbers);
end

function ascDesc = getAscDesc(slicetiming)
    shifted_arr = circshift(slicetiming,1);
    if all(shifted_arr(2:end)<slicetiming(2:end))
        ascDesc = 'asc';
    elseif all(shifted_arr(2:end)>slicetiming(2:end))
        ascDesc = 'desc';
    else
        ascDesc = 'mixed'; 
    end
end


function batch = doaction(action, metainfo, batch)
    switch action
        case 'REALIGN'
            batch = batch_realign(metainfo, batch);
        case 'SLICETIME'
            batch = batch_slicetime(metainfo, batch);
        case 'NORMALIZE'
            batch = batch_normalize(metainfo, batch);
        case 'SMOOTH'
            batch = batch_smooth(metainfo, batch);
        case 'VDM'
            batch = batch_VDM(metainfo, batch);
        case 'SEGMENT'
            batch = batch_segment(metainfo, batch);
        case 'PHYSIO'
            batch = batch_physio(metainfo, batch);
        otherwise
            error('Sorry this option for whatToDo is unknown...');
    end
end

