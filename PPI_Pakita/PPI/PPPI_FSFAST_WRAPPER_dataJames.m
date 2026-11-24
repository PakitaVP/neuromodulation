function PPPI_FSFAST_WRAPPER()

%addpath('')
spmpath = which('spm')
if(~isempty(spmpath))
    rmpath(genpath(fileparts(spmpath)))
end
clear classes
addpath(genpath('/usr/local/MATLAB/R2016b/toolbox/spm8'));
addpath('/media/sf_Share_NeuroDebian/cofeed16/cofeed16/batches/NF_VTA_MVPA/spm/PPI/PPPIv13/')

bool_OS_linux = 1;
Study_Dir='/media/sf_Share_NeuroDebian/data_james/analysis/';
Mask_Dir='/media/sf_Share_NeuroDebian/cofeed16/cofeed16/masks/';

% subjects
if (1 == bool_OS_linux)
    subjects_description = readtable('/media/sf_Share_NeuroDebian/data_james/SubjectDescription.csv', 'Delimiter',',','ReadVariableNames',true);
else
    
end
Subjects = subjects_description.SubjID_sort(:);


regionfile={};

regionname={'VOI_rSN1mm_gPPI', 'VOI_probSNVTA_gPPI_test', 'VOI_dlPFC_NF_gPPI', 'VOI_dlPFC_NF_gPPI_pmod'};
%regionname={'VOI_SN_VTA_gPPI'};
models={'.rh'};

