% requires the REST toolbox (some functions, at least)
% addpath('/home/toolbox/REST_V1.8_130615');
% 
% also requires the basic FDJenkinson estimation procedure
% [rel_rms, abs_rms] = FD_Jenkinson(RealignmentParameterFile,ReferenceImage);
% make sure REST tooblox and the path to FD Jenkinson are in the path!
%
%
% Input arguments:
%
% rpin = realignment paramters up till now (nvol-by-6 double array)
%
% im = full-path filename to one unnormalized 3D (!) image file - it is
%           best to take one of the 'mean' images just after 'ralign' (str)
%
% firstnvol = how many first volumes to remove? (int)
%
% fdthr = threshold for using the FD jenkinson-powered scannulling (float
%           between 0 and 1, OR -Inf)
%            -Inf mean:s NO FD 'powered' scannulling -
%           i.e. only apply firstnvol)
%
% fdlims = amount of scans to null BEFORE and AFTER affected scan ([int int]);
%           I advise to set this to [1 2];
%           this will be evaluated to [-1 0 1 2] scans to be removed
%           relative to the affected scans (i.e. where the fd thr > 0.5)
%           % if you set to [0 0], only affectd scan remved- no before or 
%           % after scans.. (duh)
%           % BOTH ints should be positive! - see example above.
%
% dofriston = do you wish to expand the 6 motion parameters to Friston-24?
%           % 1 = yes, 0 = no (int)
%
% 
%
% Output arguments:
%
% rpout = realignmentparameters + scannulling + FDJ scannulling in one
%           big matrix, so easy to include into SPM model (nvol-by-6+SN
%           double array). (SN - amount of scans to be 'nulled' - 
%           effectively excluded from the GLM.
%




function rpout = batch_AddFDJenkinsonAndScannullingToRpfile(rpin,im,firstnvol,fdthr,fdlims,dofriston)


    % we need this further down... - this is a wrapper function for a
    % script, so the code isn't TOO clean. But it is functional and should
    % not yield errors.
    NVOL = size(rpin,1);
    FDJ_THR = fdthr;
    BEFORE=fdlims(1);
    AFTER=fdlims(2);
    FIRSTREMOVE=firstnvol;
    rp=rpin;
    
    % call friston's function...
    [fdj, ~] = FD_Jenkinson(rpin,im);
    
    % now let us define stuff. nvol = 260, always, so...
    inds=find(fdj>FDJ_THR);
    tsteps = -1*BEFORE:AFTER;
    mat=zeros(NVOL,numel(inds)*numel(tsteps));
    for i=1:numel(inds)
        for j=1:numel(tsteps)
            tstep=tsteps(j);
            mati = inds(i)+tstep;
            if mati<1 || mati>NVOL
                % do nothing - column will remain 0 and left out of the
                % sum anyway.
            else
                % set the matrix to 1.
                mat(inds(i)+tstep,(i-1)*numel(tsteps)+j) = 1;
            end
        end
    end
    % add scannulling to mat..
    mat=[[eye(FIRSTREMOVE);zeros(NVOL-FIRSTREMOVE,FIRSTREMOVE)] mat];
    % determine which vols need to be zerod (if it appears twice - just
    % null it once is fine.
    must_zero = find(sum(mat,2)>0);
    
    % this is the actual regressor where each bol to be nulled is 1
    % column of zeros except for the vol.
    zeromat=zeros(NVOL,numel(must_zero));
    for i=1:numel(must_zero)
        zeromat(must_zero(i),i)=1;
    end
    
    % ok - now the rps..
    if dofriston
        fr24rp = [rp [zeros(1,6);rp(1:end-1,:)] rp.^2 [zeros(1,6);rp(1:end-1,:)].^2];
        allcovs = [fr24rp zeromat];
    else
        allcovs = [rp zeromat];
    end
    rpout=allcovs;
end
        