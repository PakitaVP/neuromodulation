%% Script for gPPI analysis

% In general:
% Make sure spm8 is installed. but spm 25 and matlab 2022b also worked.
% Check the parameters.mat file in the PPI folder
% Check the following steps in this script:
% step (1): check paths
% step (2): define a name for your output folders according to region name
% step (3): define a name for your output folders according to region name
% step (4): define all region files, i.e. the masks of each seed
% step (5): define contrasts

%%
function PPPI_FSFAST_WRAPPER()

% spm8 benutzen!!
spmpath = which('spm')
if(~isempty(spmpath))
    rmpath(genpath(fileparts(spmpath)))
end
clear classes

bool_pmod_analysis = 0;  % set to 1 if you really want the pmod contrasts 13..24

% Do step (1): check paths
subjects_description = readtable('/Users/pavanp/PhD/NeuroFeedback/PPI_Pakita/PPI/NFTraining_only_firstlevel_subjects.csv', 'Delimiter',',','ReadVariableNames',true);

addpath(genpath('/Users/pavanp/Documents/MATLAB/spm'));
addpath('/Users/pavanp/PhD/NeuroFeedback/PPI_Pakita/PPI/PPPIv13')

Study_Dir='/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder_restimplicit_gPPI'; %Study_Dir='/Users/pavanp/PhD/NeuroFeedback/PPI_Pakita/data/task-NFTraining_wmcsf_confounder_restimplicit_gPPI';
Mask_Dir_indiv='/Volumes/JustData/Projects/DOPANF/Masks/DOPANF_Masks_analyses/SubstantiaNigra'; %Mask_Dir_indiv='/Users/pavanp/PhD/NeuroFeedback/PPI_Pakita/data'; 

%Mask_Dir_MNI = '/media/sf_Share_NeuroDebian/cofeed16/cofeed16/masks/';
%Mask_Dir_Special = '/media/sf_Share_NeuroDebian/masks_general/Mask_extracts/Masks_20180917/';
param_file = '/Users/pavanp/PhD/NeuroFeedback/PPI_Pakita/PPI/parameters.mat';

Subjects = unique(subjects_description.subjectID_BIDS(:));

% Convert Subjects into a consistent "string array" (easy indexing with ())
if iscell(Subjects)
    Subjects = string(Subjects);
elseif ischar(Subjects)
    Subjects = string(cellstr(Subjects));
else
    Subjects = string(Subjects);
end

% Do step (2): define a name for your output folders according to region
% name 
%regionname={'VOI_SN_VTA_gPPI'};
regionname={'VOI_SN_gPPI'};
%regionname={'VOI_VTA_gPPI'};

% first-level folder name under each subject --> subject folder already contains SPM.mat
Subject_Subdirectory = '';

%% run
for indSubj = 3 %54:numel(Subjects) %3:numel(Subjects) %1  % change to: 1:numel(Subjects) when ready

    subj_id = char(Subjects(indSubj));       % "30823"
    subj_dirname = ['sub-' subj_id];         % "sub-30823"
    subj = subj_dirname;   % define for later use 

    Directory = fullfile(Study_Dir, subj_dirname, Subject_Subdirectory);

    % Quick existence checks (helpful when nothing happens)
    if ~exist(Directory, 'dir')
        fprintf('Directory not found, skipping: %s\n', Directory);
        continue
    end
    
    spmmat = fullfile(Directory, 'SPM.mat');
    if ~exist(spmmat, 'file')
        fprintf('SPM.mat not found, skipping: %s\n', spmmat);
        continue
    end

    % ROI file (seed mask)
    subjects_mask_file_name = fullfile(Mask_Dir_indiv, 'mean_SN.nii');

    if ~exist(subjects_mask_file_name, 'file')
        fprintf('ROI file not found, skipping: %s\n', subjects_mask_file_name);
        continue
    end

    % Region list (1 ROI for now)
    regionfile = {subjects_mask_file_name};

    % Loop ROIs
    for jj = 1:numel(regionfile)
        try
            cd(Directory);

            % Load template parameters (must contain struct P or create it)
            S = load(param_file);

            % If parameters.mat contains P already, use it; otherwise, make an empty struct
            if isfield(S, 'P')
                P = S.P;
            else
                P = struct();
            end

            % Required fields
            P.subject   = subj;
            P.directory = Directory;

            P.VOI    = regionfile{jj};
            P.Region = regionname{jj};

            P.maskdir = subjects_mask_file_name;

            P.method   = 'cond';     % generalized / condition-specific PPI
            P.analysis = 'psy';               % single-seed PPI
            P.Tasks    = {'1','UP','DOWN'};   % the 1 require UP/DOWN in all sessions, can change it to 0 if that is not required. in the SPM.mat files there is also a condition "FIX" but I didn;'t put that in
            
            %try to get rid of the error of the missing conditions and
            %invalid contrasts
            P.contrast = 0;
            
