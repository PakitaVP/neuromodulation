function second_level_batch()

    % 1st Level stats for DOPANF
    %

    addpath('../utils');
    
    %Base dir containing subject folders
    baseDir = '';
    global spmpath;
    
    % define folders according to analysis
    analysis_folder = 'task-NFTask';
    first_level_folder = 'stats_task-NFTask_regulation_only_regright_last3_concat';
 
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
        output_stats_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\group_stats\NFTask_regs_only_up+NFTask_regs_only_down_3_regwrong';
        if (~exist(output_stats_path, 'dir'))
            mkdir(output_stats_path);
        end
        analysis_path = fullfile('Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats', analysis_folder);

    end
    addpath(spmpath);


    
    % subjects
    subject_list = dir(fullfile(analysis_path, first_level_folder, 'sub-*'));

    confiles = cell(numel(subject_list),1);
    nr_of_cons = 2;
    for indSubjects = 1:numel(subject_list)
        %for indCon = 1:nr_of_cons
         %   if (1 == indCon)
                confiles{indSubjects} = fullfile(subject_list(indSubjects).folder, subject_list(indSubjects).name ,'con_0005.nii,1');
          %  else
           %     confiles{(indSubjects-1)*nr_of_cons+indCon} = fullfile(subject_list(indSubjects).folder, subject_list(indSubjects).name ,'con_0009.nii,1');
            %end
        %end
    end

    matlabbatch{1}.spm.stats.factorial_design.dir = {output_stats_path};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = confiles;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'DOWN-REST_REGWRONG';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'REST-DOWN_REGWRONG';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = -1;
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
    matlab.io.saveVariablesToScript(fullfile(output_stats_path,'secondlevel_job.m'),'matlabbatch')
    spm('defaults','fMRI');
    % run the batch
    spm_jobman('run', matlabbatch);
    
end