main()

function main()

bool_pmods = 0;
    if (1 == ispc)
        %addpath(genpath("C:\Users\lhellr\Documents\MATLAB\Toolboxes\spm12"));
        if (0 == bool_pmods)
            save_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\group_stats_NFTraining\full_factorial_BL_TR_restimplicit_VTA_gPPI";
        else
            save_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\group_stats_NFTraining\full_factorial_BL_TR_restimplicit_VTA_pmods";
        end
        if (~exist(save_path, 'dir'))
            mkdir(save_path);
        end
        stats_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder_restimplicit_pmods";
    
        feedbackgroup_path = "C:\Development\DOPANF_analyses\NFlearning_analyses\wholebrain_analysis\NFTraining_only_firstlevel_subjects.csv";
        postNFQ_data = readtable(feedbackgroup_path);
        postNFQ_data = renamevars(postNFQ_data,["feedback_group","subjectID_BIDS"],["Feedbackgruppe","BIDS_subID"]);
    
    elseif (1 == ismac)

        save_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/full_factorial_BL_TR_restimplicit_VTA_gPPI";
        stats_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder_restimplicit_gPPI";
        spm_path = "/Users/pavanp/Documents/MATLAB/spm";
        feedbackgroup_path = "/Users/pavanp/PhD/NeuroFeedback/PPI_Pakita/PPI/NFTraining_only_firstlevel_subjects.csv";
        postNFQ_data = readtable(feedbackgroup_path);
        postNFQ_data = renamevars(postNFQ_data,["feedback_group","subjectID_BIDS"],["Feedbackgruppe","BIDS_subID"]);
        PPI_subfolder = "PPI_VOI_VTA_gPPI";
 
    end

    [list1_up_run1, list1_up_run5, list1_up_run6, list1_up_run9, list1_down_run1, list1_down_run5, list1_down_run6, list1_down_run9] = create_lists(1,postNFQ_data, stats_path, PPI_subfolder);
    [list2_up_run1, list2_up_run5, list2_up_run6, list2_up_run9, list2_down_run1, list2_down_run5, list2_down_run6, list2_down_run9] = create_lists(2,postNFQ_data, stats_path, PPI_subfolder);
    [list3_up_run1, list3_up_run5, list3_up_run6, list3_up_run9, list3_down_run1, list3_down_run5, list3_down_run6, list3_down_run9] = create_lists(3,postNFQ_data, stats_path, PPI_subfolder);

    matlabbatch = setup_matlabbatch(save_path, ...
                                    list1_up_run1, list1_up_run5, list1_up_run6, list1_up_run9, list1_down_run1, list1_down_run5, list1_down_run6, list1_down_run9,...
                                    list2_up_run1, list2_up_run5, list2_up_run6, list2_up_run9, list2_down_run1, list2_down_run5, list2_down_run6, list2_down_run9, ...
                                    list3_up_run1, list3_up_run5, list3_up_run6, list3_up_run9, list3_down_run1, list3_down_run5, list3_down_run6, list3_down_run9);

    save(fullfile(save_path, 'matlabbatch'),'matlabbatch');
    spm('defaults','fmri');
    spm_jobman('run',matlabbatch);

end



function [list_up_run1, list_up_run5, list_up_run6, list_up_run9, list_down_run1, list_down_run5, list_down_run6, list_down_run9] = create_lists(feedbackgroup_number,postNFQ_data,stats_path, PPI_subfolder)
    group = unique(postNFQ_data(postNFQ_data.Feedbackgruppe == feedbackgroup_number, :).BIDS_subID);
    list_up_run1 = {}; 
    list_up_run5 = {};
    list_up_run6 = {};
    list_up_run9 = {};
    list_down_run1 = {};
    list_down_run5 = {};
    list_down_run6 = {};
    list_down_run9 = {};
    
    for subject_index = 1:numel(group)
        current_subject = group(subject_index);
        
            list_up_run1(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder, ['con_PPI_UP_r1_sub-' mat2str(current_subject) '.nii'] ))   };
            list_up_run5(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder, ['con_PPI_UP_r5_sub-' mat2str(current_subject) '.nii'] ))   };
            list_up_run6(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder, ['con_PPI_UP_r6_sub-' mat2str(current_subject) '.nii'] ))   };
            list_up_run9(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder, ['con_PPI_UP_r9_sub-' mat2str(current_subject) '.nii'] ))   };
            list_down_run1(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder, ['con_PPI_DOWN_r1_sub-' mat2str(current_subject) '.nii'] ))  };
            list_down_run5(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder, ['con_PPI_DOWN_r5_sub-' mat2str(current_subject) '.nii'] ))    };
            list_down_run6(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder, ['con_PPI_DOWN_r6_sub-' mat2str(current_subject) '.nii'] ))    };
            list_down_run9(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder, ['con_PPI_DOWN_r9_sub-' mat2str(current_subject) '.nii'] ))    };
        
    end
