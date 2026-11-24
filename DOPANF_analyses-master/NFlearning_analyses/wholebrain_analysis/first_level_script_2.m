

main()

function main()

bool_blocksplit = 0;
bool_restseparate = 0;
bool_restimplicit = 1;
if (1 == ispc)
    preproc_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\fmrwhy-preproc";
    if (1 == bool_blocksplit)
        stats_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder_blocksplit\";
    elseif (1 == bool_restseparate)
        stats_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder_restseparate\";
    elseif (1 == bool_restimplicit)
        stats_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder_restimplicit\";
    else
        stats_path = "Z:\Projects\DOPANF\Data\DOPANF_QA\derivatives\DOPANF_stats\task-NFTraining_wmcsf_confounder\";
    end
    spm_path = 'C:\Users\lhellr\Documents\MATLAB\Toolboxes\spm12';
elseif (1 == ismac) 
    preproc_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc/";
    if (0 == bool_blocksplit)
        stats_path = "/Volumes/JustData/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/task-NFTraining_wmcsf_confounder/";
    else
        stats_path = "";
    end
    spm_path = '/Users/malimaurer/Documents/MATLAB/zusaetzlich/spm12';
end
    sub_dirs = get_sub_dirs(preproc_path);
    
    
    for subject_index = 1:numel(sub_dirs)
        subject = sub_dirs{subject_index};
       
        try
            run_subject_analysis(preproc_path, spm_path, stats_path, subject, bool_blocksplit, bool_restseparate, bool_restimplicit);
        catch error
            disp("error with subject index = " + subject)
            disp("error was: " + error.message)
        end
    end
end


 function [dirs] = get_sub_dirs(preproc_path)
    all_items = dir(preproc_path);
    sub_dirs = all_items([all_items.isdir]);
    sub_dirs = sub_dirs(~ismember({sub_dirs.name}, {'.', '..'}));
    dirs = {sub_dirs.name};
end



function run_subject_analysis(preproc_path, spm_path, stats_path, subject, bool_blocksplit, bool_restseparate, bool_restimplicit)
save_path = stats_path + filesep + subject + filesep + "first_level_NFTraining.mat";
subject_stats_path = stats_path + filesep + subject;
subject_preproc_path = preproc_path + filesep + subject;

if (~exist(subject_stats_path, 'dir'))
    mkdir(subject_stats_path);
end

% set starting settings
matlabbatch{1}.spm.stats.fmri_spec.dir = {char(subject_stats_path)};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'Scaling';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
matlabbatch{1}.spm.stats.fmri_spec.mask = {fullfile(spm_path, 'tpm', 'mask_ICV.nii,1')};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

nr_of_sessions = 2;
nr_of_runs = [5 4];

for session_nr = 1:nr_of_sessions
    session_number = mat2str(session_nr);

    for run_nr = 1:nr_of_runs(session_nr)
        run_number = mat2str(run_nr);

        if session_nr == 1
            run_identifier = run_nr;
        else
            run_identifier = run_nr + nr_of_runs(1);
        end

        matlabbatch = define_run(matlabbatch, subject_preproc_path, subject, session_number, run_number, run_identifier, bool_blocksplit, bool_restimplicit);
        save(save_path,'matlabbatch');
    end
end

% estimation batch
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;



% define the contrasts
if (1 == bool_blocksplit)
    current_nr_of_regressors = 6;
elseif (1 == bool_restimplicit)
    current_nr_of_regressors = 3;
else
    current_nr_of_regressors = 4;
end
current_nr_of_physio_regressors = 18;
matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'eoi';

