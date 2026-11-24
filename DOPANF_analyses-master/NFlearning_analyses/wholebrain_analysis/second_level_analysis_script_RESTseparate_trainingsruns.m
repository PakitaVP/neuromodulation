main()

function main()
    if (1 == ispc)
        %addpath(genpath("C:\Users\lhellr\Documents\MATLAB\Toolboxes\spm12"));
        save_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\group_stats_NFTraining\full_factorial_allruns_training_allsubs_wmcsf_confounder_restseparate";
        if (~exist(save_path, 'dir'))
            mkdir(save_path);
        end
        stats_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder";
        
        feedbackgroup_path = "C:\Development\DOPANF_analyses\NFTraining_only_firstlevel_subjects.csv";
        postNFQ_data = readtable(feedbackgroup_path);
        postNFQ_data = renamevars(postNFQ_data,["feedback_group","subjectID_BIDS"],["Feedbackgruppe","BIDS_subID"]);
        
    elseif (1 == ismac) 
        postNFQ_data = readtable(feedbackgroup_path);   
        addpath(genpath("/Users/malimaurer/Documents/MATLAB/zusaetzlich/spm12"));
        save_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/full_factorial_allruns_training_allsubs_wmcsf_confounder_restseparate";
        stats_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder";
        spm_path = "/Users/malimaurer/Documents/MATLAB/zusaetzlich/spm12";
        feedbackgroup_path = "/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/PostNFQ_merged.csv";
        postNFQ_data = readtable(feedbackgroup_path); 
    end
    
      

    [list1_up_run2, list1_up_run3, list1_up_run4, list1_up_run7, list1_up_run8, list1_down_run2, list1_down_run3, list1_down_run4, list1_down_run7, list1_down_run8, list1_rest_run2, list1_rest_run3, list1_rest_run4, list1_rest_run7, list1_rest_run8] = create_lists(1,postNFQ_data, stats_path);
    [list2_up_run2, list2_up_run3, list2_up_run4, list2_up_run7, list2_up_run8, list2_down_run2, list2_down_run3, list2_down_run4, list2_down_run7, list2_down_run8, list2_rest_run2, list2_rest_run3, list2_rest_run4, list2_rest_run7, list2_rest_run8] = create_lists(2,postNFQ_data, stats_path);
    [list3_up_run2, list3_up_run3, list3_up_run4, list3_up_run7, list3_up_run8, list3_down_run2, list3_down_run3, list3_down_run4, list3_down_run7, list3_down_run8, list3_rest_run2, list3_rest_run3, list3_rest_run4, list3_rest_run7, list3_rest_run8] = create_lists(3,postNFQ_data, stats_path);

    matlabbatch = setup_matlabbatch(save_path, ...
                                    list1_up_run2, list1_up_run3, list1_up_run4, list1_up_run7, list1_up_run8, list1_down_run2, list1_down_run3, list1_down_run4, list1_down_run7, list1_down_run8, list1_rest_run2, list1_rest_run3, list1_rest_run4, list1_rest_run7, list1_rest_run8, ...
                                    list2_up_run2, list2_up_run3, list2_up_run4, list2_up_run7, list2_up_run8, list2_down_run2, list2_down_run3, list2_down_run4, list2_down_run7, list2_down_run8, list2_rest_run2, list2_rest_run3, list2_rest_run4, list2_rest_run7, list2_rest_run8, ...
                                    list3_up_run2, list3_up_run3, list3_up_run4, list3_up_run7, list3_up_run8, list3_down_run2, list3_down_run3, list3_down_run4, list3_down_run7, list3_down_run8, list3_rest_run2, list3_rest_run3, list3_rest_run4, list3_rest_run7, list3_rest_run8);

    save(fullfile(save_path, 'matlabbatch'),'matlabbatch');
    spm('defaults','fmri');
    spm_jobman('run',matlabbatch);

end



