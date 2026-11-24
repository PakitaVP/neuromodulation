function matlabbatch = batch_smooth(metainfo, matlabbatch)   
    ind = length(matlabbatch)+1;
    disp("smoothing - matlabbatch index:");
    disp(ind);
    matlabbatch{ind}.spm.spatial.smooth.data(1) = {fullfile(metainfo.funcDir, [metainfo.normalize_prefix metainfo.realign_prefix metainfo.slicetime_prefix metainfo.boldFile])};
    % cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{17}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{ind}.spm.spatial.smooth.fwhm = [6 6 6]; % Full  width  at  half maximum (FWHM) of the Gaussian smoothing kernel
    matlabbatch{ind}.spm.spatial.smooth.dtype = 0;
    matlabbatch{ind}.spm.spatial.smooth.im = 0; % An  "implicit  mask"  is  a mask implied by a particular voxel value
    matlabbatch{ind}.spm.spatial.smooth.prefix = metainfo.smooth_prefix;

    disp("normalize after smooth - matlabbatch index:");
    disp(ind+1);
    matlabbatch{ind+1}.spm.spatial.normalise.write.subj.def(1) = {fullfile(metainfo.anaDir, ['y_' metainfo.t1File])};
    matlabbatch{ind+1}.spm.spatial.normalise.write.subj.resample(1) = {fullfile(metainfo.anaDir, 'Brain.nii')};
    matlabbatch{ind+1}.spm.spatial.normalise.write.woptions.bb = [-78, -112, -70; 78, 76, 85]; % bounding box
    matlabbatch{ind+1}.spm.spatial.normalise.write.woptions.vox = [2 2 2]; % The voxel sizes (x, y & z, in mm) of the written normalised images.
    matlabbatch{ind+1}.spm.spatial.normalise.write.woptions.interp = 7; % 7th degree bspline interpolation
    matlabbatch{ind+1}.spm.spatial.normalise.write.woptions.prefix = metainfo.brain_norm_index; %metainfo.normalize_prefix; % which prefix for second time normalizing??
    % difference: both times forward deformation is def input, but this
    % time, resample is the image calculator thing
end