main()

function main()

    save_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/full_factorial_BL_TR_ohne_7_motion_subs";
    stats_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining";
    spm_path = "/Users/malimaurer/Documents/MATLAB/zusaetzlich/spm12";
    feedbackgroup_path = "/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/PostNFQ_merged.csv";
    
    postNFQ_data = readtable(feedbackgroup_path);   

    [list1_up_run1, list1_up_run5, list1_up_run6, list1_up_run9, list1_down_run1, list1_down_run5, list1_down_run6, list1_down_run9] = create_lists(1,postNFQ_data, stats_path);
    [list2_up_run1, list2_up_run5, list2_up_run6, list2_up_run9, list2_down_run1, list2_down_run5, list2_down_run6, list2_down_run9] = create_lists(2,postNFQ_data, stats_path);
    [list3_up_run1, list3_up_run5, list3_up_run6, list3_up_run9, list3_down_run1, list3_down_run5, list3_down_run6, list3_down_run9] = create_lists(3,postNFQ_data, stats_path);

    matlabbatch = setup_matlabbatch(list1_up_run1, list1_up_run5, list1_up_run6, list1_up_run9, list1_down_run1, list1_down_run5, list1_down_run6, list1_down_run9,...
                                    list2_up_run1, list2_up_run5, list2_up_run6, list2_up_run9, list2_down_run1, list2_down_run5, list2_down_run6, list2_down_run9, ...
                                    list3_up_run1, list3_up_run5, list3_up_run6, list3_up_run9, list3_down_run1, list3_down_run5, list3_down_run6, list3_down_run9);

    save(save_path,'matlabbatch')
    spm('defaults','fmri');
    spm_jobman('run',matlabbatch);

end



function [list_up_run1, list_up_run5, list_up_run6, list_up_run9, list_down_run1, list_down_run5, list_down_run6, list_down_run9] = create_lists(feedbackgroup_number,postNFQ_data,stats_path)
    group = postNFQ_data(postNFQ_data.Feedbackgruppe == feedbackgroup_number, :).BIDS_subID;
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

        if current_subject == 30823 || current_subject == 34697 || current_subject == 36535 || current_subject == 41734 || current_subject == 45970 || current_subject == 46831 || current_subject == 46971
           disp("would not run for: " + current_subject);
           continue;
        end

        list_up_run1(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0003.nii,1" ))   };
        list_up_run5(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0004.nii,1" ))   };
        list_up_run6(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0005.nii,1" ))   };
        list_up_run9(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0008.nii,1" ))   };
        list_down_run1(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0012.nii,1" ))    };
        list_down_run5(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0013.nii,1" ))    };
        list_down_run6(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0014.nii,1" ))    };
        list_down_run9(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0017.nii,1" ))    };
        
    end
    list_up_run1 = list_up_run1(~cellfun('isempty',list_up_run1));
    list_up_run5 = list_up_run5(~cellfun('isempty',list_up_run5));
    list_up_run6 = list_up_run6(~cellfun('isempty',list_up_run6));
    list_up_run9 = list_up_run9(~cellfun('isempty',list_up_run9));
    list_down_run1 = list_down_run1(~cellfun('isempty',list_down_run1));
    list_down_run5 = list_down_run5(~cellfun('isempty',list_down_run5));
    list_down_run6 = list_down_run6(~cellfun('isempty',list_down_run6));
    list_down_run9 = list_down_run9(~cellfun('isempty',list_down_run9));
end

function matlabbatch = setup_matlabbatch(list1_up_run1, list1_up_run5, list1_up_run6, list1_up_run9, list1_down_run1, list1_down_run5, list1_down_run6, list1_down_run9,...
                                    list2_up_run1, list2_up_run5, list2_up_run6, list2_up_run9, list2_down_run1, list2_down_run5, list2_down_run6, list2_down_run9, ...
                                    list3_up_run1, list3_up_run5, list3_up_run6, list3_up_run9, list3_down_run1, list3_down_run5, list3_down_run6, list3_down_run9)

    matlabbatch{1}.spm.stats.factorial_design.dir = {'/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/full_factorial_BL_TR_ohne_7_motion_subs'};
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

    matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
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
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = '(UP-DOWN)Feedbackgroups-(UP-DOWN)Control_BLTR';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [ones(1,4) -1*ones(1,4) ones(1,4) -1*ones(1,4) -2*ones(1,4) 2*ones(1,4)];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
   
    matlabbatch{3}.spm.stats.con.delete = 0;

end