%TODO: check auf 9 runs
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [eye(current_nr_of_regressors)...
    zeros(current_nr_of_regressors,run_identifier*current_nr_of_physio_regressors+(run_identifier-1)*current_nr_of_regressors);...

    zeros(current_nr_of_regressors,current_nr_of_physio_regressors+current_nr_of_regressors)...
    eye(current_nr_of_regressors)...
    zeros(current_nr_of_regressors,(run_identifier-1)*current_nr_of_physio_regressors+7*current_nr_of_regressors);...

    zeros(current_nr_of_regressors,2*current_nr_of_physio_regressors+2*current_nr_of_regressors)...
    eye(current_nr_of_regressors)...
    zeros(current_nr_of_regressors,(run_identifier-2)*current_nr_of_physio_regressors+6*current_nr_of_regressors)...

    zeros(current_nr_of_regressors,3*current_nr_of_physio_regressors+3*current_nr_of_regressors)...
    eye(current_nr_of_regressors)...
    zeros(current_nr_of_regressors,(run_identifier-3)*current_nr_of_physio_regressors+5*current_nr_of_regressors)...

    zeros(current_nr_of_regressors,4*current_nr_of_physio_regressors+4*current_nr_of_regressors)...
    eye(current_nr_of_regressors)...
    zeros(current_nr_of_regressors,(run_identifier-4)*current_nr_of_physio_regressors+4*current_nr_of_regressors)...

    zeros(current_nr_of_regressors,5*current_nr_of_physio_regressors+5*current_nr_of_regressors)...
    eye(current_nr_of_regressors)...
    zeros(current_nr_of_regressors,(run_identifier-5)*current_nr_of_physio_regressors+3*current_nr_of_regressors)...

    zeros(current_nr_of_regressors,6*current_nr_of_physio_regressors+6*current_nr_of_regressors)...
    eye(current_nr_of_regressors)...
    zeros(current_nr_of_regressors,(run_identifier-6)*current_nr_of_physio_regressors+2*current_nr_of_regressors)...

    zeros(current_nr_of_regressors,7*current_nr_of_physio_regressors+7*current_nr_of_regressors)...
    eye(current_nr_of_regressors)...
    zeros(current_nr_of_regressors,(run_identifier-7)*current_nr_of_physio_regressors+current_nr_of_regressors)...

    zeros(current_nr_of_regressors,8*current_nr_of_physio_regressors+8*current_nr_of_regressors)...
    eye(current_nr_of_regressors)...
    zeros(current_nr_of_regressors,(run_identifier-8)*current_nr_of_physio_regressors)...

    zeros(current_nr_of_regressors,run_identifier*current_nr_of_physio_regressors+(run_identifier-1)*current_nr_of_regressors+current_nr_of_regressors)];


matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';

contrast_basic_names = {};
contrast_weights = {};
if (1 == bool_restseparate && 0 == bool_blocksplit && 0 == bool_restimplicit)
    contrast_basic_names = {'UP', 'DOWN', 'REST', 'UP-DOWN','UP-REST', 'DOWN-REST', 'REST-DOWN'};
    contrast_weights = {[0 1 0 0], [0 0 0 1], [1 0 0 0], [0 1 0 -1],[-1 1 0 0], [-1 0 0 1], [1 0 0 -1]};
elseif (0 == bool_restseparate && 1 == bool_blocksplit && 0 == bool_restimplicit)
    contrast_basic_names = {'UP-REST', 'DOWN-REST', 'REST-DOWN', 'UP-DOWN'};
    contrast_weights = {[-1 1 0 0 0 0], [-1 0 0 0 1 0], [1 0 0 0 -1 0], [0 1 0 0 -1 0]};
elseif (1 == bool_restimplicit && 0 == bool_restseparate && 0 == bool_blocksplit )
    contrast_basic_names = {'UP', 'DOWN', 'UP-DOWN'};
    contrast_weights = {[1 0 0], [0 0 1], [1 0 -1]};
else
    contrast_basic_names = {'UP-REST', 'DOWN-REST', 'REST-DOWN', 'UP-DOWN'};
    contrast_weights = {[-1 1 0 0], [-1 0 0 1], [1 0 0 -1], [0 1 0 -1]};
end

contrast_index = 1;
%TODO: check ob noetig
current_session=[1];
for indContrast = 1:numel(contrast_basic_names)
    for indRuns = 1:run_identifier
        contrast_index = (indContrast -1 )* run_identifier + indRuns + 1;
        contrast_name = sprintf('%s%d', cell2mat(contrast_basic_names(indContrast)), indRuns);
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = contrast_name;
        weight = [zeros(1, (indRuns-1)*current_nr_of_physio_regressors) zeros(1, (indRuns-1)*current_nr_of_regressors) cell2mat(contrast_weights(indContrast)) zeros(1, (numel(current_session)-indRuns+1)*current_nr_of_physio_regressors + (numel(current_session)-indRuns)*current_nr_of_regressors)];
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
        matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';
    end
end

% add contrasts over all runs at the end
contrast_index = contrast_index + 1;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP-REST_allruns';
if (1 == bool_blocksplit)
    con_vec = [-1 1 0 0 0 0];
elseif (1 == bool_restimplicit)
    con_vec = [1 0 0];
else
    con_vec = [-1 1 0 0];
