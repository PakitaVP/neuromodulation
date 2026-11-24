% This script will use image data to calculate temporal SNR for fMRI datasets.
% 
% NOTE!
% All calculations here are done from the first to the 2nd last (i.e. end-1 in Matlab lingo) dynamics.
% This doesn't affect the SFNR or BOLD sensitivity maps but is done because sometimes we collect data where 
% the last dynamic is a noise volume. 
%
%
% November 2021
%% Loading Image Data

% How many different experiments do we analyze here?
NumOfExperiments = 1;

% 32ch data w 3x3x3 mm^3 voxels, TE=27ms or 30ms, TR=2322.70ms, 40 slices
HDRs = spm_vol(spm_select(inf, '.*.nii', 'Select EPI data')); % SENSE = ???
i32ch_epi  = spm_read_vols(HDRs);

%% Just displaying original data to see importing and reconstruction went okay
figure('name', 'Checking original data quality')

% Displaying original In-vivo Data

% 30 ms
OffsetFromCenterSlice = 0;
Slice = OffsetFromCenterSlice + 0
subplot(2,4,1),  imagesc(rot90(squeeze(i32ch_epi(:,:,floor(size(i32ch_epi,3)/2) + Slice,1)),-1)), title('3.0mm, TE = 30ms'), axis image
colormap gray

%% Realigning the data
display('Realigning volumes of the time series (might take a minute or two)...')

[optimizer, metric] = imregconfig('monomodal'); % Needed for imregtform later

for Experiment = 1:NumOfExperiments
  switch(Experiment)
    case 1
      QAData = i32ch_epi;
  end
  rQAData = zeros(size(QAData)); % Pre-allocating data for realigned data set           
              
  for i = 1:size(QAData,4)  
    display(['Realigning volume #' num2str(i) ' for Experiment #' num2str(Experiment)])
    TempTrans = imregtform(squeeze(QAData(:,:,:,i)), squeeze(QAData(:,:,:,1)),'rigid', optimizer, metric);
    rQAData(:,:,:,i) = imwarp(squeeze(QAData(:,:,:,i)),TempTrans,'OutputView', imref3d(size(squeeze(QAData(:,:,:,1)))));
 
    Trans(i,1) = TempTrans.T(4,1);
    Trans(i,2) = TempTrans.T(4,2);
    Trans(i,3) = TempTrans.T(4,3);
    Rot(i,1)   = TempTrans.T(1,2);
    Rot(i,2)   = TempTrans.T(1,3);
    Rot(i,3)   = TempTrans.T(2,3);
  end
    
  switch(Experiment)
    case 1
      Trans_i32ch_3p0_TE30 = Trans;
      ri32ch_3p0_TE30 = rQAData;  
  end % ends switch statement
end % ends for experiment = 1:NumOfExperiment

%% Dispalying data to check realignment
figure('name', 'Checking Realignment of Data') % Testing if we need to realign or its effect

for slice = 1:size(ri32ch_3p0_TE30,3)
  subplot(1,2,1), imagesc(rot90(i32ch_epi(:,:,slice,1),-1), [10 1750]), axis image
  subplot(1,2,2), imagesc(rot90(ri32ch_3p0_TE30(:,:,slice,1),-1), [10 1750]), axis image
  pause(0.5)
end

%figure('name', 'Differences w and wo realignment')
% for slice = 1:size(i32ch_epi)
%   subplot(1,2,1), imagesc(rot90(squeeze( i32ch_epi(:,:,slice,1)) - squeeze( i32ch_epi(:,:,slice,size(i32ch_epi,4)-1)),-1), [-100 100]), title('3mm WITHOUT Realignment'), axis image
%   subplot(1,2,2), imagesc(rot90(squeeze(ri32ch_3p0_TE30(:,:,slice,1)) - squeeze(ri32ch_3p0_TE30(:,:,slice,size(ri32ch_3p0_TE30,4)-1)),-1), [-100 100]), title('3mm WITH Realignment'), axis image
%   pause(0.5)
% end

%% Detrending the REALIGNED data

