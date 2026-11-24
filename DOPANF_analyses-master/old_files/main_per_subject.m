function main()
    %% SPECIFY SUBJECTS AND PROCESSING STEPS:
    subjIDs = {'SNS_RTTEST_ARB1DOPANF', 'SNS_RTTEST_ARB3DOPANF'}; % , 'SNS_RTTEST_ARB1DOPANF2', 'SNS_RTTEST_ARB1DOPANF3'}; % {'SNS_RTTEST_ARB1DOPANF', 'SNS_RTTEST_ARB2DOPANF', 'SNS_RTTEST_ARB3DOPANF'};       % 'SNS_RTTEST_ARB1DOPANF', 'SNS_RTTEST_ARB2DOPANF', 
    run_table_path = '\\lhnas.econ.uzh.ch\JustData\Projects\DOPANF\Piloting\DOPANF_BIDS\DOPANF\DOPANF_SequencesPerSubjectDescriptionExample.xlsx'; %'run_table.csv';
    %Base dir containing subject folders
    baseDir = '\\lhnas.econ.uzh.ch\JustData\Projects\DOPANF\Piloting\DOPANF_BIDS\DOPANF';
    
    global spmpath;
    spmpath = 'C:\Users\nwiedemann\Documents\MATLAB\spm12'; % >>which spm works, but cannot assign to variable, >>which(spm) opens UI and error
   
    % processing options
    % {'VDM', 'SLICETIME', 'REALIGN', 'SEGMENT', 'NORMALIZE', 'SMOOTH', 'PHYSIO'}
    processing_list = {'SLICETIME'}; %  {'VDM', 'SLICETIME', 'REALIGN'};
    
    tic; 
    parfor (indexSubj = 1:length(subjIDs), 3) % number of workers: 3
          doProcessingAD(subjIDs{indexSubj}, processing_list, baseDir, run_table_path);
    end
    disp(toc);
end