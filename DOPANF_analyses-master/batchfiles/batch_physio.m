function matlabbatch = batch_physio(metainfo, matlabbatch)   
    ind = length(matlabbatch)+1;
    disp("pysio - matlabbatch index:");
    disp(ind);
    
    json_file = loadjson([fullfile(metainfo.funcDir, erase(metainfo.physioFile, '.tsv.gz')) '.json']);
    
    metainfo.physioDirPath = [fullfile(metainfo.funcDir, erase(metainfo.physioFile, '.tsv.gz')) '_new_header' '.tsv'];
    if ~exist(metainfo.physioDirPath, 'file') % ~exist(fullfile(metainfo.funcDir, erase(metainfo.physioDir, '.gz')
        disp("Unzip the physio file");
        filename = fullfile(metainfo.funcDir, metainfo.physioFile);
        gunzip(filename);
        fidin = fopen(erase(filename, '.gz'), 'rt'); % WORKS BUT takes forever because whole file is copied
        fidout = fopen(metainfo.physioDirPath, 'wt');
        % add header
        fprintf(fidout, '## %s\n', json_file.Site{1});
        fprintf(fidout, '## %s\n', json_file.PhysDate);
        fprintf(fidout, '## ');
        fprintf(fidout, '%d ', json_file.ScanphysStats(1:9));
        fprintf(fidout, '\n');
        if json_file.DockableTable
            fprintf(fidout, '%s\n', '## Dockable table = TRUE');
        else
            fprintf(fidout, '%s\n', '## Dockable table = FALSE');
        end
        fprintf(fidout, '%s', '# ');
        while true % write old data line by line
          thisline = fgets(fidin);
          if ~ischar(thisline); break; end   %end of file
          fwrite(fidout, thisline);
        end
        fclose(fidout);
        fclose(fidin);
        disp("physio file was written again with header");
    else
        disp("File is already unzipped");
    end
    
    matlabbatch{ind}.spm.tools.physio.save_dir = {fullfile(metainfo.funcDir, 'physio_out')};
    matlabbatch{ind}.spm.tools.physio.log_files.vendor = 'Philips';
    matlabbatch{ind}.spm.tools.physio.log_files.cardiac = {metainfo.physioDirPath}; 
    matlabbatch{ind}.spm.tools.physio.log_files.respiration = {metainfo.physioDirPath}; % cellstr(metainfo.physioDirPath); 
    matlabbatch{ind}.spm.tools.physio.log_files.scan_timing = cellstr([erase(metainfo.physioDirPath, '.tsv.gz') '.json']); % cellstr(metainfo.physioDirPath); 
    matlabbatch{ind}.spm.tools.physio.log_files.sampling_interval = 0.002;
    matlabbatch{ind}.spm.tools.physio.log_files.relative_start_acquisition = 0;
    matlabbatch{ind}.spm.tools.physio.log_files.align_scan = 'last';
    matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.Nslices = metainfo.MaxSlices; % 37;
    matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
    matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.TR = metainfo.RepetitionTime; % 2.5;
    matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.Ndummies = 5;
    matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.Nscans = length(metainfo.DynamicScanNumber);% metainfo.MaxDynamics; % 495;
    matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.onset_slice = 1; % 19;
    matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
    matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
    matlabbatch{ind}.spm.tools.physio.scan_timing.sync.noinal = [];
    %matlabbatch{ind}.spm.tools.physio.scan_timing.sync.gradient_log.grad_direction = 'y';
    %matlabbatch{ind}.spm.tools.physio.scan_timing.sync.gradient_log.zero = 0.2;
    %matlabbatch{ind}.spm.tools.physio.scan_timing.sync.gradient_log.slice = 0.25; % 0.45;
    %matlabbatch{ind}.spm.tools.physio.scan_timing.sync.gradient_log.vol = [];
    %matlabbatch{ind}.spm.tools.physio.scan_timing.sync.gradient_log.vol_spacing = [];
    matlabbatch{ind}.spm.tools.physio.preproc.cardiac.modality = 'PPU';
    matlabbatch{ind}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.load_from_logfile = struct([]);
    matlabbatch{ind}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
    matlabbatch{ind}.spm.tools.physio.model.output_multiple_regressors = 'multiple_regressors.txt';
    matlabbatch{ind}.spm.tools.physio.model.output_physio = 'physio.mat';
    matlabbatch{ind}.spm.tools.physio.model.orthogonalise = 'none';
    matlabbatch{ind}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
    matlabbatch{ind}.spm.tools.physio.model.retroicor.yes.order.c = 3;
    matlabbatch{ind}.spm.tools.physio.model.retroicor.yes.order.r = 4;
    matlabbatch{ind}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
    matlabbatch{ind}.spm.tools.physio.model.rvt.no = struct([]);
    matlabbatch{ind}.spm.tools.physio.model.hrv.no = struct([]);
    matlabbatch{ind}.spm.tools.physio.model.noise_rois.no = struct([]);
    matlabbatch{ind}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {'rp_fMRI.txt'};
    matlabbatch{ind}.spm.tools.physio.model.movement.yes.order = 6;
    matlabbatch{ind}.spm.tools.physio.model.movement.yes.censoring_method = 'MAXVAL';
    matlabbatch{ind}.spm.tools.physio.model.movement.yes.censoring_threshold = [3 Inf];
    matlabbatch{ind}.spm.tools.physio.model.other.no = struct([]);
    matlabbatch{ind}.spm.tools.physio.verbose.level = 2;
    matlabbatch{ind}.spm.tools.physio.verbose.fig_output_file = 'PhysIO_output.fig';
    matlabbatch{ind}.spm.tools.physio.verbose.use_tabs = false;
end

