function compute_eigenvariate_mask(current_subject_location,num_session,region_struct)

region                   = region_struct.regions;
mask_location            = region_struct.mask;
u_threshold              = region_struct.u_threshold;
ext_threshold            = region_struct.ext_threshold;


%% STEPS REQUIRED FROM spm_getSPM.m
%Goal here is to define the thresholded xSPM struct, needed for the
%analysis

%Loads existing subject's SPM data file
try
    load(fullfile(current_subject_location,'SPM.mat'));
catch
    error(['Cannot read ' fullfile(current_subject_location,'SPM.mat')]);
end
SPM.swd = current_subject_location;
cd(SPM.swd); % Change directory so that relative filenames are valid

%Retrieve data from SPM.mat
try
    xX   = SPM.xX;				    %-Design definition structure
    XYZ  = SPM.xVol.XYZ;			%-XYZ coordinates
    S    = SPM.xVol.S;			    %-search Volume {voxels}
    R    = SPM.xVol.R;			    %-search Volume {resels}
    M    = SPM.xVol.M(1:3,1:3);		%-voxels to mm matrix
    VOX  = sqrt(diag(M'*M))';		%-voxel dimensions
catch
    
    error(['Error in', fullfile(current_subject_location,'SPM.mat'),...
        ': This model has not been estimated.']);
    
end

try
    xCon = SPM.xCon;
catch
    xCon = {};
end

%%Set contrast variable

Ic = 1; % Required variable for EFFECTS OF INTEREST

titlestr= 'effects of interest';

n=1; % n= conjunction number

IcAdd = []; % No new contrasts were defined

%Consequence of setting 'mask with other contrast(s)' to 'no'
Im = [];
pm = [];
Ex = [];

%-Compute & store contrast parameters, contrast/ESS images, & SPM
%images

SPM  = spm_contrasts(SPM, unique([Ic, Im, IcAdd]));

xCon     = SPM.xCon;
STAT     = xCon(Ic(1)).STAT;
VspmSv   = cat(1,xCon(Ic).Vspm);

%-Degrees of Freedom and STAT string describing marginal distribution

df      = [xCon(Ic(1)).eidf xX.erdf];
STATstr = sprintf('%c%s_{%.0f,%.0f}','F','',df(1),df(2));

%     fprintf('\t%-32s: %30s\n','SPM computation for subject ',...
%         current_subject_location,'...initialising')

%-Compute conjunction as minimum of SPMs
Z         = Inf;
for i     = Ic
    Z = min(Z,spm_get_data(xCon(i).Vspm,XYZ));
end

% P values for False Discovery FDR rate computation (all search voxels)
%case 'F'

Ps = (1 - spm_Fcdf(Z,df)).^n;

%     %-clean up interface
%     fprintf('\t%-32s: %30s\n','SPM computation for subject ',...
%         current_subject_location,'...done')
%
%-Height threshold - classical inference

u      = u_threshold; %Specified by the user

%-Get extent threshold [default = 0]
k      = ext_threshold;

thresDesc = ['p<' num2str(u) ' (unc.)'];
u         = spm_u(u^(1/n),df,STAT);

%-Calculate height threshold filtering
Q      = find(Z > u);

%-Apply height threshold
%-------------------------------------------------------------------
Z      = Z(:,Q);
XYZ    = XYZ(:,Q);
if isempty(Q)
    warning(sprintf('No voxels survive height threshold u=%0.2g',u))
end


%-Calculate extent threshold filtering

A     = spm_clusters(XYZ);
Q     = [];
for i = 1:max(A)
    j = find(A == i);
    if length(j) >= k; Q = [Q j]; end
end


% ...eliminate voxels

Z     = Z(:,Q);
XYZ   = XYZ(:,Q);
if isempty(Q)
    warning(sprintf('No voxels survive extent threshold k=%0.2g',k))
end


%-Assemble output structures of unfiltered data
%=======================================================================
xSPM   = struct( ...
    'swd',		current_subject_location,...
    'title',	titlestr,...
    'Z',		Z,...
    'n',		n,...
    'STAT',		STAT,...
    'df',		df,...
    'STATstr',	STATstr,...
    'Ic',		Ic,...
    'Im',		Im,...
    'pm',		pm,...
    'Ex',		Ex,...
    'u',		u,...
    'k',		k,...
    'XYZ',		XYZ,...
    'XYZmm',	SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))],...
    'S',		SPM.xVol.S,...
    'R',		SPM.xVol.R,...
    'FWHM',		SPM.xVol.FWHM,...
    'M',		SPM.xVol.M,...
    'iM',		SPM.xVol.iM,...
    'DIM',		SPM.xVol.DIM,...
    'VOX',		VOX,...
    'Vspm',		VspmSv,...
    'Ps',		Ps,...
    'thresDesc',thresDesc);

