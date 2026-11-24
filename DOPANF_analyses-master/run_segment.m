function matlabbatch = run_segment(anaDir, t1File)   
    global spmpath;
    spm_jobman('initcfg');
    global defaults
    defaults.stats.maxmem   = 2^30;
    clear matlabbatch
    matlabbatch = {};
    disp(fullfile(anaDir, t1File));

    
    matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(fullfile(anaDir, t1File)); 
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,1'));
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,2'));
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,3'));
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,4'));
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,5'));
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,6'));
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];
    disp("imcalc in segment - matlabbatch 1ex:");
    disp(2);
    
    matlabbatch{2}.spm.util.imcalc.input = {fullfile(anaDir, ['BiasField_' t1File]); fullfile(anaDir, ['c1' t1File]); fullfile(anaDir, ['c2' t1File]); fullfile(anaDir, ['c3' t1File])};
    matlabbatch{2}.spm.util.imcalc.output = 'Brain';
    matlabbatch{2}.spm.util.imcalc.outdir(1) = cellstr(anaDir); %{'testdir'}; % cfg_dep('Get Pathnames: Directories (unique)', substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','up'));
    matlabbatch{2}.spm.util.imcalc.expression = '((i2 + i3 + i4)>0.9) .* i1';
    matlabbatch{2}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{2}.spm.util.imcalc.options.mask = 0;
    matlabbatch{2}.spm.util.imcalc.options.interp = 1;
    matlabbatch{2}.spm.util.imcalc.options.dtype = 4;
    
    spm_jobman('run',matlabbatch);
end