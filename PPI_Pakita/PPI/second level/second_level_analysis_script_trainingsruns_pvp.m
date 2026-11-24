main()

function main()

bool_pmods = 0;
    if (1 == ispc)
        %addpath(genpath("C:\Users\lhellr\Documents\MATLAB\Toolboxes\spm12"));
        if (0 == bool_pmods)
            save_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\group_stats_NFTraining\full_factorial_allruns_training_allsubs_wmcsf_confounder_restimplicit_VTA_gPPI";
        else
            save_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\group_stats_NFTraining\full_factorial_allruns_training_allsubs_wmcsf_confounder_restimplicit_VTA_pmods";
        end
        if (~exist(save_path, 'dir'))
            mkdir(save_path);
        end
        stats_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder_restimplicit_gPPI";
    
        feedbackgroup_path = "C:\Development\DOPANF_analyses\NFlearning_analyses\wholebrain_analysis\NFTraining_only_firstlevel_subjects.csv";
        postNFQ_data = readtable(feedbackgroup_path);
        postNFQ_data = renamevars(postNFQ_data,["feedback_group","subjectID_BIDS"],["Feedbackgruppe","BIDS_subID"]);

    elseif (1 == ismac)

        save_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/full_factorial_allruns_training_allsubs_wmcsf_confounder_restimplicit_VTA_gPPI";
        stats_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder_restimplicit_gPPI";
        spm_path = "/Users/pavanp/Documents/MATLAB/spm";
        feedbackgroup_path = "/Users/pavanp/PhD/NeuroFeedback/PPI_Pakita/PPI/NFTraining_only_firstlevel_subjects.csv";
        postNFQ_data = readtable(feedbackgroup_path);
        postNFQ_data = renamevars(postNFQ_data,["feedback_group","subjectID_BIDS"],["Feedbackgruppe","BIDS_subID"]);
        PPI_subfolder = "PPI_VOI_VTA_gPPI";
    end

    [list1_up_run2, list1_up_run3, list1_up_run4, list1_up_run7, list1_up_run8, list1_down_run2, list1_down_run3, list1_down_run4, list1_down_run7, list1_down_run8] = create_lists(1,postNFQ_data, stats_path, PPI_subfolder);
    [list2_up_run2, list2_up_run3, list2_up_run4, list2_up_run7, list2_up_run8, list2_down_run2, list2_down_run3, list2_down_run4, list2_down_run7, list2_down_run8] = create_lists(2,postNFQ_data, stats_path, PPI_subfolder);
    [list3_up_run2, list3_up_run3, list3_up_run4, list3_up_run7, list3_up_run8, list3_down_run2, list3_down_run3, list3_down_run4, list3_down_run7, list3_down_run8] = create_lists(3,postNFQ_data, stats_path, PPI_subfolder);

    matlabbatch = setup_matlabbatch(save_path, ...
                                    list1_up_run2, list1_up_run3, list1_up_run4, list1_up_run7, list1_up_run8, list1_down_run2, list1_down_run3, list1_down_run4, list1_down_run7, list1_down_run8,...
                                    list2_up_run2, list2_up_run3, list2_up_run4, list2_up_run7, list2_up_run8, list2_down_run2, list2_down_run3, list2_down_run4, list2_down_run7, list2_down_run8, ...
                                    list3_up_run2, list3_up_run3, list3_up_run4, list3_up_run7, list3_up_run8, list3_down_run2, list3_down_run3, list3_down_run4, list3_down_run7, list3_down_run8);

    save(fullfile(save_path, 'matlabbatch'),'matlabbatch');
    spm('defaults','fmri');
    spm_jobman('run',matlabbatch);

end



