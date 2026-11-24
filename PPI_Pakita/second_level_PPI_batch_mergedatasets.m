% This script creates data matrix for final analysis
clear all;
clc;

studyset = struct;

% experiment folder
paths.output_path_base = '/media/sf_Share_NeuroDebian/data_james/analysis/';

studyset(1).paths.analysis_path = '/media/sf_Share_NeuroDebian/data_james/analysis';
studyset(1).paths.first_level_folder = 'stats_mni_allruns';
studyset(2).paths.analysis_path = '/media/sf_Share_NeuroDebian/cofeed16/cofeed16/analysis';
studyset(2).paths.first_level_folder = 'stats_mni_allruns_newreg';


regionnames = {'PPI_VOI_probSNVTA_gPPI'};
% subjlist to be included
% subjects
subjects_description = readtable('/media/sf_Share_NeuroDebian/data_james/SubjectDescription.csv', 'Delimiter',',','ReadVariableNames',true, 'TreatAsEmpty', {'','.','Na'});
studyset(1).subjects = subjects_description.SubjID_sort(:);
studyset(1).bool_group_intervention = subjects_description.Group_Intervention(:);
studyset(1).bool_group_control = subjects_description.Group_Control(:);
bool_learners_lydia_r32_rSN = subjects_description.Learner_Lydia_r3_r2_rSN(:);
bool_learners_lydia_r41_rSN = subjects_description.Learner_Lydia_r4_r1_rSN(:);
bool_learners_lydia_r32_prob = subjects_description.Learner_Lydia_r3_r2_prob(:);
bool_learners_lydia_r41_prob = subjects_description.Learner_Lydia_r4_r1_prob(:);
% DEFINE learners definition
studyset(1).bool_learners = bool_learners_lydia_r41_prob;
str_outfolders = {'ly41prob'};


% subjlist to be included
% subjects
subjects_description2 = readtable('/media/sf_Share_NeuroDebian/cofeed16/cofeed16/SubjectDescriptionGroups2.csv', 'Delimiter',',','ReadVariableNames',true, 'TreatAsEmpty', {'','.','Na'});
subjects_description2 = rmmissing(subjects_description2);
studyset(2).subjects = subjects_description2.SubjectID(:);
studyset(2).bool_group_intervention = subjects_description2.HealthyControl(:);
bool_learners_lydia_r32_rSN = subjects_description2.Learner_Lydia_r3_r2_rSN(:);
bool_learners_lydia_r41_rSN = subjects_description2.Learner_Lydia_r4_r1_rSN(:);
bool_learners_lydia_r32_prob = subjects_description2.Learner_Lydia_r3_r2_prob(:);
bool_learners_lydia_r41_prob = subjects_description2.Learner_Lydia_r4_r1_prob(:);
% DEFINE learners definition
studyset(2).bool_learners = bool_learners_lydia_r41_prob; % CHECK WITH LINE 29

%% create con list
% con0017 -> (UP-DOWN)r4-r1
% con0016 -> UP-DOWN_allruns


