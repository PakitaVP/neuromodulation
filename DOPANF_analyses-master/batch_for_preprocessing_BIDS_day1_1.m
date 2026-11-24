%%
clear all;

debugmode = 0;

if debugmode == 1
    spmpath = '/Users/jkim/matlabwork/spm12/';
    datapath = '/Volumes/Research/RP_fMRI/BIDS/';
else
    spmpath = '/mnt/matlabwork/spm12/';
    datapath = '/mnt/RP_Juice/';
end

addpath(spmpath);
subjlists = readtable(fullfile(datapath,'analysis','subjlists.xlsx'));

for s = 1:25
    if subjlists.ignore(s) == 1 || subjlists.preprocessed(s) == 1
        continue
    else
        
        
        d = 1;
        clear matlabbatch imagefiles;
        imagefiles = table();
        currdatapath = fullfile(datapath, ['sub-' num2str(subjlists.subj(s))], ['ses-' num2str(subjlists.subj(s)*d)]);
        
        ST = clock;
        tic;
        
        
        % path
        anatPath = fullfile(datapath,['sub-' num2str(subjlists.subj(s))],['ses-' num2str(subjlists.subj(s))],'anat'); % only for MPRAGE
        fmriPath = fullfile(currdatapath,'func');
        fmapPath = fullfile(currdatapath,'fmap');
        
        %% Input image files
        % anatomy data
        imagefiles.t1w = spm_select('FPList', anatPath, sprintf('sub-%5d_ses-%5d_acq-%d_rec-1_T1w.nii',subjlists.subj(s),subjlists.subj(s),subjlists.mprage(s)));
        
        file_fmri = {}; file_fmap_shortecho_mag = {}; file_fmap_shortecho_phase = {};
        file_fmap_longecho_mag = {}; file_fmap_longecho_phase = {}; file_fmri_phys = {};
        
        % for the task fmri data
        for numfmri = 1:4
            % functional data
            file_fmri{numfmri} = sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmri%d(s))', d, numfmri))], sprintf('run-%d',numfmri));
            
            % fieldmap data
            file_fmap_shortecho_mag{numfmri} = spm_select('FPList',fmapPath, sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmap_fmri%d(s))',d,numfmri))],'shortecho_magnitude'));
            file_fmap_shortecho_phase{numfmri} = spm_select('FPList',fmapPath, sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmap_fmri%d(s))',d,numfmri))],'shortecho_phase'));
            file_fmap_longecho_mag{numfmri} = spm_select('FPList',fmapPath, sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmap_fmri%d(s))',d,numfmri))],'longecho_magnitude'));
            file_fmap_longecho_phase{numfmri} = spm_select('FPList',fmapPath, sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmap_fmri%d(s))',d,numfmri))],'longecho_phase'));
            
            % cardio/respiration physio data
            file_fmri_phys{numfmri} = spm_select('FPList',fmriPath, sprintf('%s.*%s.*.log',['acq-' eval(sprintf('num2str(subjlists.d%d_fmri%d(s))', d, numfmri))], sprintf('run-%d',numfmri)));
            
        end
        
        imagefiles.fmri = file_fmri;
        imagefiles.fmap_shortecho_mag = file_fmap_shortecho_mag;
        imagefiles.fmap_shortecho_phase = file_fmap_shortecho_phase;
        imagefiles.fmap_longecho_mag = file_fmap_longecho_mag;
        imagefiles.fmap_longecho_phase = file_fmap_longecho_phase;
        imagefiles.fmri_phys = file_fmri_phys;
        
        % for the whole brain epi
        imagefiles.fmriWB = sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmriwb(s))', d))], 'run-0');
        imagefiles.fmapWB_shortecho_mag = spm_select('FPList',fmapPath, sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmap_wb(s))',d))],'shortecho_magnitude'));
        imagefiles.fmapWB_shortecho_phase = spm_select('FPList',fmapPath, sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmap_wb(s))',d))],'shortecho_phase'));
        imagefiles.fmapWB_longecho_mag = spm_select('FPList',fmapPath, sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmap_wb(s))',d))],'longecho_magnitude'));
        imagefiles.fmapWB_longecho_phase = spm_select('FPList',fmapPath, sprintf('%s.*%s.*.nii',['acq-' eval(sprintf('num2str(subjlists.d%d_fmap_wb(s))',d))],'longecho_phase'));
        imagefiles.fmriWB_phys = spm_select('FPList',fmriPath, sprintf('%s.*%s.*.log',['acq-' eval(sprintf('num2str(subjlists.d%d_fmriwb(s))', d))], 'run-0'));
        
        
        %% VDM calculation
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.shortphase = imagefiles.fmap_shortecho_phase(1);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.shortmag = imagefiles.fmap_shortecho_mag(1);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.longphase = imagefiles.fmap_longecho_phase(1);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).data.phasemag.longmag = imagefiles.fmap_longecho_mag(1);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.et = [4.6 6.9];
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.maskbrain = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.blipdir = -1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.tert = 36.707;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.epifm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.ajm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.uflags.method = 'Mark3D';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.uflags.fwhm = 10;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.uflags.pad = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.uflags.ws = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.template = cellstr(fullfile(spmpath, 'toolbox', 'FieldMap', 'T1.nii'));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.fwhm = 5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.nerode = 2;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.ndilate = 4;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.thresh = 0.5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).defaults.defaultsval.mflags.reg = 0.02;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).session(1).epi = cellstr(spm_select('FPList', fmriPath, imagefiles.fmri(1)));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).session(2).epi = cellstr(spm_select('FPList', fmriPath, imagefiles.fmri(2)));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).matchvdm = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).sessname = 'session';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).writeunwarped = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).anat = '';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(1).matchanat = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).data.phasemag.shortphase = imagefiles.fmap_shortecho_phase(3);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).data.phasemag.shortmag = imagefiles.fmap_shortecho_mag(3);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).data.phasemag.longphase = imagefiles.fmap_longecho_phase(3);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).data.phasemag.longmag = imagefiles.fmap_longecho_mag(3);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.et = [4.6 6.9];
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.maskbrain = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.blipdir = -1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.tert = 36.707;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.epifm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.ajm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.uflags.method = 'Mark3D';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.uflags.fwhm = 10;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.uflags.pad = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.uflags.ws = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.mflags.template = cellstr(fullfile(spmpath, 'toolbox', 'FieldMap', 'T1.nii'));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.mflags.fwhm = 5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.mflags.nerode = 2;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.mflags.ndilate = 4;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.mflags.thresh = 0.5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).defaults.defaultsval.mflags.reg = 0.02;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).session(1).epi = cellstr(spm_select('FPList', fmriPath, imagefiles.fmri(3)));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).session(2).epi = cellstr(spm_select('FPList', fmriPath, imagefiles.fmri(4)));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).matchvdm = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).sessname = 'session';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).writeunwarped = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).anat = '';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(2).matchanat = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).data.phasemag.shortphase = cellstr(imagefiles.fmapWB_shortecho_phase);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).data.phasemag.shortmag = cellstr(imagefiles.fmapWB_shortecho_mag);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).data.phasemag.longphase = cellstr(imagefiles.fmapWB_longecho_phase);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).data.phasemag.longmag = cellstr(imagefiles.fmapWB_longecho_mag);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.et = [4.6 6.9];
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.maskbrain = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.blipdir = -1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.tert = 36.707;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.epifm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.ajm = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.uflags.method = 'Mark3D';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.uflags.fwhm = 10;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.uflags.pad = 0;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.uflags.ws = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.mflags.template = cellstr(fullfile(spmpath, 'toolbox', 'FieldMap', 'T1.nii'));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.mflags.fwhm = 5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.mflags.nerode = 2;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.mflags.ndilate = 4;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.mflags.thresh = 0.5;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).defaults.defaultsval.mflags.reg = 0.02;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).session.epi = cellstr(spm_select('FPList', fmriPath, imagefiles.fmriWB));
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).matchvdm = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).sessname = 'session';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).writeunwarped = 1;
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).anat = '';
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj(3).matchanat = 1;
        %% slice timing for EPI data
        
        matlabbatch{2}.spm.temporal.st.scans = {cellstr(spm_select('ExtFPList',fmriPath,imagefiles.fmri{1}))
            cellstr(spm_select('ExtFPList',fmriPath,imagefiles.fmri{2}))
            cellstr(spm_select('ExtFPList',fmriPath,imagefiles.fmri{3}))
            cellstr(spm_select('ExtFPList',fmriPath,imagefiles.fmri{4}))}';
        matlabbatch{2}.spm.temporal.st.nslices = 33;
        matlabbatch{2}.spm.temporal.st.tr = 2.1;
        matlabbatch{2}.spm.temporal.st.ta = 2.03636363636364;
        matlabbatch{2}.spm.temporal.st.so = [1:33];
        matlabbatch{2}.spm.temporal.st.refslice = 17;
        matlabbatch{2}.spm.temporal.st.prefix = 'a';
        
        % slice timing for whole brain EPI data
        matlabbatch{3}.spm.temporal.st.scans = {cellstr(spm_select('ExtFPList',fmriPath, imagefiles.fmriWB))};
        matlabbatch{3}.spm.temporal.st.nslices = 60;
        matlabbatch{3}.spm.temporal.st.tr = 3.6;
        matlabbatch{3}.spm.temporal.st.ta = 3.54;
        matlabbatch{3}.spm.temporal.st.so = [1:60];
        matlabbatch{3}.spm.temporal.st.refslice = 30;
        matlabbatch{3}.spm.temporal.st.prefix = 'a';
        
        %%
        matlabbatch{4}.spm.spatial.realignunwarp.data.scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{4}.spm.spatial.realignunwarp.data.pmscan(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 1, Session 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{1}));
        matlabbatch{4}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
        matlabbatch{4}.spm.spatial.realignunwarp.eoptions.sep = 4;
        matlabbatch{4}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
        matlabbatch{4}.spm.spatial.realignunwarp.eoptions.rtm = 0;
        matlabbatch{4}.spm.spatial.realignunwarp.eoptions.einterp = 7;
        matlabbatch{4}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
        matlabbatch{4}.spm.spatial.realignunwarp.eoptions.weight = '';
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.jm = 0;
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.sot = [];
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.rem = 1;
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.noi = 5;
        matlabbatch{4}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
        matlabbatch{4}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
        matlabbatch{4}.spm.spatial.realignunwarp.uwroptions.rinterp = 7;
        matlabbatch{4}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
        matlabbatch{4}.spm.spatial.realignunwarp.uwroptions.mask = 1;
        matlabbatch{4}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
        
        %
        matlabbatch{5}.spm.spatial.realignunwarp.data.scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 2)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','files'));
        matlabbatch{5}.spm.spatial.realignunwarp.data.pmscan(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 1, Session 2)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{2}));
        matlabbatch{5}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
        matlabbatch{5}.spm.spatial.realignunwarp.eoptions.sep = 4;
        matlabbatch{5}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
        matlabbatch{5}.spm.spatial.realignunwarp.eoptions.rtm = 0;
        matlabbatch{5}.spm.spatial.realignunwarp.eoptions.einterp = 7;
        matlabbatch{5}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
        matlabbatch{5}.spm.spatial.realignunwarp.eoptions.weight = '';
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.jm = 0;
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.sot = [];
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.rem = 1;
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.noi = 5;
        matlabbatch{5}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
        matlabbatch{5}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
        matlabbatch{5}.spm.spatial.realignunwarp.uwroptions.rinterp = 7;
        matlabbatch{5}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
        matlabbatch{5}.spm.spatial.realignunwarp.uwroptions.mask = 1;
        matlabbatch{5}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
        
        %
        matlabbatch{6}.spm.spatial.realignunwarp.data.scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 3)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{3}, '.','files'));
        matlabbatch{6}.spm.spatial.realignunwarp.data.pmscan(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 2, Session 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','vdmfile', '{}',{1}));
        matlabbatch{6}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
        matlabbatch{6}.spm.spatial.realignunwarp.eoptions.sep = 4;
        matlabbatch{6}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
        matlabbatch{6}.spm.spatial.realignunwarp.eoptions.rtm = 0;
        matlabbatch{6}.spm.spatial.realignunwarp.eoptions.einterp = 7;
        matlabbatch{6}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
        matlabbatch{6}.spm.spatial.realignunwarp.eoptions.weight = '';
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.jm = 0;
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.sot = [];
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.rem = 1;
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.noi = 5;
        matlabbatch{6}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
        matlabbatch{6}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
        matlabbatch{6}.spm.spatial.realignunwarp.uwroptions.rinterp = 7;
        matlabbatch{6}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
        matlabbatch{6}.spm.spatial.realignunwarp.uwroptions.mask = 1;
        matlabbatch{6}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
        
        
        matlabbatch{7}.spm.spatial.realignunwarp.data.scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 4)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{4}, '.','files'));
        matlabbatch{7}.spm.spatial.realignunwarp.data.pmscan(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 2, Session 2)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','vdmfile', '{}',{2}));
        matlabbatch{7}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
        matlabbatch{7}.spm.spatial.realignunwarp.eoptions.sep = 4;
        matlabbatch{7}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
        matlabbatch{7}.spm.spatial.realignunwarp.eoptions.rtm = 0;
        matlabbatch{7}.spm.spatial.realignunwarp.eoptions.einterp = 7;
        matlabbatch{7}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
        matlabbatch{7}.spm.spatial.realignunwarp.eoptions.weight = '';
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.jm = 0;
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.sot = [];
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.rem = 1;
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.noi = 5;
        matlabbatch{7}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
        matlabbatch{7}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
        matlabbatch{7}.spm.spatial.realignunwarp.uwroptions.rinterp = 7;
        matlabbatch{7}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
        matlabbatch{7}.spm.spatial.realignunwarp.uwroptions.mask = 1;
        matlabbatch{7}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
        
        
        matlabbatch{8}.spm.spatial.realignunwarp.data.scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{8}.spm.spatial.realignunwarp.data.pmscan(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 3, Session 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{3}, '.','vdmfile', '{}',{1}));
        matlabbatch{8}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
        matlabbatch{8}.spm.spatial.realignunwarp.eoptions.sep = 4;
        matlabbatch{8}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
        matlabbatch{8}.spm.spatial.realignunwarp.eoptions.rtm = 0;
        matlabbatch{8}.spm.spatial.realignunwarp.eoptions.einterp = 7;
        matlabbatch{8}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
        matlabbatch{8}.spm.spatial.realignunwarp.eoptions.weight = '';
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.jm = 0;
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.sot = [];
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.rem = 1;
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.noi = 5;
        matlabbatch{8}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
        matlabbatch{8}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
        matlabbatch{8}.spm.spatial.realignunwarp.uwroptions.rinterp = 7;
        matlabbatch{8}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
        matlabbatch{8}.spm.spatial.realignunwarp.uwroptions.mask = 1;
        matlabbatch{8}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
        
        matlabbatch{9}.spm.spatial.preproc.channel.vols = cellstr(imagefiles.t1w);
        matlabbatch{9}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{9}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{9}.spm.spatial.preproc.channel.write = [1 1];
        matlabbatch{9}.spm.spatial.preproc.tissue(1).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,1'));
        matlabbatch{9}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{9}.spm.spatial.preproc.tissue(1).native = [1 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(2).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,2'));
        matlabbatch{9}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{9}.spm.spatial.preproc.tissue(2).native = [1 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(3).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,3'));
        matlabbatch{9}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{9}.spm.spatial.preproc.tissue(3).native = [1 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(4).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,4'));
        matlabbatch{9}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{9}.spm.spatial.preproc.tissue(4).native = [1 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(5).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,5'));
        matlabbatch{9}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{9}.spm.spatial.preproc.tissue(5).native = [1 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(6).tpm = cellstr(fullfile(spmpath, 'tpm', 'TPM.nii,6'));
        matlabbatch{9}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{9}.spm.spatial.preproc.tissue(6).native = [0 0];
        matlabbatch{9}.spm.spatial.preproc.tissue(6).warped = [0 0];
        matlabbatch{9}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{9}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{9}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{9}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{9}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{9}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{9}.spm.spatial.preproc.warp.write = [1 1];
        
        matlabbatch{10}.cfg_basicio.file_dir.cfg_fileparts.files(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
        
        matlabbatch{11}.spm.util.imcalc.input(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
        matlabbatch{11}.spm.util.imcalc.input(2) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
        matlabbatch{11}.spm.util.imcalc.input(3) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
        matlabbatch{11}.spm.util.imcalc.input(4) = cfg_dep('Segment: c3 Images', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
        matlabbatch{11}.spm.util.imcalc.output = 'Brain';
        matlabbatch{11}.spm.util.imcalc.outdir(1) = cfg_dep('Get Pathnames: Directories (unique)', substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','up'));
        matlabbatch{11}.spm.util.imcalc.expression = '((i2 + i3 + i4)>0.9) .* i1';
        matlabbatch{11}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{11}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{11}.spm.util.imcalc.options.mask = 0;
        matlabbatch{11}.spm.util.imcalc.options.interp = -7;
        matlabbatch{11}.spm.util.imcalc.options.dtype = 16;
        
        matlabbatch{12}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
        matlabbatch{12}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
        matlabbatch{12}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
        matlabbatch{12}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{12}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{12}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{12}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        
        matlabbatch{13}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
        matlabbatch{13}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
        matlabbatch{13}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
        matlabbatch{13}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{13}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{13}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{13}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        
        matlabbatch{14}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
        matlabbatch{14}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
        matlabbatch{14}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
        matlabbatch{14}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{14}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{14}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{14}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        
        matlabbatch{15}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
        matlabbatch{15}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
        matlabbatch{15}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
        matlabbatch{15}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{15}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{15}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{15}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        
        matlabbatch{16}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Image Calculator: ImCalc Computed Image: Brain', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
        matlabbatch{16}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
        matlabbatch{16}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{12}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
        matlabbatch{16}.spm.spatial.coreg.estimate.other(2) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{13}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
        matlabbatch{16}.spm.spatial.coreg.estimate.other(3) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{14}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
        matlabbatch{16}.spm.spatial.coreg.estimate.other(4) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{15}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
        matlabbatch{16}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{16}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{16}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{16}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        
        matlabbatch{17}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
        matlabbatch{17}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{16}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
        matlabbatch{17}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
            78 76 85];
        matlabbatch{17}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
        matlabbatch{17}.spm.spatial.normalise.write.woptions.interp = 7;
        matlabbatch{17}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        matlabbatch{18}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{17}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{18}.spm.spatial.smooth.fwhm = [6 6 6];
        matlabbatch{18}.spm.spatial.smooth.dtype = 0;
        matlabbatch{18}.spm.spatial.smooth.im = 0;
        matlabbatch{18}.spm.spatial.smooth.prefix = 's6';
        
        matlabbatch{19}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
        matlabbatch{19}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Image Calculator: ImCalc Computed Image: Brain', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
        matlabbatch{19}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
            78 76 85];
        matlabbatch{19}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
        matlabbatch{19}.spm.spatial.normalise.write.woptions.interp = 7;
        matlabbatch{19}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        spm_jobman('interactive',matlabbatch);
        
        elapsedtime = toc;
        %%
        ET = clock;
        
        fprintf('=======================================================================\n');
        fprintf('    ses-%d is preprocessed\n', subjlists.subj(s)*d);
        fprintf('    Started Time : %g-%g-%g  %g:%g:%d \n', round(ST));
        fprintf('        End Time : %g-%g-%g  %g:%g:%d \n', round(ET));
        fprintf('    Elapsed Time : %g min. (%g sec.)\n',elapsedtime/60, elapsedtime);
        fprintf('=======================================================================\n\n');
     
    end
end
