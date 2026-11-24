main()

function main()

    save_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/full_factorial_allruns_training_ohne2subs";
    stats_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining";
    spm_path = "/Users/malimaurer/Documents/MATLAB/zusaetzlich/spm12";
    feedbackgroup_path = "/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/PostNFQ_merged.csv";
    
    postNFQ_data = readtable(feedbackgroup_path);   

    [list1_up_run2, list1_up_run3, list1_up_run4, list1_up_run7, list1_up_run8, list1_down_run2, list1_down_run3, list1_down_run4, list1_down_run7, list1_down_run8] = create_lists(1,postNFQ_data, stats_path);
    [list2_up_run2, list2_up_run3, list2_up_run4, list2_up_run7, list2_up_run8, list2_down_run2, list2_down_run3, list2_down_run4, list2_down_run7, list2_down_run8] = create_lists(2,postNFQ_data, stats_path);
    [list3_up_run2, list3_up_run3, list3_up_run4, list3_up_run7, list3_up_run8, list3_down_run2, list3_down_run3, list3_down_run4, list3_down_run7, list3_down_run8] = create_lists(3,postNFQ_data, stats_path);

    matlabbatch = setup_matlabbatch(list1_up_run2, list1_up_run3, list1_up_run4, list1_up_run7, list1_up_run8, list1_down_run2, list1_down_run3, list1_down_run4, list1_down_run7, list1_down_run8,...
                                    list2_up_run2, list2_up_run3, list2_up_run4, list2_up_run7, list2_up_run8, list2_down_run2, list2_down_run3, list2_down_run4, list2_down_run7, list2_down_run8, ...
                                    list3_up_run2, list3_up_run3, list3_up_run4, list3_up_run7, list3_up_run8, list3_down_run2, list3_down_run3, list3_down_run4, list3_down_run7, list3_down_run8);

    save(save_path,'matlabbatch')
    spm('defaults','fmri');
    spm_jobman('run',matlabbatch);

end



function [list_up_run2, list_up_run3, list_up_run4, list_up_run7, list_up_run8, list_down_run2, list_down_run3, list_down_run4, list_down_run7, list_down_run8] = create_lists(feedbackgroup_number,postNFQ_data,stats_path)
    group = postNFQ_data(postNFQ_data.Feedbackgruppe == feedbackgroup_number, :).BIDS_subID;
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

        if current_subject == 30823 || current_subject == 45622 
           disp("would not run for: " + current_subject);
           continue;
        end

        list_up_run2(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0003.nii,1" ))   };
        list_up_run3(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0004.nii,1" ))   };
        list_up_run4(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0005.nii,1" ))   };
        list_up_run7(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0008.nii,1" ))   };
        list_up_run8(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0009.nii,1" ))   };
        list_down_run2(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0012.nii,1" ))    };
        list_down_run3(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0013.nii,1" ))    };
        list_down_run4(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0014.nii,1" ))    };
        list_down_run7(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0017.nii,1" ))    };
        list_down_run8(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0018.nii,1" ))    };
    end
    list_up_run2 = list_up_run2(~cellfun('isempty',list_up_run2));
    list_up_run3 = list_up_run3(~cellfun('isempty',list_up_run3));
    list_up_run4 = list_up_run4(~cellfun('isempty',list_up_run4));
    list_up_run7 = list_up_run7(~cellfun('isempty',list_up_run7));
    list_up_run8 = list_up_run8(~cellfun('isempty',list_up_run8));
    list_down_run2 = list_down_run2(~cellfun('isempty',list_down_run2));
    list_down_run3 = list_down_run3(~cellfun('isempty',list_down_run3));
    list_down_run4 = list_down_run4(~cellfun('isempty',list_down_run4));
    list_down_run7 = list_down_run7(~cellfun('isempty',list_down_run7));
    list_down_run8 = list_down_run8(~cellfun('isempty',list_down_run8));
end

function matlabbatch = setup_matlabbatch(list1_up_run2, list1_up_run3, list1_up_run4, list1_up_run7, list1_up_run8, list1_down_run2, list1_down_run3, list1_down_run4, list1_down_run7, list1_down_run8,...
                                         list2_up_run2, list2_up_run3, list2_up_run4, list2_up_run7, list2_up_run8, list2_down_run2, list2_down_run3, list2_down_run4, list2_down_run7, list2_down_run8, ...
                                         list3_up_run2, list3_up_run3, list3_up_run4, list3_up_run7, list3_up_run8, list3_down_run2, list3_down_run3, list3_down_run4, list3_down_run7, list3_down_run8)

    matlabbatch{1}.spm.stats.factorial_design.dir = {'/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/full_factorial_allruns_training_ohne2subs'};
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
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(30);
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none'; 
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = '(UP-DOWN)Feedbackgroups-(UP-DOWN)Control_without_2subs';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [ones(1,5) -1*ones(1,5) ones(1,5) -1*ones(1,5) -2*ones(1,5) 2*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
   
    matlabbatch{3}.spm.stats.con.delete = 0;

end