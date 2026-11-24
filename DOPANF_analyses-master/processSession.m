%
% Params:
%    sess-dir   - the path to the session directory for the session of the
%                   subject that is to be processed
%
%    table_infos - a struct containing the information about acquisition
%                   number of runs & of fieldmaps, paths to T1 etc 
%                   --> everything that can be read off the table
%
%    whatToDo    - list containing subset of 'VDM', 'SLICETIME', 'REALIGN', 'SEGMENT', 'NORMALIZE', 'SMOOTH', 'PHYSIO'
%
function processSession(sess_dir, table_infos, whatToDo)  
 
    % Load values of runs from table (stored in table_infos struct)
    run_numbers = table_infos.runs;
    disp("RUN NUMBERS");
    disp(run_numbers);
    
    % Load values of fmap acq numbers from table
    vdm_acq_mag = table_infos.fmaps(1);
    vdm_acq_phase = table_infos.fmaps(2);

    % specify main paths:
    func_path = [sess_dir filesep 'func'];
    fmap_path = [sess_dir filesep 'fmap']; % fieldmap processing / VDM
    
    for run=1:length(run_numbers)
        %% COLLECT METAINFO EACH RUN
        if isnan(run_numbers(run))
            disp("Skipping run because no acq number available in excel file. Run:");
            disp(run);
            continue
        end
        disp("Getting metadata for current run with acquisition number:");
        disp(run_numbers(run));
        run_number =run_numbers(run);  
        
        % Load metainfo 
        info_json = get_files_with(func_path, {['task-rt_acq-' num2str(run_number)],'bold.json'}, '');
        assert(length(info_json)==1, 'No or several bold.json files found for this run. There must be exactly one.');
        metainfo = loadjson(fullfile(func_path, cell2mat(info_json)));
        assert(metainfo.AcqNr==run_numbers(run));
        % assert(length(metainfo.DynamicScanNumber)==metainfo.MaxDynamics);
        
        % add relevant file paths to metainfo
        physioFile = get_files_with(func_path, {['task-rt_acq-' num2str(run_number)], 'physio.tsv.gz'}, 'sub-');
        % TODO: insert
        % assert(length(physioFile)==1, 'No or several physio.tsv.gz files found for this run. There must be exactly one.');
        boldFile = get_files_with(func_path, {['task-rt_acq-' num2str(run_number)], 'bold.nii.gz'}, 'sub-');
        assert(length(boldFile)==1, 'No or several bold.nii.gz files found for this run. There must be exactly one.');
        metainfo.physioFile = cell2mat(physioFile);
        metainfo.boldFile = cell2mat(boldFile);
        
        % add additional information to metainfo
        metainfo.AscDesc = getAscDesc(metainfo.SliceTiming);
        metainfo.funcDir = func_path;
        metainfo.fmapDir = fmap_path;
        metainfo.anaDir = table_infos.t1_path;
        metainfo.t1File = table_infos.t1_file;
        % define prefixes and add to metainfo
        metainfo.realign_prefix = 'ra_';
        metainfo.slicetime_prefix = 'st_';
        metainfo.vdm_prefix = 'u';
        metainfo.smooth_prefix = 'sm_';
        metainfo.normalize_prefix = 'no_';
        metainfo.brain_norm_index = 'bno_'; % written to anat folder!

        % check if vdm exists already:
        [imagefiles, out_vdm, vdm_exists] = getVDMexists(fmap_path, vdm_acq_mag, vdm_acq_phase, whatToDo);
        metainfo.vdmFile = out_vdm;
        metainfo.fm_files = imagefiles;

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
            disp("Unzipped EPI");
        else
            disp("EPI File is already unzipped");
        end
        disp(fullfile(metainfo.funcDir, erase(metainfo.boldFile, '.gz')));
        % remove zip part from path name
        metainfo.boldFile = erase(metainfo.boldFile, '.gz');
            
        % MAIN PART
        % Iterate over processing steps
        % (possibility to replace function doaction: something like any(strcmp(whattodo,'a'))
        for todo=1:length(whatToDo)
            action = whatToDo(todo);
            % skip VDM or SEGMENT if done already (done ones per session)
            if (strcmp(action, 'VDM') && vdm_exists) || (strcmp(action, 'SEGMENT')) % here, we skip VDM if it is already available
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
end



%% HELPER FUNCTION:
function [imagefiles, out_vdm, vdm_exists] = getVDMexists(fmap_path, vdm_acq_mag, vdm_acq_phase, whatToDo)
    % checks if vdm 5 exists already, if not, then it checks if vdm is required
    % for the processing pipeline. If it is required, the relevant file
    % paths to phase and magnitude images are returned in imagefiles
    imagefiles = '';
    vdm_files = get_files_with(fmap_path, {['acq-' num2str(vdm_acq_mag)]}, 'vdm5_sc'); % select only the ones for the current session
    if ~isempty(vdm_files) % does exist already
        assert(length(vdm_files)==1, 'several vdm5 files found. please check why there are multiple');
        vdm_exists = 1;
        out_vdm = fullfile(fmap_path, vdm_files(1)); 
        disp("vdm file exists already");
        disp(out_vdm);
    else % does not exist yet
        vdm_exists = 0;
        out_vdm = ' ';
        disp("VDM does not exist yet");
        if any(strcmp(whatToDo, 'VDM')) % does not exist but in whattodo: get relevant files to do it
            [imagefiles, out_vdm] = get_vdm_files(fmap_path, vdm_acq_mag, vdm_acq_phase);
            disp("found fieldmap files:");
            disp(imagefiles);
            disp(out_vdm);
        elseif any(strcmp(whatToDo, 'REALIGN')) % not in whattodo, but dependency
            ME = MException('myerror:filenotfounderror', 'VDM file does not exist so far. You have specified REALIGN in the processing list, but VDM is required for this step. Please add VDM to processing list or delete REALIGN from it.');
            throw(ME);
        % if vdm does not exist but also not done --> do nothing
        end
    end
end
        
       
function [imagefiles, out_vdm] = get_vdm_files(fmapDir, vdm_acq_mag, vdm_acq_phase)
    % finds the four mag and phase images in fmapDir and returns them as
    % @param imagefiles
    % @param out_fdm: File path of the vdm5 file once it is processed
    relevant_files = get_files_with(fmapDir, {{['acq-' num2str(vdm_acq_mag)], ['acq-' num2str(vdm_acq_phase)]}}, '');
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

function ascDesc = getAscDesc(slicetiming)
    % returns whether the slice timing is asc or desc or mixed
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
    % main function to collect matlabbatch: According to the input action,
    % the relevant batch script is called and the processing steps are
    % added to the matlabbatch.
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
        case 'PHYSIO'
            batch = batch_physio(metainfo, batch);
        otherwise
            error('Sorry this option for whatToDo is unknown...');
    end
end