function [list_up_run2, list_up_run3, list_up_run4, list_up_run7, list_up_run8,...
          list_down_run2, list_down_run3, list_down_run4, list_down_run7, list_down_run8,...
          list_rest_run2, list_rest_run3, list_rest_run4, list_rest_run7, list_rest_run8] = create_lists(feedbackgroup_number,postNFQ_data,stats_path)
    group = postNFQ_data(postNFQ_data.Feedbackgruppe == feedbackgroup_number, :).BIDS_subID;
    list_up_run2 = {}; 
    list_up_run3 = {};
    list_up_run4 = {};
    list_up_run7 = {};
    list_up_run8 = {};
    list_rest_run2 = {}; 
    list_rest_run3 = {};
    list_rest_run4 = {};
    list_rest_run7 = {};
    list_rest_run8 = {};
    list_down_run2 = {};
    list_down_run3 = {};
    list_down_run4 = {};
    list_down_run7 = {};
    list_down_run8 = {};
   
    for subject_index = 1:numel(group)
        current_subject = group(subject_index);
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
        list_rest_run2(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0021.nii,1" ))    };
        list_rest_run3(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0022.nii,1" ))    };
        list_rest_run4(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0023.nii,1" ))    };
        list_rest_run7(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0026.nii,1" ))    };
        list_rest_run8(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0027.nii,1" ))    };
    end
  
end
function matlabbatch = setup_matlabbatch(save_path,...
    list1_up_run2, list1_up_run3, list1_up_run4, list1_up_run7, list1_up_run8, ...
    list1_down_run2, list1_down_run3, list1_down_run4, list1_down_run7, list1_down_run8,...
    list1_rest_run2, list1_rest_run3, list1_rest_run4, list1_rest_run7, list1_rest_run8,...
    list2_up_run2, list2_up_run3, list2_up_run4, list2_up_run7, list2_up_run8, ...
    list2_down_run2, list2_down_run3, list2_down_run4, list2_down_run7, list2_down_run8, ...
    list2_rest_run2, list2_rest_run3, list2_rest_run4, list2_rest_run7, list2_rest_run8, ...
    list3_up_run2, list3_up_run3, list3_up_run4, list3_up_run7, list3_up_run8, ...
    list3_down_run2, list3_down_run3, list3_down_run4, list3_down_run7, list3_down_run8, ...
    list3_rest_run2, list3_rest_run3, list3_rest_run4, list3_rest_run7, list3_rest_run8)

    matlabbatch{1}.spm.stats.factorial_design.dir = {char(save_path)};
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Feedbackgruppe';
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Condition';
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 3;
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

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(11).levels = [1 3 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(11).scans = list1_rest_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(12).levels = [1 3 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(12).scans = list1_rest_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(13).levels = [1 3 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(13).scans = list1_rest_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(14).levels = [1 3 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(14).scans = list1_rest_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(15).levels = [1 3 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(15).scans = list1_rest_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(16).levels = [2 1 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(16).scans = list2_up_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(17).levels = [2 1 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(17).scans = list2_up_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(18).levels = [2 1 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(18).scans = list2_up_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(19).levels = [2 1 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(19).scans = list2_up_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(20).levels = [2 1 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(20).scans = list2_up_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(21).levels = [2 2 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(21).scans = list2_down_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(22).levels = [2 2 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(22).scans = list2_down_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(23).levels = [2 2 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(23).scans = list2_down_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(24).levels = [2 2 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(24).scans = list2_down_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(25).levels = [2 2 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(25).scans = list2_down_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(26).levels = [2 3 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(26).scans = list2_rest_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(27).levels = [2 3 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(27).scans = list2_rest_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(28).levels = [2 3 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(28).scans = list2_rest_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(29).levels = [2 3 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(29).scans = list2_rest_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(30).levels = [2 3 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(30).scans = list2_rest_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(31).levels = [3 1 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(31).scans = list3_up_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(32).levels = [3 1 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(32).scans = list3_up_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(33).levels = [3 1 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(33).scans = list3_up_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(34).levels = [3 1 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(34).scans = list3_up_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(35).levels = [3 1 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(35).scans = list3_up_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(36).levels = [3 2 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(36).scans = list3_down_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(37).levels = [3 2 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(37).scans = list3_down_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(38).levels = [3 2 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(38).scans = list3_down_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(39).levels = [3 2 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(39).scans = list3_down_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(40).levels = [3 2 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(40).scans = list3_down_run8;

    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(41).levels = [3 3 1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(41).scans = list3_rest_run2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(42).levels = [3 3 2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(42).scans = list3_rest_run3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(43).levels = [3 3 3];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(43).scans = list3_rest_run4;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(44).levels = [3 3 4];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(44).scans = list3_rest_run7;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(45).levels = [3 3 5];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(45).scans = list3_rest_run8;

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
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(45);
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none'; 
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = '(UP-DOWN)Feedbackgroups-(UP-DOWN)Control';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [ones(1,5) -1*ones(1,5) zeros(1,5) ones(1,5) -1*ones(1,5) zeros(1,5) -2*ones(1,5) 2*ones(1,5) zeros(1,5)];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = '(UP-DOWN)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [ones(1,5) -1*ones(1,5) zeros(1,5) ones(1,5) -1*ones(1,5) zeros(1,5) ones(1,5) -1*ones(1,5) zeros(1,5)];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = '(UP-DOWN)R-(UP-DOWN)C';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [ones(1,5) -1*ones(1,5) zeros(1,5) zeros(1,15) -1*ones(1,5) 1*ones(1,5) zeros(1,5)];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = '(REST-DOWN)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [zeros(1,5) -1*ones(1,5 ) ones(1,5) zeros(1,5) -1*ones(1,5) ones(1,5) zeros(1,5) -1*ones(1,5) ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = '(UP-DOWN)P-(UP-DOWN)C';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [zeros(1,15) ones(1,5) -1*ones(1,5) zeros(1,5) -1*ones(1,5) 1*ones(1,5) zeros(1,5)];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = '(UP-DOWN)R-(UP-DOWN)P';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [ones(1,5) -1*ones(1,5) zeros(1,5) -1*ones(1,5) 1*ones(1,5) zeros(1,5) zeros(1,15)];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = '(DOWN-REST)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [zeros(1,5) ones(1,5 ) -1*ones(1,5) zeros(1,5) ones(1,5) -1*ones(1,5) zeros(1,5) ones(1,5) -1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    
    % 
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = '(UP-REST)Feedbackgroups-(UP-REST)Control';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [ones(1,5)  zeros(1,5) -1*ones(1,5) ones(1,5)  zeros(1,5) -1*ones(1,5) -2*ones(1,5)  zeros(1,5) 2*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = '(UP-REST)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [ones(1,5)  zeros(1,5) -1*ones(1,5) ones(1,5)  zeros(1,5) -1*ones(1,5) ones(1,5)  zeros(1,5) -1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = '(UP-REST)R-(UP-REST)C';
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [ones(1,5) zeros(1,5) -1*ones(1,5) zeros(1,15) -1*ones(1,5)  zeros(1,5) 1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = '(UP-REST)P-(UP-REST)C';
    matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [zeros(1,15) ones(1,5) zeros(1,5) -1*ones(1,5) -1*ones(1,5) zeros(1,5) 1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = '(UP-REST)R-(UP-REST)P';
    matlabbatch{3}.spm.stats.con.consess{13}.tcon.weights = [ones(1,5) zeros(1,5) -1*ones(1,5) -1*ones(1,5) zeros(1,5) 1*ones(1,5) zeros(1,15)];
    matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = '(DOWN-REST)Feedbackgroups-(DOWN-REST)Control';
    matlabbatch{3}.spm.stats.con.consess{14}.tcon.weights = [zeros(1,5) ones(1,5) -1*ones(1,5)  zeros(1,5) ones(1,5) -1*ones(1,5) zeros(1,5) -2*ones(1,5) 2*ones(1,5) ];
    matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = '(DOWN-REST)_allgroups';
    matlabbatch{3}.spm.stats.con.consess{15}.tcon.weights = [zeros(1,5) ones(1,5) -1*ones(1,5) zeros(1,5) ones(1,5) -1*ones(1,5) zeros(1,5) ones(1,5) -1*ones(1,5) ];
    matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = '(DOWN-REST)R-(DOWN-REST)C';
    matlabbatch{3}.spm.stats.con.consess{16}.tcon.weights = [zeros(1,5) ones(1,5) -1*ones(1,5) zeros(1,20) -1*ones(1,5) ones(1,5) ];
    matlabbatch{3}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{17}.tcon.name = '(DOWN-REST)P-(DOWN-REST)C';
    matlabbatch{3}.spm.stats.con.consess{17}.tcon.weights = [zeros(1,20) ones(1,5) -1*ones(1,5) zeros(1,5) -1*ones(1,5) 1*ones(1,5)];
    matlabbatch{3}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{18}.tcon.name = '(DOWN-REST)R-(DOWN-REST)P';
    matlabbatch{3}.spm.stats.con.consess{18}.tcon.weights = [zeros(1,5) ones(1,5) -1*ones(1,5) zeros(1,5) -1*ones(1,5) ones(1,5) zeros(1,15)];
    matlabbatch{3}.spm.stats.con.consess{18}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.delete = 0;

end