function [list_up_run2, list_up_run3, list_up_run4, list_up_run7, list_up_run8, list_down_run2, list_down_run3, list_down_run4, list_down_run7, list_down_run8] = create_lists(feedbackgroup_number,postNFQ_data,stats_path, PPI_subfolder)
    group = unique(postNFQ_data(postNFQ_data.Feedbackgruppe == feedbackgroup_number, :).BIDS_subID);
    list_up_run2 = {}; 
    list_up_run3 = {};
    list_up_run4 = {};
    list_up_run7 = {};
    list_up_run8 = {};
    list_down_run2 = {};
    list_down_run3 = {};
    list_down_run4 = {};
    list_down_run7 = {};
    list_down_run8 = {};

    for subject_index = 1:numel(group)
        current_subject = group(subject_index);
        list_up_run2(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder, ['con_PPI_UP_r2_sub-' mat2str(current_subject) '.nii']))   };
        list_up_run3(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder,['con_PPI_UP_r3_sub-' mat2str(current_subject) '.nii'] ))   };
        list_up_run4(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder,['con_PPI_UP_r4_sub-' mat2str(current_subject) '.nii'] ))   };
        list_up_run7(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder,['con_PPI_UP_r7_sub-' mat2str(current_subject) '.nii'] ))   };
        list_up_run8(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder,['con_PPI_UP_r8_sub-' mat2str(current_subject) '.nii'] ))   };
        list_down_run2(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder,['con_PPI_DOWN_r2_sub-' mat2str(current_subject) '.nii'] ))    };
        list_down_run3(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder,['con_PPI_DOWN_r3_sub-' mat2str(current_subject) '.nii'] ))    };
        list_down_run4(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder,['con_PPI_DOWN_r4_sub-' mat2str(current_subject) '.nii']))    };
        list_down_run7(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder,['con_PPI_DOWN_r7_sub-' mat2str(current_subject) '.nii'] ))    };
        list_down_run8(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], PPI_subfolder,['con_PPI_DOWN_r8_sub-' mat2str(current_subject) '.nii'] ))    };
    end
  