for indRegions = 1:numel(regionnames)
    current_region = cell2mat(regionnames(indRegions));
    
    current_str_outfolders = cell2mat(str_outfolders(indRegions));
    
    bool_choose_analysis = 1;
    if (1 == bool_choose_analysis)
        outdir={sprintf('group_stats_PPI_%s_r4r1_L_NL_%s', current_region, current_str_outfolders), sprintf('group_stats_PPI_%s_r2r3_L_NL_%s', current_region, current_str_outfolders)};
        conlist={'con_(UP-DOWN)r4-r1','con_(UP-DOWN)r2+r3'};
        separate_by={'Learn','Learn'};
        contrasts={[1 -1],[-1 1],[1 -1],[-1 1]};
        contrastnames={'PPI_r4r1_L>NL','PPI_r4r1_NL>L','PPI_r2r3_L>NL','PPI_r2r3_NL>L'};
    elseif (2 == bool_choose_analysis)
        outdir={sprintf('group_stats_PPI_%s_r4_Tertile_L_NL_%s', current_region, current_str_outfolders), sprintf('group_stats_PPI_%s_r3_Tertile_L_NL_%s', current_region, current_str_outfolders)};
        conlist={'con_PPI_UP-DOWN_r4_','con_PPI_UP-DOWN_r3_'};
        separate_by={'Tertile','Tertile'};
        contrasts={[1 -1],[-1 1],[1 -1],[-1 1]};
        contrastnames={'PPI_Tertile_r4_L>NL','PPI_Tertile_r4_NL>L', 'PPI_Tertile_r3_L>NL', 'PPI_Tertile_r3_NL>L'};
    elseif(3 == bool_choose_analysis)
        outdir={sprintf('group_stats_PPI_%s_r4-r1_HC_CU_L_%s', current_region, current_str_outfolders)};
        conlist={'con_(UP-DOWN)r4-r1'};
        separate_by={'LearnBoth'};
        contrasts={[1 -1],[-1 1]};
        contrastnames={'PPI_r4-r1_HCL>CUL','PPI_r4-r1_CUL>HCL'};
    elseif (4 == bool_choose_analysis)
        outdir={sprintf('group_stats_PPI_%s_r4-r1_HC_CU', current_region), sprintf('group_stats_PPI_%s_r2r3_HC_CU', current_region)};
        conlist={'con_(UP-DOWN)r4-r1','con_(UP-DOWN)r2+r3'};
        separate_by={'Health','Health'};
        contrasts={[1 -1],[-1 1],[1 -1],[-1 1]};
        contrastnames={'r4-r1_HC>CU','r4-r1_CU>HC', 'r2+r3_all_HC>CU', 'r2+r3_CU>HC'};
    elseif (7 == bool_choose_analysis)
        studyset(2).paths.first_level_folder = 'stats_mni_allruns_newreg6/PPI_VOI_dlPFC_NF_gPPI';
        studyset(1).paths.first_level_folder = 'stats_mni_allruns/PPI_VOI_dlPFC_NF_gPPI';
        outdir={['group_stats_HCBS_PPI_INT_CON_DOFL']};
        studyset(1).conlist={'con_(UP-DOWN)allruns'};
        studyset(2).conlist={'con_(UP-DOWN)allruns'};
        separate_by={'INTCON'};
        contrasts={[0 0 0 1 -1],[0 0 0 -1 1]};
        contrastnames={'allruns_INT>CON_DOFL','allruns_CON>INT_DOFL'};
        bool_use_dofl_cov = 1;
    end
    
    
    
    
    
    
    for indContrasts = 1:length(conlist)
        
        % create outdir
        paths.output_path = cell2mat(fullfile(paths.output_path_base, outdir(indContrasts)));
        % set up output path for group stat
        if ~exist(fullfile(paths.output_path),'dir')
            mkdir(fullfile(paths.output_path));
        end
        
        current_contrast = cell2mat(conlist(indContrasts));
        
        % lists according to contrast and condition
        confiles_group1 = {};
        confiles_group2 = {};
        current_covariat_vec_group1 = [];
        current_covariat_vec_group2 = [];
        for indStudysetSubjects = 1:numel(studyset)
            subjects = studyset(indStudysetSubjects).subjects;
            for  indSubj = 1:length(subjects)
                subjID = cell2mat(subjects(indSubj));
                currentPath = fullfile(studyset(indStudysetSubjects).paths.analysis_path, subjID, studyset(indStudysetSubjects).paths.first_level_folder, current_region);
                %currentFile = dir(fullfile(currentPath, [current_contrast,subjID,'.img']));
                currentFile = dir(fullfile(currentPath, [current_contrast '.nii']));
                if (isempty(currentFile))
                    currentFile = dir(fullfile(currentPath, [current_contrast '.img']));
                end
                if (~isempty(currentFile))
                    if (strcmp('Learn',separate_by(indContrasts)))
                        if (1 == studyset(indStudysetSubjects).bool_learners(indSubj) && (1 == studyset(indStudysetSubjects).bool_group_intervention(indSubj)))
                            if (isempty(confiles_group1))
                                confiles_group1 = {fullfile(currentPath, currentFile.name)};
                            else
                                confiles_group1 = [confiles_group1; fullfile(currentPath, currentFile.name)];
                            end
                            current_covariat_vec_group1 = [current_covariat_vec_group1; indStudysetSubjects];
                        elseif (0 == studyset(indStudysetSubjects).bool_learners(indSubj) && (1 == studyset(indStudysetSubjects).bool_group_intervention(indSubj)))
                            if (isempty(confiles_group2))
                                confiles_group2 = {fullfile(currentPath, currentFile.name)};
                            else
                                confiles_group2 = [confiles_group2; fullfile(currentPath, currentFile.name)];
                            end
                            current_covariat_vec_group2 = [current_covariat_vec_group2; indStudysetSubjects];
                        end
                    elseif (strcmp('Health',separate_by(indContrasts)))
                        if (1 == studyset(indStudysetSubjects).bool_healthy_control(indSubj))
                            if (isempty(confiles_group1))
                                confiles_group1 = {fullfile(currentPath, currentFile.name)};
                            else
                                confiles_group1 = [confiles_group1; fullfile(currentPath, currentFile.name)];
                            end
                            current_covariat_vec_group1 = [current_covariat_vec_group1; indStudysetSubjects];
                        else
                            if (isempty(confiles_group2))
                                confiles_group2 = {fullfile(currentPath, currentFile.name)};
                            else
                                confiles_group2 = [confiles_group2; fullfile(currentPath, currentFile.name)];
                            end
                            current_covariat_vec_group2 = [current_covariat_vec_group2; indStudysetSubjects];
                        end
                    elseif  (strcmp('HealthLearn',separate_by(indContrasts)))
                        if (1 == studyset(indStudysetSubjects).bool_healthy_control(indSubj) && 1 == studyset(indStudysetSubjects).bool_learners(indSubj))
                            if (isempty(confiles_group1))
                                confiles_group1 = {fullfile(currentPath, currentFile.name)};
                            else
                                confiles_group1 = [confiles_group1; fullfile(currentPath, currentFile.name)];
                            end
                            current_covariat_vec_group1 = [current_covariat_vec_group1; indStudysetSubjects];
                        elseif ((1 == studyset(indStudysetSubjects).bool_healthy_control(indSubj) && 0 == studyset(indStudysetSubjects).bool_learners(indSubj)))
                            if (isempty(confiles_group2))
                                confiles_group2 = {fullfile(currentPath, currentFile.name)};
                            else
                                confiles_group2 = [confiles_group2; fullfile(currentPath, currentFile.name)];
                            end
                            current_covariat_vec_group2 = [current_covariat_vec_group2; indStudysetSubjects];
                        end
                    elseif  (strcmp('LearnBoth',separate_by(indContrasts)))
                        if (1 == studyset(indStudysetSubjects).bool_healthy_control(indSubj) && 1 == studyset(indStudysetSubjects).bool_learners(indSubj))
                            if (isempty(confiles_group1))
                                confiles_group1 = {fullfile(currentPath, currentFile.name)};
                            else
                                confiles_group1 = [confiles_group1; fullfile(currentPath, currentFile.name)];
                            end
                            current_covariat_vec_group1 = [current_covariat_vec_group1; indStudysetSubjects];
                        elseif ((0 == studyset(indStudysetSubjects).bool_healthy_control(indSubj) && 1 == studyset(indStudysetSubjects).bool_learners(indSubj)))
                            if (isempty(confiles_group2))
                                confiles_group2 = {fullfile(currentPath, currentFile.name)};
                            else
                                confiles_group2 = [confiles_group2; fullfile(currentPath, currentFile.name)];
                            end
                            current_covariat_vec_group2 = [current_covariat_vec_group2; indStudysetSubjects];
                        end
                        
                    end
                else
                    fprintf('Contrast file not found: %s', fullfile(currentPath, currentFile));
                end
            end % over all subjects
        end
        % load the template
        matlabbatch = secondlevel_job_template_ttests();
        % fill with current con files and folder
        matlabbatch{1}.spm.stats.factorial_design.dir = {paths.output_path};
        matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = cellstr(confiles_group1);
        matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = cellstr(confiles_group2);
        matlabbatch{1}.spm.stats.factorial_design.cov.c = [current_covariat_vec_group1; current_covariat_vec_group2];
        matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'Studyset';
        matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
        matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;
        % TODO: set names of contrasts
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = cell2mat(contrastnames((indContrasts-1)*2+1));
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = cell2mat(contrasts((indContrasts-1)*2+1));
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = cell2mat(contrastnames((indContrasts-1)*2+2));
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = cell2mat(contrasts((indContrasts-1)*2+2));
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        
        % save the batch
        
        matlab.io.saveVariablesToScript(fullfile(paths.output_path,'secondlevel_job.m'),'matlabbatch')
        % run the batch
        spm('defaults','fMRI');
        spm_jobman('run', matlabbatch);
        
        
    end
    
end

