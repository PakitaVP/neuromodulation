function second_level_batch_fullfactorial()

% 1st Level stats for DOPANF
%

addpath('../utils');
%Base dir containing subject folders
baseDir = '';
global spmpath;

% define folders according to analysis
analysis_folder = 'task-NFTask';
first_level_folder = 'stats_task-NFTask_regulation_and_decisions_upar_downar_concat_restimplicit';

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
    output_stats_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\group_stats\NFTask_fullfactorial_decisions_restimplicit';
    if (~exist(output_stats_path, 'dir'))
        mkdir(output_stats_path);
    end
    analysis_path = fullfile('Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats', analysis_folder);
end
addpath(spmpath);


% subjects
subject_list = dir(fullfile(analysis_path, first_level_folder, 'sub-*'));
list1 =  {};list2 =  {};list3 =  {};list4 =  {};
for indSubjects = 1:numel(subject_list)
    list1(indSubjects,1) = {
        fullfile(subject_list(indSubjects).folder, subject_list(indSubjects).name ,'con_0005.nii,1')
        };
    list2(indSubjects,1) = {
        fullfile(subject_list(indSubjects).folder, subject_list(indSubjects).name ,'con_0007.nii,1')
        };
    list3(indSubjects,1) = {
        fullfile(subject_list(indSubjects).folder, subject_list(indSubjects).name ,'con_0008.nii,1')
        };
    list4(indSubjects,1) = {
        fullfile(subject_list(indSubjects).folder, subject_list(indSubjects).name ,'con_0006.nii,1')
        };

end


matlabbatch{1}.spm.stats.factorial_design.dir = {output_stats_path};
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Regulation';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Decision';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1
    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = list1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1
    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = list2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2
    1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = list3;
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2
    2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = list4;
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'C:\Users\lhellr\Documents\MATLAB\Toolboxes\spm12\tpm\mask_ICV.nii,1'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Regulations_x_Decisions';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1 -1 1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;


matlab.io.saveVariablesToScript(fullfile(output_stats_path,'secondlevel_job.m'),'matlabbatch')
spm('defaults','fMRI');
% run the batch
spm_jobman('run', matlabbatch);

end