%             %these are the path changes when working on pakita macbook
%             if (ismac)
%                 spm_changepath('SPM.mat', ...
%                     ['Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc\' subj_dirname '\ses-2\func\'], ...
%                     ['/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc/' subj_dirname '/ses-2/func/']);
% 
%                 spm_changepath('SPM.mat', ...
%                     ['Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc\' subj_dirname '\ses-1\func\'], ...
%                     ['/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc/' subj_dirname '/ses-1/func/']);
% 
%                 load(fullfile(Directory,'SPM.mat'));   % loads variable SPM
%                 swd_path_new = strrep(SPM.swd, ...
%                     'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder_restimplicit\', ...
%                     '/Users/pavanp/PhD/NeuroFeedback/PPI_Pakita/data/task-NFTraining_wmcsf_confounder_restimplicit_gPPI');
%                 SPM.swd = swd_path_new;
% 
%                 save(fullfile(swd_path_new, 'SPM.mat'), 'SPM');
%             else


%             uncomment when working on the server 
            if (ismac)
                spm_changepath('SPM.mat', ...
                    ['Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc\' subj_dirname '\ses-2\func\'], ...
                    ['/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc/' subj_dirname '/ses-2/func/']);

                spm_changepath('SPM.mat', ...
                    ['Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc\' subj_dirname '\ses-1\func\'], ...
                    ['/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc/' subj_dirname '/ses-1/func/']);

                load(fullfile(Directory,'SPM.mat'));   % loads variable SPM
                swd_path_new = strrep(SPM.swd, ...
                    'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder_restimplicit\', ...
                    '/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder_restimplicit_gPPI/');
                SPM.swd = swd_path_new;

                save(fullfile(swd_path_new, 'SPM.mat'), 'SPM');
            else
                 % get number of sessions
                load(fullfile(Directory,'SPM.mat'));   % loads variable SPM
            end
            P.outdir = swd_path_new;


            if isfield(P,'VOI2'), P = rmfield(P,'VOI2'); end

            P.Contrasts = struct([]);
            
            nSess = numel(SPM.Sess);   % should be 9 for our subjects

            c = 0;

            % UP per run
            for s = 1:nSess
                c = c+1;
                P.Contrasts(c).left     = {'UP'};
                P.Contrasts(c).right    = {'none'};
                P.Contrasts(c).STAT     = 'T';
                P.Contrasts(c).Weighted = 0;
                P.Contrasts(c).MinEvents= 1;
                P.Contrasts(c).name     = sprintf('UP_r%d', s);
                P.Contrasts(c).Prefix   = sprintf('Sn(%d)', s);
            end
            
            % DOWN per run
            for s = 1:nSess
                c = c+1;
                P.Contrasts(c).left     = {'DOWN'};
                P.Contrasts(c).right    = {'none'};
                P.Contrasts(c).STAT     = 'T';
                P.Contrasts(c).Weighted = 0;
                P.Contrasts(c).MinEvents= 1;
                P.Contrasts(c).name     = sprintf('DOWN_r%d', s);
                P.Contrasts(c).Prefix   = sprintf('Sn(%d)', s);
            end
            
            % UP - DOWN per run
            for s = 1:nSess
                c = c+1;
                P.Contrasts(c).left     = {'UP'};
                P.Contrasts(c).right    = {'DOWN'};
                P.Contrasts(c).STAT     = 'T';
                P.Contrasts(c).Weighted = 0;
                P.Contrasts(c).MinEvents= 1;
                P.Contrasts(c).name     = sprintf('UP-DOWN_r%d', s);
                P.Contrasts(c).Prefix   = sprintf('Sn(%d)', s);
            end


            if bool_pmod_analysis == 1
                P.Contrasts(13).left={'UPxFeedbackValues^1'};
                P.Contrasts(13).right={'none'};
                P.Contrasts(13).STAT='T';
                P.Contrasts(13).Weighted=0;
                P.Contrasts(13).MinEvents=1;
                P.Contrasts(13).name='UP_FB1';
                P.Contrasts(13).Prefix='Sn(1)';
    
                P.Contrasts(14).left={'UPxFeedbackValues^1'};
                P.Contrasts(14).right={'none'};
                P.Contrasts(14).STAT='T';
                P.Contrasts(14).Weighted=0;
                P.Contrasts(14).MinEvents=1;
                P.Contrasts(14).name='UP_FB2';
                P.Contrasts(14).Prefix='Sn(2)';
    
                P.Contrasts(15).left={'UPxFeedbackValues^1'};
                P.Contrasts(15).right={'none'};
                P.Contrasts(15).STAT='T';
                P.Contrasts(15).Weighted=0;
                P.Contrasts(15).MinEvents=1;
                P.Contrasts(15).name='UP_FB3';
                P.Contrasts(15).Prefix='Sn(3)';
    
                P.Contrasts(16).left={'UPxFeedbackValues^1'};
                P.Contrasts(16).right={'none'};
                P.Contrasts(16).STAT='T';
                P.Contrasts(16).Weighted=0;
                P.Contrasts(16).MinEvents=1;
                P.Contrasts(16).name='UP_FB4';
                P.Contrasts(16).Prefix='Sn(4)';
    
                P.Contrasts(17).left={'DOWNxFeedbackValues^1'};
                P.Contrasts(17).right={'none'};
                P.Contrasts(17).STAT='T';
                P.Contrasts(17).Weighted=0;
                P.Contrasts(17).MinEvents=1;
                P.Contrasts(17).name='DOWN_FB1';
                P.Contrasts(17).Prefix='Sn(1)';
    
                P.Contrasts(18).left={'DOWNxFeedbackValues^1'};
                P.Contrasts(18).right={'none'};
                P.Contrasts(18).STAT='T';
                P.Contrasts(18).Weighted=0;
                P.Contrasts(18).MinEvents=1;
                P.Contrasts(18).name='DOWN_FB2';
                P.Contrasts(18).Prefix='Sn(2)';
    
                P.Contrasts(19).left={'DOWNxFeedbackValues^1'};
                P.Contrasts(19).right={'none'};
                P.Contrasts(19).STAT='T';
                P.Contrasts(19).Weighted=0;
                P.Contrasts(19).MinEvents=1;
                P.Contrasts(19).name='DOWN_FB3';
                P.Contrasts(19).Prefix='Sn(3)';
    
                P.Contrasts(20).left={'DOWNxFeedbackValues^1'};
                P.Contrasts(20).right={'none'};
                P.Contrasts(20).STAT='T';
                P.Contrasts(20).Weighted=0;
                P.Contrasts(20).MinEvents=1;
                P.Contrasts(20).name='DOWN_FB4';
                P.Contrasts(20).Prefix='Sn(4)';
    
                P.Contrasts(21).left={'UPxFeedbackValues^1'};
                P.Contrasts(21).right={'DOWNxFeedbackValues^1'};
                P.Contrasts(21).STAT='T';
                P.Contrasts(21).Weighted=0;
                P.Contrasts(21).MinEvents=1;
                P.Contrasts(21).name='UP-DOWN_FB1';
                P.Contrasts(21).Prefix='Sn(1)';
    
                P.Contrasts(22).left={'UPxFeedbackValues^1'};
                P.Contrasts(22).right={'DOWNxFeedbackValues^1'};
                P.Contrasts(22).STAT='T';
                P.Contrasts(22).Weighted=0;
                P.Contrasts(22).MinEvents=1;
                P.Contrasts(22).name='UP-DOWN_FB2';
                P.Contrasts(22).Prefix='Sn(2)';
    
                P.Contrasts(23).left={'UPxFeedbackValues^1'};
                P.Contrasts(23).right={'DOWNxFeedbackValues^1'};
                P.Contrasts(23).STAT='T';
                P.Contrasts(23).Weighted=0;
                P.Contrasts(23).MinEvents=1;
                P.Contrasts(23).name='UP-DOWN_FB3';
                P.Contrasts(23).Prefix='Sn(3)';
    
                P.Contrasts(24).left={'UPxFeedbackValues^1'};
                P.Contrasts(24).right={'DOWNxFeedbackValues^1'};
                P.Contrasts(24).STAT='T';
                P.Contrasts(24).Weighted=0;
                P.Contrasts(24).MinEvents=1;
                P.Contrasts(24).name='UP-DOWN_FB4';
                P.Contrasts(24).Prefix='Sn(4)';

            end
%% --- (4) Save config + run PPPI ---
            cfgfile = fullfile(Directory, sprintf('%s_%s_PPI_config.mat', subj, P.Region));
            
            % ---- disable any zip/gzip logic (often inherited from parameters.mat) ----
            P.zip = 0;
            if isfield(P,'zipfiles'),  P.zipfiles = 0; end
            if isfield(P,'zipFile'),   P = rmfield(P,'zipFile'); end
            if isfield(P,'gunzip'),    P = rmfield(P,'gunzip'); end
            if isfield(P,'gzip'),      P = rmfield(P,'gzip'); end
                        
            save(cfgfile, 'P');

            fprintf('Running PPPI with config:\n  %s\n', cfgfile);

            disp(P.Tasks)
            disp({P.Contrasts(1:3).name})
            disp({P.Contrasts(1:3).Prefix})

            tPPPI = tic;
            fprintf('[%s] Starting PPPI for %s | %s\n', datestr(now,'yyyy-mm-dd HH:MM:SS'), subj, P.Region);
            PPPI(cfgfile);
            fprintf('[%s] Finished PPPI for %s | %s (%.1f min)\n', datestr(now,'yyyy-mm-dd HH:MM:SS'), subj, P.Region, toc(tPPPI)/60);

            fprintf('Finished %s | %s\n', subj, P.Region);

        catch ME
            fprintf('FAILED %s | %s\n', subj, regionname{jj});
            fprintf('%s\n', ME.message);
            % Uncomment for full stack:
            disp(getReport(ME,'extended'));
        end
    end
        % You will want to zip the files here if P.zipfiles is not set to 1.
end

end