end


weight = repmat([con_vec zeros(1,current_nr_of_physio_regressors)], 1, run_identifier);

matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

contrast_index = contrast_index + 1;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'DOWN-REST_allruns';
if (1 == bool_blocksplit)
    con_vec = [-1 0 0 0 1 0];
elseif (1 == bool_restimplicit)
    con_vec = [0 0 1];
else 
    con_vec = [-1 0 0 1];
end

weight = repmat([con_vec zeros(1,current_nr_of_physio_regressors)], 1, run_identifier);


matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

contrast_index = contrast_index + 1;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'REST-DOWN_allruns';
if (1 == bool_blocksplit)
    con_vec = [1 0 0 0 -1 0];
elseif (1 == bool_restimplicit)
    con_vec = [0 0 -1];
else
    con_vec = [1 0 0 -1];
end

weight = repmat([con_vec zeros(1,current_nr_of_physio_regressors)], 1, run_identifier);

matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

contrast_index = contrast_index + 1;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = 'UP-DOWN_allruns';
if (1 == bool_blocksplit)
    con_vec = [0 1 0 0 -1 0];
elseif (1 == bool_restimplicit)
    con_vec = [1 0 -1];
else
    con_vec = [0 1 0 -1];
end

weight = repmat([con_vec zeros(1,current_nr_of_physio_regressors)], 1, run_identifier);

matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = weight;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

contrast_index = contrast_index + 1;
if (1 == bool_blocksplit)
    con_vec = [0 1 0 0 -1 0];
elseif (1 == bool_restimplicit)
    con_vec = [1 0 -1];
else 
    con_vec = [0 1 0 -1];
end
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)_BLTR_TRses2-BLses1';
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [-1*con_vec zeros(1,7*current_nr_of_regressors+8*current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

contrast_index = contrast_index + 1;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)_BLTR_TRses1-BLses1';
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [-1*con_vec zeros(1,3*current_nr_of_regressors+4*current_nr_of_physio_regressors) con_vec zeros(1,4*current_nr_of_regressors+5*current_nr_of_physio_regressors)];
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

contrast_index = contrast_index + 1;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)_BLTR_TRses2-BLses2';
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,5*current_nr_of_regressors+5*current_nr_of_physio_regressors) -1*con_vec zeros(1,2*current_nr_of_regressors+3*current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors)];
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

contrast_index = contrast_index + 1;
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.name = '(UP-DOWN)_all_trainingsruns';
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.weights = [zeros(1,current_nr_of_regressors) zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors) con_vec zeros(1,current_nr_of_physio_regressors) 0*con_vec zeros(1,current_nr_of_physio_regressors) 0*con_vec zeros(1,current_nr_of_physio_regressors) -1*con_vec zeros(1,current_nr_of_physio_regressors)  -1*con_vec zeros(1,current_nr_of_physio_regressors) 0*con_vec zeros(1,current_nr_of_physio_regressors)];
matlabbatch{3}.spm.stats.con.consess{contrast_index}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

save(save_path,'matlabbatch')
spm('defaults','fmri');
spm_jobman('run',matlabbatch);

end


