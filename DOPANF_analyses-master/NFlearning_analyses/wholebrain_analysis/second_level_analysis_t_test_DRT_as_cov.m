

data_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc';
data_searchterm = '*_desc-swrapreproc_bold.nii';
output_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\timeseries_analysis';
data_bids_path = 'Z:\Projects\DOPANF\Data\DOPANF_QA';
[current_path,~,~] = fileparts(mfilename('fullpath'));


% subjects
subjects_description = readtable(fullfile(current_path, '..', 'NFTraining_only_firstlevel_subjects.csv'), 'Delimiter',',','ReadVariableNames',true);
subjects = subjects_description.subjectID_BIDS(:);
group = subjects_description.feedback_group(:);


bool_add_drt = 1;
%DRTslope_ses-all_condition_UP_mask-probSNVTA_task-NFTraining_wmcsf_confounder.csv
%DRTslope_ses-all_condition_DOWN_mask-probSNVTA_task-NFTraining_wmcsf_confounder.csv
%DRTslope_ses-all_condition_UP-DOWN_mask-probSNVTA_task-NFTraining_wmcsf_confounder.csv
drt_table = readtable('Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\extract_from_cons\DRTslope_ses-all_condition_UP-DOWN_mask-probSNVTA_task-NFTraining_wmcsf_confounder_rest-down.csv');
subjects = drt_table.subject(find(drt_table.group ==1));
drts = drt_table.DRT12(find(drt_table.group ==1));


paths.output_path_base = 'Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\group_stats_NFTraining\one_sample_t-tests';
outdir=['group_stats_(UP-DOWN)Tr2-BL1_onesample_DRT' num2str(bool_add_drt) '_groupReward'];
paths.output_path = fullfile(paths.output_path_base, outdir);

confiles_group1 = '';
conimg = 'con_0042.nii';
drt_vec = [];
for indSubject = 1:numel(subjects)
   
    
   if (isempty(confiles_group1))
       confiles_group1 = {['Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder' filesep 'sub-' mat2str(subjects(indSubject)) filesep conimg]};
   else
       confiles_group1 = [confiles_group1; ['Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder' filesep 'sub-' mat2str(subjects(indSubject)) filesep conimg]];
   end 
   drt_vec(indSubject) = drts(indSubject);
end



matlabbatch{1}.spm.stats.factorial_design.dir = {paths.output_path};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = confiles_group1;
matlabbatch{1}.spm.stats.factorial_design.cov.c = drt_vec;
matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'DRT';
matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;
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
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Transfer2-Baseline1';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Basline1-Transfer2';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'DRT_Positive';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'DRT_Negative';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 -1];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

spm('defaults','fMRI');
    % run the batch
    spm_jobman('run', matlabbatch);