end
function matlabbatch = setup_matlabbatch(save_path,...
                                         list1_up_run2, list1_up_run3, list1_up_run4, list1_up_run7, list1_up_run8, list1_down_run2, list1_down_run3, list1_down_run4, list1_down_run7, list1_down_run8,...
                                         list2_up_run2, list2_up_run3, list2_up_run4, list2_up_run7, list2_up_run8, list2_down_run2, list2_down_run3, list2_down_run4, list2_down_run7, list2_down_run8, ...
                                         list3_up_run2, list3_up_run3, list3_up_run4, list3_up_run7, list3_up_run8, list3_down_run2, list3_down_run3, list3_down_run4, list3_down_run7, list3_down_run8)

    matlabbatch{1}.spm.stats.factorial_design.dir =  {char(save_path)};
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Feedbackgruppe'; %reward, punishment, neutral
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Condition'; % up or down
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).name = 'Repetition'; %runnumber 
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).levels = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(3).ancova = 0;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1 1 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = list1_up_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1 1 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = list1_up_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [1 1 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = list1_up_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [1 1 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = list1_up_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [1 1 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = list1_up_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [1 2 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = list1_down_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [1 2 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).scans = list1_down_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [1 2 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).scans = list1_down_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(9).levels = [1 2 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(9).scans = list1_down_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(10).levels = [1 2 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(10).scans = list1_down_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(11).levels = [2 1 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(11).scans = list2_up_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(12).levels = [2 1 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(12).scans = list2_up_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(13).levels = [2 1 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(13).scans = list2_up_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(14).levels = [2 1 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(14).scans = list2_up_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(15).levels = [2 1 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(15).scans = list2_up_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(16).levels = [2 2 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(16).scans = list2_down_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(17).levels = [2 2 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(17).scans = list2_down_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(18).levels = [2 2 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(18).scans = list2_down_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(19).levels = [2 2 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(19).scans = list2_down_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(20).levels = [2 2 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(20).scans = list2_down_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(21).levels = [3 1 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(21).scans = list3_up_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(22).levels = [3 1 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(22).scans = list3_up_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(23).levels = [3 1 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(23).scans = list3_up_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(24).levels = [3 1 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(24).scans = list3_up_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(25).levels = [3 1 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(25).scans = list3_up_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(26).levels = [3 2 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(26).scans = list3_down_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(27).levels = [3 2 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(27).scans = list3_down_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(28).levels = [3 2 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(28).scans = list3_down_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(29).levels = [3 2 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(29).scans = list3_down_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(30).levels = [3 2 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(30).scans = list3_down_run8;

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
    contrast_index = 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.fcon.name = 'eoi';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.fcon.weights = eye(30);
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.fcon.sessrep = 'none'; 
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) zeros(1,5) ones(1,5) zeros(1,5) ones(1,5) zeros(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)Feedbackgroups-(UP)Control_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) zeros(1,5) ones(1,5) zeros(1,5) -2*ones(1,5) zeros(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)R-(UP)C_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) zeros(1,15) -1*ones(1,5) zeros(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)P-(UP)C_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,10) ones(1,5) zeros(1,5) -1*ones(1,5) zeros(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP)R-(UP)P_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) zeros(1,5) -1*ones(1,5) zeros(1,15)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5) ones(1,5) zeros(1,5) ones(1,5) zeros(1,5) ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)Feedbackgroups-(DOWN)Control_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5) ones(1,5)  zeros(1,5) ones(1,5) zeros(1,5) -2*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)R-(DOWN)C_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5) ones(1,5) zeros(1,10) zeros(1,5) -1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)P-(DOWN)C_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,10) zeros(1,5) ones(1,5) zeros(1,5) -1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN)R-(DOWN)P_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5) ones(1,5) zeros(1,5) -1*ones(1,5) zeros(1,10)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5) -1*ones(1,5) zeros(1,5) -1*ones(1,5) zeros(1,5) -1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)Feedbackgroups-(DOWN+)Control_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5) -1*ones(1,5)  zeros(1,5) -1*ones(1,5) zeros(1,5) 2*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)R-(DOWN+)C_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5) -1*ones(1,5) zeros(1,10) zeros(1,5) 1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)P-(DOWN+)C_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,10) zeros(1,5) -1*ones(1,5) zeros(1,5) 1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(DOWN+)R-(DOWN+)P_Training';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5) -1*ones(1,5) zeros(1,5) 1*ones(1,5) zeros(1,10)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;

    %#########
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP+DOWN)Feedbackgroups-(UP+DOWN)Control';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) 1*ones(1,5) ones(1,5) 1*ones(1,5) -2*ones(1,5) -2*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP+DOWN)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) 1*ones(1,5) ones(1,5) 1*ones(1,5) 1*ones(1,5) 1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP+DOWN)R-(UP+DOWN)C';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) 1*ones(1,5) zeros(1,10) -1*ones(1,5) -1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP+DOWN)P-(UP+DOWN)C';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,10) ones(1,5) 1*ones(1,5) -1*ones(1,5) -1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP+DOWN)R-(UP+DOWN)P';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) 1*ones(1,5) -1*ones(1,5) -1*ones(1,5) zeros(1,10)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)Feedbackgroups-(UP-DOWN)Control';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) -1*ones(1,5) ones(1,5) -1*ones(1,5) -2*ones(1,5) 2*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) -1*ones(1,5) ones(1,5) -1*ones(1,5) ones(1,5) -1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)R-(UP-DOWN)C';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) -1*ones(1,5) zeros(1,10) -1*ones(1,5) 1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)P-(UP-DOWN)C';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,10) ones(1,5) -1*ones(1,5) -1*ones(1,5) 1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    contrast_index = contrast_index + 1;
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)R-(UP-DOWN)P';
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [ones(1,5) -1*ones(1,5) -1*ones(1,5) 1*ones(1,5) zeros(1,10)];
    matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    

    

    matlabbatch{3}.spm.stats.con.delete = 0;

end