for indSubj=18:30%1:size(Subjects,1)
    try
        clear config
    catch
    end
    
    
    config.Subject=Subjects{indSubj};
    config.Study=Study_Dir;
    config.Subject_Subdirectory='/stats_mni_allruns_NFvaluesPmodDelta/';
    bool_pmod_analysis = 1;
    %    config.Model=''; % change for new model
    config.zip=0;
    
    regionfile={'/media/sf_Share_NeuroDebian/cofeed16/cofeed16/masks/rSN_1mm.nii', '/media/sf_Share_NeuroDebian/cofeed16/cofeed16/masks/rmask_probSNVTA.nii', '/media/sf_Share_NeuroDebian/masks_general/Mask_extracts/Masks_20180917/ROI_NF_dlPFC.nii', '/media/sf_Share_NeuroDebian/masks_general/Mask_extracts/Masks_20180917/ROI_NF_dlPFC.nii'};
    
    
    for jj=4:numel(regionfile)
        try
            Directory=[config.Study Subjects{indSubj} config.Subject_Subdirectory];
            cd(Directory)
            load('/media/sf_Share_NeuroDebian/cofeed16/cofeed16/batches/NF_VTA_MVPA/spm/PPI/parameters.mat');
            P.subject=Subjects{indSubj};
            P.directory=Directory;
            P.Tasks = {'1' 'BL' 'DOWN' 'UP'};
            
            P.VOI=regionfile{jj};
            P.Region=regionname{jj};
            %P.FSFAST=1;
            %P.FSFAST_source=[Study_Dir filesep Subjects{ii} filesep config.Subject_Subdirectory filesep 'SPMana' filesep config.Model models{3} filesep 'SPM.mat']; % subcortical iamge for ROI extraction
            P.wb=0; % may need to be changed to 0 on local computers
            P.concatR=0;
            
            
            P.Contrasts(1).left={'UP'};
            P.Contrasts(1).right={'none'};
            P.Contrasts(1).STAT='T';
            P.Contrasts(1).Weighted=0;
            P.Contrasts(1).MinEvents=1;
            P.Contrasts(1).name='UP_r1';
            P.Contrasts(1).Prefix='Sn(1)';
            
            P.Contrasts(2).left={'UP'};
            P.Contrasts(2).right={'none'};
            P.Contrasts(2).STAT='T';
            P.Contrasts(2).Weighted=0;
            P.Contrasts(2).MinEvents=1;
            P.Contrasts(2).name='UP_r2';
            P.Contrasts(2).Prefix='Sn(2)';
            
            P.Contrasts(3).left={'UP'};
            P.Contrasts(3).right={'none'};
            P.Contrasts(3).STAT='T';
            P.Contrasts(3).Weighted=0;
            P.Contrasts(3).MinEvents=1;
            P.Contrasts(3).name='UP_r3';
            P.Contrasts(3).Prefix='Sn(3)';
            
            P.Contrasts(4).left={'UP'};
            P.Contrasts(4).right={'none'};
            P.Contrasts(4).STAT='T';
            P.Contrasts(4).Weighted=0;
            P.Contrasts(4).MinEvents=1;
            P.Contrasts(4).name='UP_r4';
            P.Contrasts(4).Prefix='Sn(4)';
            
            P.Contrasts(5).left={'UP'};
            P.Contrasts(5).right={'none'};
            P.Contrasts(5).STAT='T';
            P.Contrasts(5).Weighted=0;
            P.Contrasts(5).MinEvents=1;
            P.Contrasts(5).name='UP_r5';
            P.Contrasts(5).Prefix='Sn(5)';
            
            P.Contrasts(6).left={'DOWN'};
            P.Contrasts(6).right={'none'};
            P.Contrasts(6).STAT='T';
            P.Contrasts(6).Weighted=0;
            P.Contrasts(6).MinEvents=1;
            P.Contrasts(6).name='DOWN_r1';
            P.Contrasts(6).Prefix='Sn(1)';
            
            P.Contrasts(7).left={'DOWN'};
            P.Contrasts(7).right={'none'};
            P.Contrasts(7).STAT='T';
            P.Contrasts(7).Weighted=0;
            P.Contrasts(7).MinEvents=1;
            P.Contrasts(7).name='DOWN_r2';
            P.Contrasts(7).Prefix='Sn(2)';
            
            P.Contrasts(8).left={'DOWN'};
            P.Contrasts(8).right={'none'};
            P.Contrasts(8).STAT='T';
            P.Contrasts(8).Weighted=0;
            P.Contrasts(8).MinEvents=1;
            P.Contrasts(8).name='DOWN_r3';
            P.Contrasts(8).Prefix='Sn(3)';
            
            P.Contrasts(9).left={'DOWN'};
            P.Contrasts(9).right={'none'};
            P.Contrasts(9).STAT='T';
            P.Contrasts(9).Weighted=0;
            P.Contrasts(9).MinEvents=1;
            P.Contrasts(9).name='DOWN_r4';
            P.Contrasts(9).Prefix='Sn(4)';
            
            P.Contrasts(10).left={'DOWN'};
            P.Contrasts(10).right={'none'};
            P.Contrasts(10).STAT='T';
            P.Contrasts(10).Weighted=0;
            P.Contrasts(10).MinEvents=1;
            P.Contrasts(10).name='DOWN_r5';
            P.Contrasts(10).Prefix='Sn(5)';
            
            P.Contrasts(11).left={'UP'};
            P.Contrasts(11).right={'DOWN'};
            P.Contrasts(11).STAT='T';
            P.Contrasts(11).Weighted=0;
            P.Contrasts(11).MinEvents=1;
            P.Contrasts(11).name='UP-DOWN_r1';
            P.Contrasts(11).Prefix='Sn(1)';
            
            P.Contrasts(12).left={'UP'};
            P.Contrasts(12).right={'DOWN'};
            P.Contrasts(12).STAT='T';
            P.Contrasts(12).Weighted=0;
            P.Contrasts(12).MinEvents=1;
            P.Contrasts(12).name='UP-DOWN_r2';
            P.Contrasts(12).Prefix='Sn(2)';
            
            P.Contrasts(13).left={'UP'};
            P.Contrasts(13).right={'DOWN'};
            P.Contrasts(13).STAT='T';
            P.Contrasts(13).Weighted=0;
            P.Contrasts(13).MinEvents=1;
            P.Contrasts(13).name='UP-DOWN_r3';
            P.Contrasts(13).Prefix='Sn(3)';
            
            P.Contrasts(14).left={'UP'};
            P.Contrasts(14).right={'DOWN'};
            P.Contrasts(14).STAT='T';
            P.Contrasts(14).Weighted=0;
            P.Contrasts(14).MinEvents=1;
            P.Contrasts(14).name='UP-DOWN_r4';
            P.Contrasts(14).Prefix='Sn(4)';
            
            P.Contrasts(15).left={'UP'};
            P.Contrasts(15).right={'DOWN'};
            P.Contrasts(15).STAT='T';
            P.Contrasts(15).Weighted=0;
            P.Contrasts(15).MinEvents=1;
            P.Contrasts(15).name='UP-DOWN_r5';
            P.Contrasts(15).Prefix='Sn(5)';
            if (1 == bool_pmod_analysis)
                P.Contrasts(16).left={'UPxFeedbackValues^1'};
                P.Contrasts(16).right={'none'};
                P.Contrasts(16).STAT='T';
                P.Contrasts(16).Weighted=0;
                P.Contrasts(16).MinEvents=1;
                P.Contrasts(16).name='UP_FB1';
                P.Contrasts(16).Prefix='Sn(1)';
                
                P.Contrasts(17).left={'UPxFeedbackValues^1'};
                P.Contrasts(17).right={'none'};
                P.Contrasts(17).STAT='T';
                P.Contrasts(17).Weighted=0;
                P.Contrasts(17).MinEvents=1;
                P.Contrasts(17).name='UP_FB2';
                P.Contrasts(17).Prefix='Sn(2)';
                
                P.Contrasts(18).left={'UPxFeedbackValues^1'};
                P.Contrasts(18).right={'none'};
                P.Contrasts(18).STAT='T';
                P.Contrasts(18).Weighted=0;
                P.Contrasts(18).MinEvents=1;
                P.Contrasts(18).name='UP_FB3';
                P.Contrasts(18).Prefix='Sn(3)';
                
                P.Contrasts(19).left={'UPxFeedbackValues^1'};
                P.Contrasts(19).right={'none'};
                P.Contrasts(19).STAT='T';
                P.Contrasts(19).Weighted=0;
                P.Contrasts(19).MinEvents=1;
                P.Contrasts(19).name='UP_FB4';
                P.Contrasts(19).Prefix='Sn(4)';
                
                P.Contrasts(20).left={'UPxFeedbackValues^1'};
                P.Contrasts(20).right={'none'};
                P.Contrasts(20).STAT='T';
                P.Contrasts(20).Weighted=0;
                P.Contrasts(20).MinEvents=1;
                P.Contrasts(20).name='UP_FB5';
                P.Contrasts(20).Prefix='Sn(5)';
                
                P.Contrasts(21).left={'DOWNxFeedbackValues^1'};
                P.Contrasts(21).right={'none'};
                P.Contrasts(21).STAT='T';
                P.Contrasts(21).Weighted=0;
                P.Contrasts(21).MinEvents=1;
                P.Contrasts(21).name='DOWN_FB1';
                P.Contrasts(21).Prefix='Sn(1)';
                
                P.Contrasts(22).left={'DOWNxFeedbackValues^1'};
                P.Contrasts(22).right={'none'};
                P.Contrasts(22).STAT='T';
                P.Contrasts(22).Weighted=0;
                P.Contrasts(22).MinEvents=1;
                P.Contrasts(22).name='DOWN_FB2';
                P.Contrasts(22).Prefix='Sn(2)';
                
                P.Contrasts(23).left={'DOWNxFeedbackValues^1'};
                P.Contrasts(23).right={'none'};
                P.Contrasts(23).STAT='T';
                P.Contrasts(23).Weighted=0;
                P.Contrasts(23).MinEvents=1;
                P.Contrasts(23).name='DOWN_FB3';
                P.Contrasts(23).Prefix='Sn(3)';
                
                P.Contrasts(24).left={'DOWNxFeedbackValues^1'};
                P.Contrasts(24).right={'none'};
                P.Contrasts(24).STAT='T';
                P.Contrasts(24).Weighted=0;
                P.Contrasts(24).MinEvents=1;
                P.Contrasts(24).name='DOWN_FB4';
                P.Contrasts(24).Prefix='Sn(4)';
                
                P.Contrasts(25).left={'DOWNxFeedbackValues^1'};
                P.Contrasts(25).right={'none'};
                P.Contrasts(25).STAT='T';
                P.Contrasts(25).Weighted=0;
                P.Contrasts(25).MinEvents=1;
                P.Contrasts(25).name='DOWN_FB5';
                P.Contrasts(25).Prefix='Sn(5)';
                
                P.Contrasts(26).left={'UPxFeedbackValues^1'};
                P.Contrasts(26).right={'DOWNxFeedbackValues^1'};
                P.Contrasts(26).STAT='T';
                P.Contrasts(26).Weighted=0;
                P.Contrasts(26).MinEvents=1;
                P.Contrasts(26).name='UP-DOWN_FB1';
                P.Contrasts(26).Prefix='Sn(1)';
                
                P.Contrasts(27).left={'UPxFeedbackValues^1'};
                P.Contrasts(27).right={'DOWNxFeedbackValues^1'};
                P.Contrasts(27).STAT='T';
                P.Contrasts(27).Weighted=0;
                P.Contrasts(27).MinEvents=1;
                P.Contrasts(27).name='UP-DOWN_FB2';
                P.Contrasts(27).Prefix='Sn(2)';
                
                P.Contrasts(28).left={'UPxFeedbackValues^1'};
                P.Contrasts(28).right={'DOWNxFeedbackValues^1'};
                P.Contrasts(28).STAT='T';
                P.Contrasts(28).Weighted=0;
                P.Contrasts(28).MinEvents=1;
                P.Contrasts(28).name='UP-DOWN_FB3';
                P.Contrasts(28).Prefix='Sn(3)';
               
                P.Contrasts(29).left={'UPxFeedbackValues^1'};
                P.Contrasts(29).right={'DOWNxFeedbackValues^1'};
                P.Contrasts(29).STAT='T';
                P.Contrasts(29).Weighted=0;
                P.Contrasts(29).MinEvents=1;
                P.Contrasts(29).name='UP-DOWN_FB4';
                P.Contrasts(29).Prefix='Sn(4)';
                
                P.Contrasts(30).left={'UPxFeedbackValues^1'};
                P.Contrasts(30).right={'DOWNxFeedbackValues^1'};
                P.Contrasts(30).STAT='T';
                P.Contrasts(30).Weighted=0;
                P.Contrasts(30).MinEvents=1;
                P.Contrasts(30).name='UP-DOWN_FB5';
                P.Contrasts(30).Prefix='Sn(5)';
            end
            
            save([Subjects{indSubj} '_PPI_config.mat'],'P');
            PPPI([Subjects{indSubj} '_PPI_config.mat'])
            spm('defaults','fMRI');
        catch
            disp(['Failed: ' Subjects{indSubj}])
        end
        %end
    end
    % You will want to zip the files here if P.zipfiles is not set to 1.
end

