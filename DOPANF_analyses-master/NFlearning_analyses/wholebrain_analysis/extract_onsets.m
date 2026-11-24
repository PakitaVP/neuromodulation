function [] = extract_onsets(data_preproc_path, data_bids_path, subjects_dataset, nr_of_sessions)



for indSubjects = 1:numel(subjects_dataset)
    
    current_subject = subjects_dataset{indSubjects};
    current_nr_of_runs = [5 4];
    
    for indSessions = 1:numel(nr_of_sessions)
        for indRuns = 1:current_nr_of_runs(indSessions)
            
            str = fprintf('Create onset file for Subject: %s', ['sub-' mat2str(current_subject)]);
            disp(str);
            Onsets = struct();
            Duration = struct();
            % load all params for conditions in 1st level analysis -
            % on/offsets and duration for all available conditions
            % they need to be re-formatted 
            % load from condsOnOff file raw information of conditions
            fname_conditions = dir(fullfile(data_bids_path, ['sub-' current_subject], ['ses-' mat2str(indSessions)], 'beh' ,['*_run-' mat2str(indRuns) '_condsOnOff_beh_task-NFTraining.json']));
            fid = fopen(fullfile(fname_conditions.folder, fname_conditions.name));
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);
            conditions_raw = jsondecode(str);
            max_rows = max([length(conditions_raw.Bas(:,1)), length(conditions_raw.NFup(:,1)), length(conditions_raw.Fix(:,1)), length(conditions_raw.NFdown(:,1))]);
                        
            Onsets.REST = [conditions_raw.Bas(:,1); nan(1, max_rows - length(conditions_raw.Bas(:,1)))];
            Duration.REST = [conditions_raw.Bas(:,2)-conditions_raw.Bas(:,1)+1; nan(1, max_rows - length(conditions_raw.Bas(:,1)))]; 
            Onsets.NFUp = [conditions_raw.NFup(:,1); nan(1, max_rows - length(conditions_raw.NFup(:,1)))];
            Duration.NFUp = [conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1; nan(1, max_rows - length(conditions_raw.NFup(:,1)))];
            Duration.NFUp_1stHalf = [ceil((conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1)/2); nan(1, max_rows - length(conditions_raw.NFup(:,1)))];
            Duration.NFUp_2ndHalf = [(conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1) - ceil((conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1)/2);...
                                    nan(1, max_rows - length(conditions_raw.NFup(:,1)))];
            Onsets.NFUp_2ndHalf = [conditions_raw.NFup(:,1) + ceil((conditions_raw.NFup(:,2)-conditions_raw.NFup(:,1)+1)/2);...
                                  nan(1, max_rows - length(conditions_raw.NFup(:,1)))];
            Onsets.Fix = [conditions_raw.Fix(:,1); nan(1, max_rows - length(conditions_raw.Fix(:,1)))];
            Duration.Fix = [conditions_raw.Fix(:,2)-conditions_raw.Fix(:,1)+1; nan(1, max_rows - length(conditions_raw.Fix(:,1)))];
            Onsets.NFDown = [conditions_raw.NFdown(:,1); nan(1, max_rows - length(conditions_raw.NFdown(:,1)))];
            Duration.NFDown = [conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1; nan(1, max_rows - length(conditions_raw.NFdown(:,1)))];
            Duration.NFDown_1stHalf = [ceil((conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1)/2); nan(1, max_rows - length(conditions_raw.NFdown(:,1)))];
            Duration.NFDown_2ndHalf = [conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1 - ceil((conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1)/2);...
                                      nan(1, max_rows - length(conditions_raw.NFdown(:,1)))];
            Onsets.NFDown_2ndHalf = [conditions_raw.NFdown(:,1) + ceil((conditions_raw.NFdown(:,2)-conditions_raw.NFdown(:,1)+1)/2);...
                                    nan(1, max_rows - length(conditions_raw.NFdown(:,1)))];

            [outfilename_onsets, outfilepath] = fmrwhy_bids_constructFilename('beh', 'sub', current_subject, 'ses', mat2str(indSessions), 'task', 'NFTraining', 'run', mat2str(indRuns), 'desc', 'onsets', 'ext', '.csv');
            [outfilename_durations, outfilepath] = fmrwhy_bids_constructFilename('beh', 'sub', current_subject, 'ses', mat2str(indSessions), 'task', 'NFTraining', 'run', mat2str(indRuns), 'desc', 'durations', 'ext', '.csv');
            if (0 == exist(fullfile(data_preproc_path, outfilepath), 'dir'))
                mkdir(fullfile(data_preproc_path, outfilepath));
            end
            writetable(struct2table(Duration), fullfile(data_preproc_path, outfilepath, outfilename_durations), 'FileType', 'text', 'WriteVariableNames',1, 'WriteMode', 'overwrite');
            writetable(struct2table(Onsets), fullfile(data_preproc_path, outfilepath, outfilename_onsets), 'FileType', 'text', 'WriteVariableNames',1, 'WriteMode', 'overwrite');

        end
    end
end

     
   