% based on script_proband_1
function matlabbatch = define_run(matlabbatch, subject_path, subject, session_number, run_number, run_identifier, bool_blocksplit, bool_restimplicit)

    matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).scans = load_scan_data(subject_path, subject, session_number, run_number);    
  
    % load onset/duration files 
    onsets = load_table_data(subject_path, subject, session_number, run_number, false);
    durations = load_table_data(subject_path, subject, session_number, run_number, true);
    
    con_counter = 0; 
    if (0 == bool_restimplicit)
        con_counter = con_counter + 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).onset = onsets.REST(~isnan(onsets.REST));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).duration = durations.REST(~isnan(durations.REST));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).name = 'REST';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).orth = 1;
    elseif (0 == bool_blocksplit)
        con_counter = con_counter + 1; 
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).name = 'UP';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).onset = onsets.NFUp(~isnan(onsets.NFUp));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).duration = durations.NFUp(~isnan(durations.NFUp));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).orth = 1;
        con_counter = con_counter + 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).name = 'FIX';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).onset = onsets.Fix(~isnan(onsets.Fix));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).duration = durations.Fix(~isnan(durations.Fix));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).orth = 1;
        con_counter = con_counter + 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).name = 'DOWN';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).onset = onsets.NFDown(~isnan(onsets.NFDown));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).duration = durations.NFDown(~isnan(durations.NFDown));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).orth = 1;
    else
        con_counter = con_counter + 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).name = 'UP_1';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).onset = onsets.NFUp(~isnan(onsets.NFUp));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).duration = durations.NFUp_1stHalf(~isnan(durations.NFUp_1stHalf));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).orth = 1;
        con_counter = con_counter + 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).name = 'UP_2';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).onset = onsets.NFUp_2ndHalf(~isnan(onsets.NFUp_2ndHalf));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).duration = durations.NFUp_2ndHalf(~isnan(durations.NFUp_2ndHalf));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).orth = 0;
        con_counter = con_counter + 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).name = 'FIX';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).onset = onsets.Fix(~isnan(onsets.Fix));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).duration = durations.Fix(~isnan(durations.Fix));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).orth = 1;
        con_counter = con_counter + 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).name = 'DOWN_1';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).onset = onsets.NFDown(~isnan(onsets.NFDown));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).duration = durations.NFDown_1stHalf(~isnan(durations.NFDown_1stHalf));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).orth = 1;
        con_counter = con_counter + 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).name = 'DOWN_2';
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).onset = onsets.NFDown_2ndHalf(~isnan(onsets.NFDown_2ndHalf));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).duration = durations.NFDown_2ndHalf(~isnan(durations.NFDown_2ndHalf));
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).cond(con_counter).orth = 0;
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).regress = struct('name', {}, 'val', {});

    matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).multi_reg = cellstr(get_confound_file(subject_path, subject, session_number, run_number));
    matlabbatch{1}.spm.stats.fmri_spec.sess(run_identifier).hpf = 128;

end

function table_data = load_table_data(subject_path, subject, session_number, run_number, is_duration)
    suffix = "onsets.csv";
    if is_duration
        suffix = "durations.csv";
    end

    file_path = subject_path + filesep + "ses-" + session_number + filesep + "beh" + filesep  + subject + "_ses-" + session_number + "_task-NFTraining_run-" + run_number + "_desc-" + suffix;
    table_data = readtable(file_path);
end



function file_name = get_confound_file(subject_path, subject, session_number, run_number)
    path = subject_path + filesep + "ses-" + session_number + filesep + "func" + filesep;
    physio_regressors_file = path + subject + "_ses-" + session_number + "_task-NFTraining_run-" + run_number + "_desc-confounds_physio.tsv";
    physio_regressors_raw = readtable(physio_regressors_file, 'FileType', 'delimitedtext', 'delimiter', '\t');

    tissue_regressors_file = path + subject + "_ses-" + session_number + "_task-NFTraining_run-" + run_number + "_desc-confounds_tissue.tsv";
    tissue_regressors_raw = readtable(tissue_regressors_file, 'FileType', 'delimitedtext', 'delimiter', '\t');

    file_path = subject_path + filesep + "ses-" + session_number + filesep + "func" + filesep;
    motion_regressors_file = file_path + subject + "_ses-" + session_number + "_task-NFTraining_run-" + run_number + "_desc-confounds_motion.tsv";
    motion_regressors = readtable(motion_regressors_file, 'FileType', 'delimitedtext', 'delimiter', '\t');
    physio_regressors = [];
    physio_regressors = [physio_regressors physio_regressors_raw(:, 1:2)];
    physio_regressors = [physio_regressors physio_regressors_raw(:, 9:10)];
    physio_regressors = [physio_regressors physio_regressors_raw(:, 15:20)];
    tissue_regressors = [];
    tissue_regressors = [tissue_regressors tissue_regressors_raw(:, 2:3)];

    confounds_regressor = [motion_regressors physio_regressors tissue_regressors]; 

    file_path = subject_path + filesep + "ses-" + session_number + filesep + "func" + filesep;
    file_name = file_path + subject + "_ses-" + session_number + "_task-NFTraining_run-" + run_number + "_motionphysiotissue.txt";
    writetable(confounds_regressor, file_name, 'FileType', 'text', 'Delimiter','\t', 'WriteVariableNames',0);
end

   


function scan_data = load_scan_data(subject_path, subject, session_number, run_number)
    file_path = subject_path + filesep + "ses-" + session_number + filesep + "func" + filesep;
    file_name = subject + "_ses-" + session_number + "_task-NFTraining_run-" + run_number + "_desc-swrapreproc_bold.nii";
    scan_data = cellstr(spm_select('ExtFPList',file_path,file_name,Inf));
end

