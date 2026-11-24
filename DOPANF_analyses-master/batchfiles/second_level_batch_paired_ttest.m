function second_level_batch_paired_ttest()

    % 1st Level stats for DOPANF
    %

    addpath('../utils');
    
    %Base dir containing subject folders
    baseDir = '';
    global spmpath;
    
    % define folders according to analysis
    analysis_folder = 'task-NFTask';
    first_level_folder = 'stats_task-NFTask_regulation_only_regright_concat_fm';
 
    data_input_path = '';
    analysis_path = '';
    if (1 == ismac)
        addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/bids-matlab'));
        spmpath = '/Users/lhellr/Documents/MATLAB/AdditionalStuff/spm12';
        addpath(genpath('/Volumes/JustData/Development/fMRwhy/fmrwhy'));
        data_bids_path = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA';
        output_stats_path = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats/XXX';
        if (~exist(output_stats_path, 'dir'))
            mkdir(output_stats_path);
        end
        analysis_path = fullfile('/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats', analysis_folder);

    elseif (1 == ispc)
        addpath(genpath('C:\Users\lhellr\Documents\MATLAB\Toolboxes\bids-matlab'));
        addpath(genpath('C:\Development\fMRwhy\fmrwhy'));
        spmpath = 'C:\Users\lhellr\Documents\MATLAB\Toolboxes\spm12';
        output_stats_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\group_stats\NFTask_regs_only_ttest';
        if (~exist(output_stats_path, 'dir'))
            mkdir(output_stats_path);
        end
        analysis_path = fullfile('Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats', analysis_folder);
    end
    addpath(spmpath);
    
    
    % subjects
    subject_list = dir(fullfile(analysis_path, first_level_folder, 'sub-*'));
    
    for indSubjects = 1:numel(subject_list)
        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(indSubjects).scans = {
            fullfile(subject_list(indSubjects).folder, subject_list(indSubjects).name ,'con_0002.nii,1')
            fullfile(subject_list(indSubjects).folder, subject_list(indSubjects).name ,'con_0004.nii,1')
            };
    end
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {output_stats_path};
    matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {'C:\Users\lhellr\Documents\MATLAB\Toolboxes\spm12\tpm\mask_ICV.nii,1'};%{''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Up-Down_Regright';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Down-Up_Regright';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
    matlab.io.saveVariablesToScript(fullfile(output_stats_path,'secondlevel_job.m'),'matlabbatch')
    spm('defaults','fMRI');
    % run the batch
    spm_jobman('run', matlabbatch);
    
end