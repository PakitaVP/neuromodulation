matlabbatch{1}.spm.stats.fmri_est.spmmat = {'/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/preproc_playground/sub-41388/SPM.mat'};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
% dependency machen für estimation




% Funktion der motion regressors einzeln 
function reg_data = load_regression_data(subject_path, subject, session_number, run_number)
    path = subject_path + "/ses-" + session_number + "/func/";
    file_name = path + "rp_temp_" + subject + "_ses-" + session_number + "_task-NFTraining_run-" + run_number + "_bold.txt";
    reg_data = {char(file_name)};
end