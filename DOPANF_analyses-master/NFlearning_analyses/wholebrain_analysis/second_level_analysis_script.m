main()

function main()

    save_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/test_anova_2";
    stats_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining";
    spm_path = "/Users/malimaurer/Documents/MATLAB/zusaetzlich/spm12";
    feedbackgroup_path = "/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/PostNFQ_merged.csv";
    
    postNFQ_data = readtable(feedbackgroup_path);   

    [list1_up, list1_down] = create_lists(1,postNFQ_data, stats_path);
    [list2_up, list2_down] = create_lists(2,postNFQ_data, stats_path);
    [list3_up, list3_down] = create_lists(3,postNFQ_data, stats_path);

    matlabbatch = setup_matlabbatch(list1_up, list1_down, list2_up, list2_down, list3_up, list3_down);

    save(save_path,'matlabbatch')
    spm('defaults','fmri');
    spm_jobman('run',matlabbatch);

end



function [list_up, list_down] = create_lists(feedbackgroup_number,postNFQ_data,stats_path)
    group = postNFQ_data(postNFQ_data.Feedbackgruppe == feedbackgroup_number, :).BIDS_subID;
    list_up = {}; 
    list_down = {};
    
    for subject_index = 1:numel(group)
        current_subject = group(subject_index);
        list_up(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0010.nii,1" ))   };
        list_down(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], "con_0002.nii,1" ))    };
    end
end

function matlabbatch = setup_matlabbatch(list1_up, list1_down, list2_up, list2_down, list3_up, list3_down)

    matlabbatch{1}.spm.stats.factorial_design.dir = {'/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/test_anova2'};
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Feedbackgruppe';
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 3;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Condition';
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1
                                                                        1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = list1_up;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1
                                                                        2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = list1_down;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2
                                                                        1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = list2_up;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2
                                                                        2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = list2_down;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [3
                                                                        1];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = list3_up;
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [3
                                                                        2];
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = list3_down;
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
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Feebackgroups - Control';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1 1 1 -2 2];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.fcon.name = 'Feedbackgroups vs. Control';
    matlabbatch{3}.spm.stats.con.consess{2}.fcon.weights = [1 0 0 0 0 0
                                                            0 1 0 0 0 0
                                                            0 0 1 0 0 0
                                                            0 0 0 1 0 0
                                                            0 0 0 0 1 0
                                                            0 0 0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{2}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

end