end

function matlabbatch = setup_matlabbatch(save_path, ...
                                    list1_up_run1, list1_up_run5, list1_up_run6, list1_up_run9, list1_down_run1, list1_down_run5, list1_down_run6, list1_down_run9,...
                                    list2_up_run1, list2_up_run5, list2_up_run6, list2_up_run9, list2_down_run1, list2_down_run5, list2_down_run6, list2_down_run9, ...
                                    list3_up_run1, list3_up_run5, list3_up_run6, list3_up_run9, list3_down_run1, list3_down_run5, list3_down_run6, list3_down_run9)

    matlabbatch{1}.spm.stats.factorial_design.dir = {char(save_path)};
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Feedbackgruppe';
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Condition';
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).name = 'Repetition';
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).levels = 4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).ancova = 0;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1 1 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = list1_up_run1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1 1 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = list1_up_run5;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [1 1 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = list1_up_run6;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [1 1 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = list1_up_run9;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [1 2 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = list1_down_run1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [1 2 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = list1_down_run5;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [1 2 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).scans = list1_down_run6;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [1 2 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).scans = list1_down_run9;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(9).levels = [2 1 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(9).scans = list2_up_run1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(10).levels = [2 1 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(10).scans = list2_up_run5;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(11).levels = [2 1 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(11).scans = list2_up_run6;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(12).levels = [2 1 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(12).scans = list2_up_run9;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(13).levels = [2 2 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(13).scans = list2_down_run1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(14).levels = [2 2 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(14).scans = list2_down_run5;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(15).levels = [2 2 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(15).scans = list2_down_run6;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(16).levels = [2 2 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(16).scans = list2_down_run9;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(17).levels = [3 1 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(17).scans = list3_up_run1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(18).levels = [3 1 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(18).scans = list3_up_run5;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(19).levels = [3 1 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(19).scans = list3_up_run6;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(20).levels = [3 1 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(20).scans = list3_up_run9;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(21).levels = [3 2 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(21).scans = list3_down_run1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(22).levels = [3 2 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(22).scans = list3_down_run5;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(23).levels = [3 2 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(23).scans = list3_down_run6;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(24).levels = [3 2 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(24).scans = list3_down_run9;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 0;
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
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'eoi';
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(24);
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none'; 
    
    %## Transfer effects single conditions #############
    contrast_index = 2;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Feedbackgroups-(UP)Control_Transfer_11';
    con_vec_UP_TR1BL1 = [-1 1 zeros(1,6)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_TR1BL1 con_vec_UP_TR1BL1 -2*con_vec_UP_TR1BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_UP_TR2BL2 = [0 0 -1 1 zeros(1,4)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Feedbackgroups-(UP)Control_Transfer_22';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_TR2BL2 con_vec_UP_TR2BL2 -2*con_vec_UP_TR2BL2];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_UP_TR2BL1 = [-1 0 0 1 zeros(1,4)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Feedbackgroups-(UP)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_TR2BL1 con_vec_UP_TR2BL1 -2*con_vec_UP_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Reward-(UP)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_TR2BL1 zeros(1,8) -1*con_vec_UP_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Punishment-(UP)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,8) con_vec_UP_TR2BL1 -1*con_vec_UP_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Reward-(UP)Punishment_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_TR2BL1 -1*con_vec_UP_TR2BL1 zeros(1,8)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWN_TR1BL1 = [zeros(1,4) -1 1 zeros(1,2)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Feedbackgroups-(DOWN)Control_Transfer_11';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_TR1BL1 con_vec_DOWN_TR1BL1 -2*con_vec_DOWN_TR1BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWN_TR2BL2 = [zeros(1,6) -1 1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Feedbackgroups-(DOWN)Control_Transfer_22';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_TR2BL2 con_vec_DOWN_TR2BL2 -2*con_vec_DOWN_TR2BL2];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWN_TR2BL1 = [zeros(1,4) -1 zeros(1,2) 1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Feedbackgroups-(DOWN)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_TR2BL1 con_vec_DOWN_TR2BL1 -2*con_vec_DOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Reward-(DOWN)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_TR2BL1 zeros(1,8) -1*con_vec_DOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Punishment-(DOWN)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,8) con_vec_DOWN_TR2BL1 -1*con_vec_DOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Reward-(DOWN)Punishment_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_TR2BL1 -1*con_vec_DOWN_TR2BL1 zeros(1,8)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWNplus_TR1BL1 = [zeros(1,4) 1 -1 zeros(1,2)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)Feedbackgroups-(DOWN+)Control_Transfer_11';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWNplus_TR1BL1 con_vec_DOWNplus_TR1BL1 -2*con_vec_DOWNplus_TR1BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWNplus_TR2BL2 = [zeros(1,6) 1 -1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)Feedbackgroups-(DOWN+)Control_Transfer_22';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWNplus_TR2BL2 con_vec_DOWNplus_TR2BL2 -2*con_vec_DOWNplus_TR2BL2];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWNplus_TR2BL1 = [zeros(1,4) 1 zeros(1,2) -1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)Feedbackgroups-(DOWN+)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWNplus_TR2BL1 con_vec_DOWNplus_TR2BL1 -2*con_vec_DOWNplus_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)Reward-(DOWN+)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWNplus_TR2BL1 zeros(1,8) -1*con_vec_DOWNplus_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)Punishment-(DOWN+)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,8) con_vec_DOWNplus_TR2BL1 -1*con_vec_DOWNplus_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)Reward-(DOWN+)Punishment_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWNplus_TR2BL1 -1*con_vec_DOWNplus_TR2BL1 zeros(1,8)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    
    %## Transfer effects combined conditions #############
    contrast_index = contrast_index + 1;
    con_vec_UPplusDOWN_TR2BL1 = [-1 0 0 1 -1 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP+DOWN)Feedbackgroups-(UP+DOWN)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UPplusDOWN_TR2BL1 con_vec_UPplusDOWN_TR2BL1 -2*con_vec_UPplusDOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP+DOWN)Reward-(UP+DOWN)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UPplusDOWN_TR2BL1 zeros(1,8) -1*con_vec_UPplusDOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP+DOWN)Punishment-(UP+DOWN)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,8) con_vec_UPplusDOWN_TR2BL1 -1*con_vec_UPplusDOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP+DOWN)Reward-(UP+DOWN)Punishment_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UPplusDOWN_TR2BL1 -1*con_vec_UPplusDOWN_TR2BL1 zeros(1,8)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_UPminusDOWN_TR2BL1 = [-1 0 0 1 1 0 0 -1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)Feedbackgroups-(UP-DOWN)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UPminusDOWN_TR2BL1 con_vec_UPminusDOWN_TR2BL1 -2*con_vec_UPminusDOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)Reward-(UP-DOWN)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UPminusDOWN_TR2BL1 zeros(1,8) -1*con_vec_UPminusDOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)Punishment-(UP-DOWN)Control_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,8) con_vec_UPminusDOWN_TR2BL1 -1*con_vec_UPminusDOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)Reward-(UP-DOWN)Punishment_Transfer_21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UPminusDOWN_TR2BL1 zeros(1,8) -1*con_vec_UPminusDOWN_TR2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

    %## Consilidation effects single conditions #############
    contrast_index = contrast_index + 1;
    con_vec_UP_BL2BL1 = [-1 0 1 0 zeros(1,4)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Feedbackgroups-(UP)Control_Consolid_BLs';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_BL2BL1 con_vec_UP_BL2BL1 -2*con_vec_UP_BL2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Reward-(UP)Control_Consolid_BLs';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_BL2BL1 zeros(1,8) -1*con_vec_UP_BL2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Punishment-(UP)Control_Consolid_BLs';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,8) con_vec_UP_BL2BL1 -1*con_vec_UP_BL2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Reward-(UP)Punishment_Consolid_BLs';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_BL2BL1 -1*con_vec_UP_BL2BL1 zeros(1,8)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_UP_BL2TR1 = [0 -1 1 0 zeros(1,4)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Feedbackgroups-(UP)Control_Consolid_BL2TR1';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_BL2TR1 con_vec_UP_BL2TR1 -2*con_vec_UP_BL2TR1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Reward-(UP)Control_Consolid_BL2TR1';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_BL2TR1 zeros(1,8) -1*con_vec_UP_BL2TR1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Punishment-(UP)Control_Consolid_BL2TR1';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,8) con_vec_UP_BL2TR1 -1*con_vec_UP_BL2TR1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Reward-(UP)Punishment_Consolid_BL2TR1';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_BL2TR1 -1*con_vec_UP_BL2TR1 zeros(1,8)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

    contrast_index = contrast_index + 1;
    con_vec_DOWN_BL2BL1 = [zeros(1,4) -1 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Feedbackgroups-(DOWN)Control_Consolid_BLs';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_BL2BL1 con_vec_DOWN_BL2BL1 -2*con_vec_DOWN_BL2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Reward-(DOWN)Control_Consolid_BLs';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_BL2BL1 zeros(1,8) -1*con_vec_DOWN_BL2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Punishment-(DOWN)Control_Consolid_BLs';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,8) con_vec_DOWN_BL2BL1 -1*con_vec_DOWN_BL2BL1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Reward-(DOWN)Punishment_Consolid_BLs';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_BL2BL1 -1*con_vec_DOWN_BL2BL1 zeros(1,8)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWN_BL2TR1 = [zeros(1,4) 0 -1 1 0];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Feedbackgroups-(DOWN)Control_Consolid_BL2TR1';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_BL2TR1 con_vec_DOWN_BL2TR1 -2*con_vec_DOWN_BL2TR1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Reward-(DOWN)Control_Consolid_BL2TR1';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_BL2TR1 zeros(1,8) -1*con_vec_DOWN_BL2TR1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Punishment-(DOWN)Control_Consolid_BL2TR1';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,8) con_vec_DOWN_BL2TR1 -1*con_vec_DOWN_BL2TR1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Reward-(DOWN)Punishment_Consolid_BL2TR1';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_BL2TR1 -1*con_vec_DOWN_BL2TR1 zeros(1,8)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_UP_BL = [1 zeros(1,7)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP_BL_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_BL con_vec_UP_BL con_vec_UP_BL];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_UP_TR = [0 0 0 1 zeros(1,4)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP_TR_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_TR con_vec_UP_TR con_vec_UP_TR];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_UP_TRBL = [-1 0 0 1 zeros(1,4)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)_allgroups_Transfer21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_UP_TRBL con_vec_UP_TRBL con_vec_UP_TRBL];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

    contrast_index = contrast_index + 1;
    con_vec_DOWN_BL = [zeros(1,4) 1 zeros(1,3)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DOWN_BL_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_BL con_vec_DOWN_BL con_vec_DOWN_BL];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWN_TR = [zeros(1,7) 1 ];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DOWN_TR_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_TR con_vec_DOWN_TR con_vec_DOWN_TR];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWN_TRBL = [zeros(1,4) -1 0 0 1 ];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)_allgroups_Transfer21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_TRBL con_vec_DOWN_TRBL con_vec_DOWN_TRBL];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

    contrast_index = contrast_index + 1;
    con_vec_DOWN_BL = [zeros(1,4) -1 zeros(1,3)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DOWN+_BL_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_BL con_vec_DOWN_BL con_vec_DOWN_BL];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWN_TR = [zeros(1,7) -1 ];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DOWN+_TR_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_TR con_vec_DOWN_TR con_vec_DOWN_TR];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    con_vec_DOWN_TRBL = [zeros(1,4) 1 0 0 -1 ];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)_allgroups_Transfer21';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_DOWN_TRBL con_vec_DOWN_TRBL con_vec_DOWN_TRBL];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

    contrast_index = contrast_index + 1;
    con_vec_fullinteraction = [1 -1 -1 1 zeros(1,4)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP_TR2BL2-TR1BL1_FB>C';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_fullinteraction con_vec_fullinteraction -2*con_vec_fullinteraction];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

    contrast_index = contrast_index + 1;
    con_vec_all = [1 1 1 1 zeros(1,4)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP_allgroups_allruns';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_all con_vec_all con_vec_all];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

    contrast_index = contrast_index + 1;
    con_vec_all = [zeros(1,4) 1 1 1 1];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DOWN_allgroups_allruns';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [con_vec_all con_vec_all con_vec_all];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';


    matlabbatch{3}.spm.stats.con.delete = 0;

end