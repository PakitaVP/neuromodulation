function matlabbatch = batch_normalize(metainfo, matlabbatch)   
    ind = length(matlabbatch)+1;
    disp("spatial coreg (in normalize function) - matlabbatch index:");
    disp(ind);
    disp(fullfile(metainfo.anaDir, ['y_' metainfo.t1File]));
    disp(exist(fullfile(metainfo.anaDir, ['y_' metainfo.t1File]),'file'));
    % disp(exist(fullfile(metainfo.funcDir, ['mean' metainfo.realign_prefix metainfo.realign_prefix metainfo.boldFile]), 'file'));
    matlabbatch{ind}.spm.spatial.coreg.estimate.ref(1) = {fullfile(metainfo.anaDir, 'Brain.nii')}; % cfg_dep('Image Calculator: ImCalc Computed Image: Brain', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{ind}.spm.spatial.coreg.estimate.source(1) = {fullfile(metainfo.funcDir, ['mean' metainfo.realign_prefix metainfo.slicetime_prefix metainfo.boldFile])}; % cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
    matlabbatch{ind}.spm.spatial.coreg.estimate.other(1) = {fullfile(metainfo.funcDir, [metainfo.realign_prefix metainfo.slicetime_prefix metainfo.boldFile])};
    matlabbatch{ind}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{ind}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{ind}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{ind}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    matlabbatch{ind+1}.spm.spatial.normalise.write.subj.def(1) = {fullfile(metainfo.anaDir, ['y_' metainfo.t1File])};
    % L vorgeschlagen als deformation field: {fullfile(metainfo.anaDir, [erase(metainfo.t1File, '.nii') '_seg8.mat'])};
    % aber spm manual: In SPM, deformation fields are saved in NIfTI format
    disp("normalize - matlabbatch index:");
    disp(ind+1);
    matlabbatch{ind+1}.spm.spatial.normalise.write.subj.resample(1) = {fullfile(metainfo.funcDir, [metainfo.realign_prefix metainfo.slicetime_prefix metainfo.boldFile])};
    matlabbatch{ind+1}.spm.spatial.normalise.write.woptions.bb = [-78, -112, -70; 78, 76, 85]; % [-78 -112 -70 78 76 85];
    matlabbatch{ind+1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{ind+1}.spm.spatial.normalise.write.woptions.interp = 7;
    matlabbatch{ind+1}.spm.spatial.normalise.write.woptions.prefix = metainfo.normalize_prefix; % w
end