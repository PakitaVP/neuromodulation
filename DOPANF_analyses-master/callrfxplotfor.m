function [ output_args ] = callrfxplotfor( )
%callrfxplotfor 
%   Detailed explanation goes here

% 1. load the RFX SPM.mat

%rfxdir = pwd;

rfxdir = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/DOPANF_stats/group_stats/NFTask_Dec_pmod_regright';
load(fullfile(rfxdir,'SPM.mat'))

% 2. create the xSPM struct (e.g. for contrast 3
% at 0.001 uncorrected) [see help in results_nogui]
%contrastNr = 5;
contrastNr = 1;
xSPM = results_nogui('val',rfxdir, contrastNr);

% 3. define RFX coordinates
rfxxyz = [-42 22 -10];

% 4a. create a defaults opts struct
% and replace necessary fields
opts = rfx_setup_opts;
opts.rfxdir = rfxdir;
opts.xyz = rfxxyz;
%.task
%[char] <?effect?,?fitresp?,?psth?,?extract?> task type
%(i.e., plot effect, ?tted response, PSTHs (aka time courses), extract the data.
opts.task = 'psth';

% .pre?x [char] ?lename pre?x for 1st level analyses from which to extract and
% plot the data.
opts.prefix = 'beta';

% .space [char] <?sphere?,?voxel?,?box?,?image?> type RFX search
% volume .
opts.space = 'sphere';

% .dim [double] dimension of the RFX search volume (in case of sphere, this
% denotes the radius).
opts.dim = [3];
% .mask [cell array] name(s) of the anatomical mask images de?ning the (groupwise or individual) search volumes.
opts.mask = {''};
%opts.mask = {};
% .limit [boolean] <0, 1> Limit voxel selection to supra-threshold voxels? (1
 %= yes, 0 = no).
opts.limit = 0;

% .limtype [char] <?maskffx?,?peakffx?,?sphereffx?,?allrfx?>
% how to select the individual voxels in the RFX search volume: ?maskffx? ?
% anatomical masks (de?ned in opts.mask), ?peakffx? ? individual peak voxel
% in RFX search volume, ?sphereffx? ? individual sphere around peak voxel,
% ?allrfx? ? all voxels in RFX search volume (con?ned to supra-threshold voxels if opts.limit = 1.
opts.limtype = 'allrfx';

% .ffxsphere [double] radius of the individual sphere around the peak voxel in
% RFX search volume.
opts.ffxsphere = 0;

% .select [double] index numbers for the 1st level images from which to extract
% the data (see table in GUI version of rfxplot for a list of the indices.
opts.select = [4 6 29 31 54 56];

% .selname [cell array] image descriptions of the selected images (non-essential
% option).
%opts.selname = {'Sn(1) onset_amountsxamount_value^1*bf(1)','Sn(1) Delay onsxDelay^1*bf(1)'};
opts.selname = {'Sn(1) Decision_accepted*bf(1)', 'Sn(1) Decision_rejected*bf(1)', 'Sn(2) Decision_accepted*bf(1)', 'Sn(2) Decision_rejected*bf(1)', 'Sn(3) Decision_accepted*bf(1)', 'Sn(3) Decision_rejected*bf(1)'};

% .regtype [cell array] <?reg?,?pmod?> type of regressor for each select
% image (reg = onset regressor, pmod = parametric modulation).
%opts.regtype = {'pmod' ,'pmod'};
opts.regtype = {'reg'  'reg'  'reg'  'reg'  'reg'  'reg'};

% .repl [double] vector indicating which images should be averaged (those with
% the same number in opts.repl).
opts.repl = [1 2 1 2 1 2];

% .reglabel [cell array] short description of the image. This is used as a label
% in the plot. If some images are replications, then opts.reglabel should have
% max(opts.repl) elements.
opts.reglabel = {'accepted'  'rejected'};

% .nbin [cell array] number of bins in which to split a regressor.
opts.nbin = {[1]  [1]  [1]  [1]  [1]  [1]};

% .binthresh [cell array] threshold for bins when splitting up regressors. The
% threshold of each image are themselves cell arrays with either a 2-element
% vector (lower/ upper boundary) or a string specifying a trial range.
opts.binthresh  = {[]  []  []  []  []  []};
opts.bintype = {'none'  'none'  'none'  'none'  'none'  'none'};
% .binnames [cell array] names for the bins. For each regressors there is a
% cell array of nbin names. This is used as a label in the plot. If some images
% are replications (opts.repl =0), then opts.binnames should have max(opts.repl)
% elements.
opts.binnames = {'',''};
% .ngroup [double] number of group in which to split the sample
opts.ngroup = 1;

% opts.ngroup = {};
% .group [cell array] subject numbers for each group. The numbers correspond to the order of the subject as they are entered in the RFX analysis
% (and found in SPM.xY.P)
opts.group = {[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41]};
%opts.group = {};

% .gname [cell array] names of the groups (empty for only a single group)
opts.gname = {''};
%opts.gname = {};

% .?lter [char] <?none?,?hpf?,?ar1?,?both?> ?ltering option for extracted time courses
opts.filter = 'both';

% .indiX0 [double] column numbers of regressors for which the time course should
% be adjusted (opts.adjust = ?user?)
% .adjust [char] <?none?,?block?,?nuis?,?all?,?user?,?con?>
% adjustment options for extracted time series
opts.adjust = 'nuis';

%opts.winbound [double] boundaries of time window for plotting PSTHs
%opts.winbound = [-7.23 14.46];
opts.winbound = [-10 6];

% .winlength [double] length of PSTH window (computed automatically)
opts.winlength = [16];

% .binwidth [double] width of each PSTH bin (default 1 TR)
opts.binwidth = [2];

% .resample [double] time resolution to which the extracted time course should
% be resampled
opts.resample = 0;

% .rescale [boolean] <0,1> mean-correct PSTH at stimulus onset
opts.rescale = 0;

% .scale [char] <?pcnt?,?es?> scale of the plotted data (?pcnt? = percent
% signal change, ?es? = effect size)
opts.scale = 'pcnt';

% .where [char] <?spm?, axis command> where to plot the data
opts.where = 'spm';

% .plottype [char] <?bar?,?dot?,?dotline?> plot type for plotting effects
opts.plottype = 'psth';

% .overlay [boolean] <0,1> Overlay individual data?
opts.overlay = 0;

% .sublabel [boolean] <0,1> Include subject numbers?
opts.sublabel = 1;

% .error [char] <?none?,?sd?,?sem?,?ci?> type of error bar
opts.error = 'sem';

% .errcol [char] <?s?, ?k?> color of the error bar (?s?ame or
opts.errcol = 's';

% .errtype [char] <?bar?,?area?> type of error (?bar? = error bar, ?area? 
% error area (bounds around the PSTH or ?tted response)) blac?k?)
opts.errtype = 'area';

% .coltype [char] <?effect?,?bin?,?manual?> how to specify the colors for the plot
opts.coltype = 'effect';
% .colgrad [boolean] <0,1> Make a color gradient for different bins?
opts.colgrad = 0;

% .xtick [double] XTick positions for the different effects
opts.xtick = [];
% .?t cell array[] column number for which to ?t an additional regression

% .?tfun [cell array] <?lin?,?quad?,?exp?,?log?> type of regression
% to ?t to the data

% .?tcol [cell array] colors of the regression line
opts.color = {'g', 'b'};
%opts.color = {'g'};
% .name [char] name for the plot con?guration (for saving)
opts.name = 'decisions_psth';

% 5. call rfxplot non-interactively
rfxplot(rfxxyz,opts,SPM,xSPM);

%getStatValuesFromRfxplot;

end


function [xSPM] = results_nogui(dunno, path, contrast)

%batch_resultsreport;

% .swd      - SPM working directory - directory containing current SPM.mat
% .title    - title for comparison (string)
% .Ic       - indices of contrasts (in SPM.xCon)
% .n        - conjunction number <= number of contrasts
% .Im       - indices of masking contrasts (in xCon)
% .pm       - p-value for masking (uncorrected)
% .Ex       - flag for exclusive or inclusive masking
% .u        - height threshold
% .k        - extent threshold {voxels}
% .thresDesc - description of height threshold (string)


xSPMin.swd = path;
 xSPMin.Ic = contrast;
 xSPMin.Im = [];
 xSPMin.title = '';
 xSPMin.u = 3.225;
 xSPMin.k = 0;
 xSPMin.pm = 0.001;
 xSPM.thresDesc = 'none';
 %xSPM.pm = [];
 xSPM.Ex =[];



%xSPM      - structure containing SPM, distribution & filtering details
% .swd      - SPM working directory - directory containing current SPM.mat
% .title    - title for comparison (string)
% .Z        - minimum of Statistics {filtered on u and k}
% .n        - conjunction number <= number of contrasts
% .STAT     - distribution {Z, T, X, F or P}
% .df       - degrees of freedom [df{interest}, df{residual}]
% .STATstr  - description string
% .Ic       - indices of contrasts (in SPM.xCon)
% .Im       - indices of masking contrasts (in xCon)
% .pm       - p-value for masking (uncorrected)
% .Ex       - flag for exclusive or inclusive masking
% .u        - height threshold
% .k        - extent threshold {voxels}
% .XYZ      - location of voxels {voxel coords}
% .XYZmm    - location of voxels {mm}
% .S        - search Volume {voxels}
% .R        - search Volume {resels}
% .FWHM     - smoothness {voxels}
% .M        - voxels -> mm matrix
% .iM       - mm -> voxels matrix
% .VOX      - voxel dimensions {mm} - column vector
% .DIM      - image dimensions {voxels} - column vector
% .Vspm     - Mapped statistic image(s)
% .Ps       - uncorrected P values in searched volume (for voxel FDR)
% .Pp       - uncorrected P values of peaks (for peak FDR)
% .Pc       - uncorrected P values of cluster extents (for cluster FDR)
% .uc       - 0.05 critical thresholds for FWEp, FDRp, FWEc, FDRc
% .thresDesc - description of height threshold (string)




[SPM, xSPM] = spm_getSPM(xSPMin);

end

