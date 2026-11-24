%% VDM calculation
function matlabbatch = batch_VDM(metainfo, matlabbatch)
    global spmpath;
    
    ind = length(matlabbatch)+1;
    disp("VDM - matlabbatch index:");
    disp(ind);
    
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.shortphase = metainfo.fm_files.phase1; % fmap_shortecho_phase;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.shortmag = metainfo.fm_files.magnitude1;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.longphase = metainfo.fm_files.phase2;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.longmag = metainfo.fm_files.magnitude2;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.et = [4.6 6.9];
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.maskbrain = 1;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.blipdir = -1;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.tert = 36.707;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.epifm = 0;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.ajm = 0;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.uflags.method = 'Mark3D';
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.uflags.fwhm = 10;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.uflags.pad = 0;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.uflags.ws = 1;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.template = cellstr(fullfile(spmpath, 'toolbox', 'FieldMap', 'T1.nii'));
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.fwhm = 5;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.nerode = 2;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.ndilate = 4;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.thresh = 0.5;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.reg = 0.02;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).session(1).epi = cellstr(fullfile(metainfo.funcDir, metainfo.boldFile));
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).matchvdm = 1;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).sessname = 'session';
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).writeunwarped = 1;
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).anat = '';
    matlabbatch{ind}.spm.tools.fieldmap.calculatevdm.subj(1).matchanat = 1;
    % spm_jobman('run',matlabbatch);
end