for Experiment = 1:NumOfExperiments
    
  switch(Experiment)
     case 1
      QAData = ri32ch_3p0_TE30; % Make sure it's the realigned data from above
  end
  
  dQAData = zeros(size(QAData));
     
  for x = 1:size(QAData,1)
    display(['Working on #' num2str(x) ' out of ' num2str(size(QAData,1)) ' in Experiment #' num2str(Experiment) ' out of ' num2str(NumOfExperiments)])
    for y = 1:size(QAData,2)
      for z = 1:size(QAData,3)
        VoxData = squeeze(QAData(x,y,z,1:(size(QAData,4)-1)));
        p = polyfit(1:(size(QAData,4)-1), VoxData',2);
        yfit = polyval(p,1:(size(QAData,4)-1));
        dQAData(x,y,z,1:(size(QAData,4)-1)) = VoxData' - yfit + mean(VoxData);
      end
    end
  end
  
  switch(Experiment)
    % 32ch Data
    case 1
      dri32ch_3p0_TE30 = dQAData;
  end
end % end of for experiment = 1:NumOfExperiments

% %% Checking detrending
% figure('name', 'Checking Detrending of Data') % Testing if we need to realign or not
% 
% clf
% subplot(2,1,1), plot(squeeze(i32ch_1p8_TE27(30,30,20,1:199)),'r'), hold on, plot(squeeze(ri32ch_1p8_TE27(30,30,20,1:199)),'b'), plot(squeeze(dri32ch_1p8_TE27(30,30,20,1:199)),'k')
% subplot(2,1,2), plot(squeeze(i08ch_1p8_TE27(40,40,20,1:199)),'r'), hold on, plot(squeeze(ri08ch_1p8_TE27(40,40,20,1:199)),'b'), plot(squeeze(dri08ch_1p8_TE27(40,40,20,1:199)),'k')
% clf
% subplot(2,1,1), plot(squeeze(p32in1(20,20,20,1:199)),'r'), hold on, plot(squeeze(rp32in1(20,20,20,1:199)),'b'), plot(squeeze(drp32in1(20,20,20,1:199)),'k')
% subplot(2,1,2), plot(squeeze(p32in2(20,20,20,1:199)),'r'), hold on, plot(squeeze(rp32in2(20,20,20,1:199)),'b'), plot(squeeze(drp32in2(20,20,20,1:199)),'k')

%% Calculating temporal SNR from detrended  data

% First the voxel-wise mean
%%%%%%%%%%%%%%%%%%%%%%%%%%%
mdri32ch_3p0_TE30 = mean(dri32ch_3p0_TE30(:,:,:,1:end-1),4);


% Next the temporal fluctuations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sdri32ch_3p0_TE30 = std(dri32ch_3p0_TE30(:,:,:,1:end-1),0,4);

% Finally the SFNR
%%%%%%%%%%%%%%%%%%
SFNR_i32ch_3p0_TE30 = mdri32ch_3p0_TE30./sdri32ch_3p0_TE30;


%% Displaying final SFNR results 
figure('name', 'Temporal SNR Results') 

% 30 ms
OffsetFromCenterSlice = 0;
Slice = OffsetFromCenterSlice + 0
subplot(2,4,1),  imagesc(rot90(squeeze(SFNR_i32ch_3p0_TE30(:,:,floor(size(SFNR_i32ch_3p0_TE30,3)/2) + Slice,1)),-1), [0 140]), title(''), axis image

colormap jet

%% Calculating BOLD sensitivity 

BS_i32ch_3p0_TE30 = SFNR_i32ch_3p0_TE30 * 30;

%% Displaying the BOLD sensitivity maps
figure('name', 'BOLD Sensitivity Results') 

% 30 ms
OffsetFromCenterSlice = 0;
Slice = OffsetFromCenterSlice + 0
subplot(2,4,1),  imagesc(rot90(squeeze(BS_i32ch_3p0_TE30(:,:,floor(size(BS_i32ch_3p0_TE30,3)/10) + Slice,1)),-1), [0 140*30]), title(''), axis image
Slice = OffsetFromCenterSlice + 4;
subplot(2,4,2),  imagesc(rot90(squeeze(BS_i32ch_3p0_TE30(:,:,floor(size(BS_i32ch_3p0_TE30,3)/8) + Slice,1)),-1), [0 140*30]), title(''), axis image
Slice = OffsetFromCenterSlice + 8;
subplot(2,4,3),  imagesc(rot90(squeeze(BS_i32ch_3p0_TE30(:,:,floor(size(BS_i32ch_3p0_TE30,3)/4) + Slice,1)),-1), [0 140*30]), title(''), axis image
Slice = OffsetFromCenterSlice + 9;
subplot(2,4,4),  imagesc(rot90(squeeze(BS_i32ch_3p0_TE30(:,:,floor(size(BS_i32ch_3p0_TE30,3)/3) + Slice,1)),-1), [0 140*30]), title(''), axis image

Slice = OffsetFromCenterSlice + 4;
subplot(2,4,6),  imagesc(rot90(squeeze(BS_i32ch_3p0_TE30(:,:,floor(size(BS_i32ch_3p0_TE30,3)/2) + Slice,1)),-1), [0 140*30]), title('3.0mm, TE = 30ms'), axis image
Slice = OffsetFromCenterSlice + 8;
subplot(2,4,7),  imagesc(rot90(squeeze(BS_i32ch_3p0_TE30(:,:,floor(size(BS_i32ch_3p0_TE30,3)/2+size(BS_i32ch_3p0_TE30,3)/8) + Slice,1)),-1), [0 140*30]), title('3.0mm, TE = 30ms'), axis image
Slice = OffsetFromCenterSlice + 9;
subplot(2,4,8),  imagesc(rot90(squeeze(BS_i32ch_3p0_TE30(:,:,floor(size(BS_i32ch_3p0_TE30,3)/2+size(BS_i32ch_3p0_TE30,3)/6) + Slice,1)),-1), [0 140*30]), title('3.0mm, TE = 30ms'), axis image

colormap jet

