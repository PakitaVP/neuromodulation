function compute_ppi_variables_mask(current_subject_location,num_run,num_session,VOI_str,region_struct,contrast_struct)

physio_variable          = region_struct.regions;
name_contrast            = contrast_struct.names;
contrasts                = contrast_struct.contrast_vector;
num_session_str          = num2str(num_session);
num_run_str              = num2str(num_run);
save_directory_name      = ['stats_',num_run_str,'_S',num_session_str,'_',name_contrast,'_',physio_variable,'_mask'];


fprintf('\t PPI analysis for subject %s \n \t for region %s  and contrast %s \t ...started \n',...
        current_subject_location,physio_variable,name_contrast)
    %Loads existing subject's SPM data file
    current_SPM_mat_file_location = fullfile(deblank(current_subject_location),'SPM.mat');
    try
        load(current_SPM_mat_file_location);
    catch
        error(['Cannot read ' current_SPM_mat_file_location]);
    end
    
    cd(current_subject_location); % Change directory so that relative filenames are valid
    
    %Retrieve data from SPM.mat
    try
        RT     = SPM.xY.RT;
        dt     = SPM.xBF.dt;
        NT     = RT/dt;      %Number of trials
    catch
        error(['Error in', current_SPM_mat_file_location,...
            ': Did not find SPM.xY.RT or SPM.xBF.dt .']);
    end
    
    %Load the physiological data
    
    desired_VOI = [VOI_str,'.mat'];%['VOI_S',num_session_str,'_',physio_variable,'_sphere_',radius_str,'mm_radius','.mat'];
    load(desired_VOI)
    
    try
        Sess  = SPM.Sess(xY.Sess);
    catch
        error('No xY.Sess found in VOI xY file')
    end
    
    
    % get 'causes' or inputs U
    %----------------------------------------------------------------------
    U.name = {};
    U.u    = [];
    U.w    = [];
    
    u      = length(Sess.U);
%     if u ~= num_contrasts
%         error('Number of contrasts entered in function call does not match the number of contrasts in xY.Sess')
%     end
    
    for  i = 1:u
        try
        tmpw = contrasts(i);
        % if tmpw==0 then don't include the column in the
        % design. This takes care of the possibility that
        % the user would select to include the column but
        % then give it a 0 weight.
        %------------------------------------------------
        if tmpw ~= 0
            U.w             = [U.w tmpw];
            U.u             = [U.u Sess.U(i).u(33:end,1)];
            U.name{end + 1} = Sess.U(i).name{1};
        end
        catch
            i = i+1; % This corresponds to the uninteresting variables
                     % posterror, error, missing, eliminated, which are
                     % all set to zero weight by default
        end
    end
    
    %ppiFilename = 'PPI';  %Not needed
    
    % Setup variables
    %-------------------------------------------------------------------------
    N = length(xY.u);
    k = 1:NT:N*NT;  			% microtime to scan time indices
    
    % create basis functions and hrf in scan time and microtime
    %-------------------------------------------------------------------------
    hrf = spm_hrf(dt);
    
    % create convolved explanatory {Hxb} variables in scan time
    %-------------------------------------------------------------------------
    xb  = spm_dctmtx(N*NT + 128,N);
    Hxb = zeros(N,N);
    for i = 1:N
        Hx       = conv(xb(:,i),hrf);
        Hxb(:,i) = Hx(k + 128);
    end
    xb = xb(129:end,:);
    
    % get confounds (in scan time) and constant term
    %-------------------------------------------------------------------------
    X0 = xY.X0;
    M  = size(X0,2);
    
    
    % get response variable,
    %-------------------------------------------------------------------------
    
    Y(:,1) = xY.u;
    
    % remove confounds and save Y in ouput structure
    %-------------------------------------------------------------------------
    Yc = Y - X0*inv(X0'*X0)*X0'*Y;
    PPI.Y = Yc(:,1);
    
    % specify covariance components; assume neuronal response is white
    % treating confounds as fixed effects
    %-------------------------------------------------------------------------
    Q = speye(N,N)*N/trace(Hxb'*Hxb);
    Q = blkdiag(Q, speye(M,M)*1e6  );
    
    % get whitening matrix (NB: confounds have already been whitened)
    %-------------------------------------------------------------------------
    W = SPM.xX.W(Sess.row,Sess.row);
    
    % create structure for spm_PEB
    %-------------------------------------------------------------------------
    P{1}.X = [W*Hxb X0];		% Design matrix for lowest level
    P{1}.C = speye(N,N)/4;		% i.i.d assumptions
    P{2}.X = sparse(N + M,1);	% Design matrix for parameters (0's)
    P{2}.C = Q;
    
    
    
    %=====================================================================
    
    % COMPUTE PSYCHOPHYSIOLOGIC INTERACTIONS
    % use basis set in microtime
    %---------------------------------------------------------------------
    % get parameter estimates and neural signal; beta (C) is in scan time
    % This clever trick allows us to compute the betas in scan time which is
    % much quicker than with the large microtime vectors. Then the betas
    % are applied to a microtime basis set generating the correct neural
    % activity to convolve with the psychological variable in mircrotime
    %---------------------------------------------------------------------
    C  = spm_PEB(Y,P);
    xn = xb*C{2}.E(1:N);
    xn = spm_detrend(xn);
    
    % setup psychological variable from inputs and contrast weights
    %---------------------------------------------------------------------
    PSY = zeros(N*NT,1);
    for i = 1:size(U.u,2)
        PSY = PSY + full(U.u(:,i)*U.w(:,i));
    end
    %         PSY = spm_detrend(PSY);  <- removed centering of psych variable
    %         prior to multiplication with xn. Based on discussion with Karl
    %         and Donald McLaren.
    
    % multiply psychological variable by neural signal
    %---------------------------------------------------------------------
    PSYxn = PSY.*xn;
    
    % convolve and resample at each scan for bold signal
    %---------------------------------------------------------------------
    ppi	= conv(PSYxn,hrf);
    ppi = ppi(k);
    
    % similarly for psychological effect
    %---------------------------------------------------------------------
    PSYHRF = conv(PSY,hrf);
    PSYHRF = PSYHRF(k);
    
    % save psychological variables
    %---------------------------------------------------------------------
    PPI.psy = U;
    PPI.P   = PSYHRF;
    PPI.xn  = xn;
    PPI.ppi = spm_detrend(ppi);
    
    
    % setup other output variables and Save
    %-------------------------------------------------------------------------
    PPI.xY = xY;
    PPI.dt = dt;
    
    
    %% Saving variables on parent folder
    
    str = sprintf('%s_%i_%s_mask_%s%s','PPI_S',xY.Sess,physio_variable,name_contrast,'.mat');
    
    %cd ..
    if ~exist(save_directory_name,'dir')
        eval(sprintf(['mkdir(','''','%s','''',')'],save_directory_name));
        fprintf('%s created,\n',save_directory_name);
    end
    
    cd(current_subject_location);
    
    %parent_folder=fileparts(SPM.swd);
    parent_folder=fileparts(current_subject_location);
    
    if spm_matlab_version_chk('7') >= 0,
        save(fullfile(parent_folder,save_directory_name,str),'-V6','PPI','region_struct','contrast_struct')
    else
        save(fullfile(parent_folder,save_directory_name,str),'PPI','region_struct','contrast_struct')
    end
    
    copyfile(desired_VOI,fullfile(parent_folder,save_directory_name))
    
fprintf('\t PPI analysis for subject %s \n \t for region %s  and contrast %s \t ...done \n',...
        current_subject_location,physio_variable,name_contrast)
    
    