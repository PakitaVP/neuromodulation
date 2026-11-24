tic;
num_run = 1; %This is what one would normally call session, but it is a run for SPM
num_session = 4; %This number is what one would normally call run, but it is a session for SPM

use_mask_for_VOI = 1;
bool_OS_linux = 1;

if (1 == bool_OS_linux)
    rootname = '/media/sf_Share_NeuroDebian/cofeed16/cofeed16/analysis';
    maskpath = '/media/sf_Share_NeuroDebian/cofeed16/cofeed16/preproc';
    batchfoldername = '/media/sf_Share_NeuroDebian/cofeed16/cofeed16/batches/NF_VTA_MVPA/spm/PPI';
    first_level_stats_folder_name = sprintf('stats_mni_allruns_newreg/');
    addpath(genpath('/usr/local/MATLAB/R2016b/toolbox/spm12'));
else
    rootname = 'D:\Share_NeuroDebian\cofeed16\cofeed16\analysis';
    maskpath = 'D:\Share_NeuroDebian\cofeed16\cofeed16\preproc';
    batchfoldername = 'D:\Share_NeuroDebian\cofeed16\cofeed16\batches\NF_VTA_MVPA\spm\PPI';
    first_level_stats_folder_name = sprintf('stats_mni_allruns\');
end



addpath(batchfoldername);
cd(batchfoldername);


% subjects
if (1 == bool_OS_linux)
    subjects_description = readtable('/media/sf_Share_NeuroDebian/cofeed16/cofeed16/SubjectDescriptionGroups2.csv', 'Delimiter',',','ReadVariableNames',true);
else
    subjects_description = readtable('D:\Share_NeuroDebian\cofeed16\cofeed16\SubjectDescriptionGroups2.csv', 'Delimiter',',','ReadVariableNames',true);
end
subjects = subjects_description.SubjectID(:);
subjIDs_to_analyze = subjects_description.SubjectID(1:2);

%% Enter the contrasts

 contraststruct = ...
     struct('names',{'eoi','UP_r1','UP_r2','UP_r3','UP_r4','DOWN_r1','DOWN_r2','DOWN_r3','DOWN_r4','UP-DOWN_r1','UP-DOWN_r2','UP-DOWN_r3','UP-DOWN_r4','UP-DOWN_allruns', 'UP-DOWN_r4-r1'},...
     'contrast_vector',{[1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],...   
                                                        [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0]...
                                                        [0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0],...
                                                        [0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0]
                        });
                    
%contraststruct = ...
%    struct('names',{'neg_vs_neut'},...
%    'contrast_vector',{[0 1 -1]});



number_contrasts = size(contraststruct,2);
%% Building participant path list

num_subjects     = size(subjIDs_to_analyze,1);
subjects_names                    = cell(num_subjects,1);
subjects_folders_first_stat_list  = cell(num_subjects,1);

% Building mask file list
subjects_folders_amy_mask_list = cell(num_subjects,1);
VOI_struct_list = cell(num_subjects,1);

%Fill up the name of each subject and the mask file respectively
for count = 1:num_subjects
    subjects_names{count,1} = cell2mat(subjIDs_to_analyze(count));
    %actual_current_subject_name = sprintf('%s',subjIDs_to_analyze(count));
    %subjects_names{count} = actual_current_subject_name;
    subjects_folders_first_stat_list{count,1} = fullfile(rootname,...
        subjects_names{count},first_level_stats_folder_name);
    
    % VOI
    % individual masks per subject
    if use_mask_for_VOI
        % put in individual mask
%         subjects_mask_file_name = fullfile(maskpath,...
%             subjects_names{count},'ROI','w_lh_newreg_thr_SN_VTA_ROI_LH.nii');
        subjects_mask_file_name = '/media/sf_Share_NeuroDebian/cofeed16/cofeed16/preproc/rSN_1mm.nii';
        subjects_folders_amy_mask_list{count,1} = subjects_mask_file_name;
        
        %     mask_for_left_Hippo = fullfile(first_part_dir_name,'015\EMOTA\batch\PPI_batches\masks\L_Hippo_aal.nii');
        %         VOIstruct = ...
        %             struct('regions',{'L_AMY'},...
        %             'mask',{subjects_mask_file_name},...
        %             'u_threshold',0.5,...
        %             'ext_threshold',0);
        %         % add to list
    else
        disp('CANNOT DO THIS');
        %         VOIstruct = ...
        %             struct('regions',{'DUNNO'},...
        %             'coordinates',{[]},...
        %             'radius',5,'u_threshold',0.5,...
        %             'ext_threshold',0);
        %         % add to list
    end
end

%number_regions = size(VOIstruct,2);


%% Computing eigenvariate for each subject with individual mask


for count_subj = 1 : num_subjects
    current_subject_location = subjects_folders_first_stat_list{count_subj,1};
    current_subject_mask = subjects_folders_amy_mask_list{count_subj,1};
    current_region_struct = ...
        struct('regions',{'rSN1mm'},...
        'mask',current_subject_mask,...
        'u_threshold',0.5,...
        'ext_threshold',0);
    fprintf('\t Eigenvariate analysis for region %s \n \t ...started \n \n \n',...
        current_region_struct.regions)
    if use_mask_for_VOI
        compute_eigenvariate_mask(current_subject_location,num_session,current_region_struct);
    else
        compute_eigenvariate(current_subject_location,num_session,current_region_struct);
    end
end
fprintf('\t Eigenvariate analysis for region %s \n \t ...done \n \n \n',...
    current_region_struct.regions)


fprintf('\t Eigenvariate analysis for all regions \n \t ...done \n \n \n')


%% Computing PPI variables for the respective contrasts


for count_contrast = 1: number_contrasts
    current_contrast_struct = contraststruct(count_contrast);
    fprintf('\t PPI analysis for contrast %s \n \t ...started \n \n \n',...
        current_contrast_struct.names)
    for count_subj = 1 : num_subjects
        
        current_subject_mask = subjects_folders_amy_mask_list{count_subj,1};
        current_region_struct = ...
            struct('regions',{'rSN1mm'},...
            'mask',current_subject_mask,...
            'u_threshold',0.5,...
            'ext_threshold',0);
        
        
        fprintf('\t PPI analysis for region %s \n \t ...started \n \n \n',...
            current_region_struct.regions)
        if use_mask_for_VOI
            VOI_str = sprintf('%s_S%i_%s_%s','VOI',num_session,current_region_struct.regions,'mask');
        else
            VOI_str = sprintf('%s_S%i_%s_%s_%d%s','VOI',num_session,current_region_struct.regions,'sphere',current_region_struct.radius,'mm_radius');
        end
        
        
        current_subject_location = subjects_folders_first_stat_list{count_subj,1};
        if use_mask_for_VOI
            compute_ppi_variables_mask(current_subject_location,num_run,num_session,VOI_str,...
                current_region_struct,current_contrast_struct);
        else
            compute_ppi_variables(current_subject_location,num_run,num_session,VOI_str,...
                current_region_struct,current_contrast_struct);
        end
        fprintf('\t PPI analysis for region %s and contrast %s \n \t ...done \n \n \n',...
            current_region_struct.regions,current_contrast_struct.names)
    end
    fprintf('\t PPI analysis for region %s \n \t ...done \n \n \n',...
        current_region_struct.regions)
end

toc;

