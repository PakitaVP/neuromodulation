
function main()

    addpath(genpath("/Users/malimaurer/Documents/MATLAB/zusaetzlich/spm12"));
    %addpath /Users/malimaurer/Documents/MATLAB/zusaetzlich/spm12/external/fieldtrip
    save_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats_NFTraining/two_sample_t-tests/two_sample_t-tests_"; 
    %stats_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder_restseparate";
    stats_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder_restimplicit"; % für restimplicit
    spm_path = "/Users/malimaurer/Documents/MATLAB/zusaetzlich/spm12";
    feedbackgroup_path = "/Users/malimaurer/Documents/GitHub/experimental_questionnaires/results.nosync/PostNFQ_merged.csv";
    
    postNFQ_data = readtable(feedbackgroup_path);

    %con_files = {{"con_0109.nii,1", "UP-DOWN_TR2-BL1"}, {"con_0110.nii,1", "UP-DOWN_TR1-BL1"}, {"con_0111.nii,1", "UP-DOWN_TR2-BL2"}, {"con_0095.nii,1", "UP-DOWN_alltrainingruns"}, {"con_0097.nii,1", "UP_TR2-BL1"}, {"con_0090.nii,1", "UP_alltrainingruns"}, {"con_0100.nii,1", "DOWN_TR2-BL1"}, {"con_0091.nii,1", "DOWN_alltrainingruns"}, {"con_0115.nii,1", "DOWN+_TR2-BL1"}, {"con_0092.nii,1", "DOWN+_alltrainingruns"}, {"con_0106.nii,1", "UP+DOWN_TR2-BL1"}, {"con_0094.nii,1", "UP+DOWN_alltrainingruns"}};
    %con_files = {{"con_0068.nii,1", "UP-DOWN_TR2-BL1"}, {"con_0069.nii,1", "UP-DOWN_TR1-BL1"}, {"con_0070.nii,1", "UP-DOWN_TR2-BL2"}, {"con_0057.nii,1", "UP-DOWN_alltrainingruns"}, {"con_0059.nii,1", "UP_TR2-BL1"}, {"con_0062.nii,1", "DOWN_TR2-BL1"}, {"con_0065.nii,1", "UP+DOWN_TR2-BL1"}, {"con_0053.nii,1", "UP_alltrainingruns"}, {"con_0054.nii,1", "DOWN_alltrainingruns"}, {"con_0056.nii,1", "UP+DOWN_alltrainingruns"}};
    con_files = {{"con_0074.nii,1", "DOWN+_TR2-BL1"}, {"con_0055.nii,1", "DOWN+_alltrainingruns"}};

    for con_file_index = 1:numel(con_files)
        con_pair = con_files{con_file_index};
        con_file_name = con_pair{1};
        con_file_description = con_pair{2};

        % set up group comparisons
        list_group1 = create_list(1, postNFQ_data, stats_path, con_file_name);
        list_group2 = create_list(2, postNFQ_data, stats_path, con_file_name);
        list_group3 = create_list(3, postNFQ_data, stats_path, con_file_name);
        group_comparisons = {{list_group1, list_group2, "R-P", "P-R"},{list_group1, list_group3, "R-C", "C-R"}, {list_group2, list_group3, "P-C", "C-P"}};
        
        % run group comparisons
        run_group_comparisons(group_comparisons, save_path, con_file_description);
        
    end
    
    
end

function run_group_comparisons(group_comparisons, save_path, con_file_description) 

    for pair_index = 1:numel(group_comparisons)
        pair = group_comparisons{pair_index};

        list_group_scans1 = pair{1};
        list_group_scans2 = pair{2};
        group_comparison_name = pair{3};
        group_comparison_name_inverted = pair{4};
        

        % create individual save paths
        final_save_path = save_path + con_file_description + "_" + group_comparison_name + "_restimplicit";

        matlabbatch = setup_matlabbatch(list_group_scans1, list_group_scans2, final_save_path, con_file_description, group_comparison_name, group_comparison_name_inverted); %für jedes Con-File 3 t-tests machen: 1:2, 1:3, 2:3 (davon 3 Kontraste mit unterschiedlichen Namen)
        
        if ~exist(final_save_path, 'dir')
            mkdir(final_save_path);
        end
        save(fullfile(final_save_path, 'matlabbatch.mat'),'matlabbatch')
        spm('defaults','fmri');
        spm_jobman('run',matlabbatch);
    end
end



function [list_group] = create_list(feedbackgroup_number, postNFQ_data, stats_path, con_file)
    group = postNFQ_data(postNFQ_data.Feedbackgruppe == feedbackgroup_number, :).BIDS_subID;
    list_group = {}; 
    
    for subject_index = 1:numel(group)
        current_subject = group(subject_index);

        list_group(subject_index,1) = {char(fullfile(stats_path, ['sub-' mat2str(current_subject)], con_file ))   }; %für mehrere Con Files: 42,43,44,45
       
    end
end      
    

 
    

function matlabbatch = setup_matlabbatch(list_group_scans1, list_group_scans2, save_path, run_comparison_name, group_comparison_name, group_comparison_name_inverted)

    matlabbatch{1}.spm.stats.factorial_design.dir = {char(save_path)};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = list_group_scans1;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = list_group_scans2;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
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
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [eye(2)]; 
    matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = char(run_comparison_name + "_" + group_comparison_name); 
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 -1]; 
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = char(run_comparison_name + "_" + group_comparison_name_inverted); 
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

end