% RESELS per voxel (density) if it exists
%-----------------------------------------------------------------------
try, xSPM.VRpv  = SPM.VRpv;       end
try, xSPM.units = SPM.xVol.units; end


%% SECOND STEP

M         = SPM.xVol.M;
DIM       = SPM.xVol.DIM;
try
    units = SPM.xVol.units;
catch
    units = {'mm' 'mm' 'mm'};
end

% ensure pwd = swd so that relative filenames are valid
%----------------------------------------------------------------------
cd(SPM.swd)


%% EIGENVARIATE ANALYSIS FOR THE SPECIFIED REGION

fprintf('\t Eigenvariate analysis for subject %s \n \t at region %s \t ...started \n',...
    current_subject_location,region)
xY = {}; %Initialization

xY.name = 'VOI';

%Set 'adjust data for (select contrast)' to 'effects of interest'
xY.Ic = 1;

%Single session choice
xY.Sess   = num_session;

%Choose mask as a VOI definition
xY.def = 'mask';

%Initialization
Q = ones(1,size(xSPM.XYZmm,2));

%Extract desired VOI
if ~isfield(xY,'spec')
    xY.spec = spm_vol(mask_location);
else
    if ~isstruct(xY.spec)
        xY.spec = spm_vol(xY.spec);
    end;
end;
mXYZ=inv(xY.spec.mat)*[xSPM.XYZmm;ones(1,size(xSPM.XYZmm,2))];
tmpQ = spm_sample_vol(xY.spec,mXYZ(1,:),mXYZ(2,:),mXYZ(3,:),0);
tmpQ(~isfinite(tmpQ)) = 0;
Q = find(tmpQ);
%-Extract required data from results files

%-Get raw data, whiten and filter
y        = spm_get_data(SPM.xY.VY,xSPM.XYZ(:,Q));
y        = spm_filter(SPM.xX.K,SPM.xX.W*y);
xY.XYZmm = xSPM.XYZmm(:,Q);

%-Computation

% remove null space of contrast
if xY.Ic
    
    %-Parameter estimates: beta = xX.pKX*xX.K*y
    beta  = spm_get_data(SPM.Vbeta,xSPM.XYZ(:,Q));
    
    %-subtract Y0 = XO*beta,  Y = Yc + Y0 + e
    y     = y - spm_FcUtil('Y0',SPM.xCon(xY.Ic),SPM.xX.xKXs,beta);
    
end

% confounds
xY.X0     = SPM.xX.xKXs.X(:,[SPM.xX.iB SPM.xX.iG]);

% extract session-specific rows from data and confounds

try
    i     = SPM.Sess(xY.Sess).row;
    y     = y(i,:);
    xY.X0 = xY.X0(i,:);
end

% and add session-specific filter confounds

try
    xY.X0 = [xY.X0 SPM.xX.K(xY.Sess).X0];
end

try
    xY.X0 = [xY.X0 SPM.xX.K(xY.Sess).KH]; % Compatibility check
end


% Remove null space of X0

xY.X0   = xY.X0(:,~~any(xY.X0));

% compute regional response in terms of first eigenvariate

[m n]   = size(y);
if m > n
    [v s v] = svd(spm_atranspa(y));
    s       = diag(s);
    v       = v(:,1);
    u       = y*v/sqrt(s(1));
else
    [u s u] = svd(spm_atranspa(y'));
    s       = diag(s);
    u       = u(:,1);
    v       = y'*u/sqrt(s(1));
end
d       = sign(sum(v));
u       = u*d;
v       = v*d;
Y       = u*sqrt(s(1)/n); % quantity of interest!

% set in structure

xY.y    = y;
xY.u    = Y;
xY.v    = v;
xY.s    = s;

% show dynamics
try
    x_axis_for_Y = SPM.xY.RT*[1:length(xY.u)];
catch
    x_axis_for_Y = 0:length(Y);
end

% save results

if isfield(xY,'Sess')
    if length(xY.Sess) == 1
        str = sprintf('%s_S%i_%s_%s',xY.name,xY.Sess,...
            region,'mask');
    end
end

if spm_matlab_version_chk('7') >= 0
    save(fullfile(SPM.swd,str),'-V6','Y','xY','x_axis_for_Y','region_struct')
else
    save(fullfile(SPM.swd,str),'Y','xY','x_axis_for_Y','region_struct')
end

fprintf('\t Eigenvariate analysis for subject %s \n \t at region %s \t ...done \n',...
    current_subject_location,region)
