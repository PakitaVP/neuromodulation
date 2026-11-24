 classdef Configuration_renaming
    properties( Constant = true )
         nr_runs_TaskNF_session1 = 5
         nr_runs_TaskNF_session2 = 4
         nr_runs_TaskAdaptiveED = 3
         nr_runs_TaskNonAdpativeED = 2
         task_naming = {'EPI_NFTraining_Run1', 'EPI_NFTraining_Run2', 'EPI_NFTraining_Run3', 'EPI_NFTraining_Run4','EPI_NFTraining_Run5', 'EPI_NFTask_Run1', 'EPI_NFTask_Run2', 'EPI_NFTask_Run3', 'EPI_BLTask_Run1', 'EPI_BLTask_Run2'};
         
         fieldmap_naming = {'EPI_NFTraining_Fieldmap_Run1', 'EPI_NFTraining_Fieldmap_Run2', 'EPI_NFTraining_Fieldmap_Run3', 'EPI_NFTraining_Fieldmap_Run4','EPI_NFTraining_Fieldmap_Run5', 'EPI_NFTask_Fieldmap_Run1', 'EPI_NFTask_Fieldmap_Run2', 'EPI_NFTask_Fieldmap_Run3', 'EPI_BLTask_Fieldmap_Run1', 'EPI_BLTask_Fieldmap_Run2'};
         
         task_name_old = containers.Map({'NFTRAIN1','NFTRAIN2','NFTRAIN3', 'NFTRAIN4', 'NFTRAIN5', 'NFTASK1', 'NFTASK2', 'NFTASK3', 'BLTASK1', 'BLTASK2'},...
                                        {'_task-rt','_task-rt','_task-rt','_task-rt','_task-rt','_task-rt','_task-rt','_task-rt','_task-rt','_task-rt'})
         task_name_revised = containers.Map({'NFTRAIN1','NFTRAIN2','NFTRAIN3', 'NFTRAIN4', 'NFTRAIN5', 'NFTASK1', 'NFTASK2', 'NFTASK3', 'BLTASK1', 'BLTASK2'},...
                                            {'EPI_NFTraining_Run1', 'EPI_NFTraining_Run2', 'EPI_NFTraining_Run3', 'EPI_NFTraining_Run4','EPI_NFTraining_Run5', 'EPI_NFTask_Run1', 'EPI_NFTask_Run2', 'EPI_NFTask_Run3', 'EPI_BLTask_Run1', 'EPI_BLTask_Run2'})
         run_name_old = containers.Map({'NFTRAIN1','NFTRAIN2','NFTRAIN3', 'NFTRAIN4', 'NFTRAIN5', 'NFTASK1', 'NFTASK2', 'NFTASK3', 'BLTASK1', 'BLTASK2'},...
                                        {'_run-20','_run-20','_run-20','_run-20','_run-20','_run-20','_run-20','_run-20','_run-20','_run-20'})
                                        
                                        runs_per_task = containers.Map({'NFTRAINING_SESSION1','NFTRAINING_SESSION2','NFTASK','BLTASK'}, {5,4,3,2})
         paths = struct('input_bids', '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_BIDS',...
                        'copy_to', '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA',...
                        'manual_corrections', '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_CORRECTIONS',...
                        'input_bids_pc', 'Z:\Projects\DOPANF\Data\DOPANF_BIDS',...
                        'copy_to_pc', 'Z:\Projects\DOPANF\Data\DOPANF_QA',...
                        'manual_corrections_pc', 'Z:\Projects\DOPANF\Data\DOPANF_CORRECTIONS')
                    
         subjects_onsets_from_DecMakBL_edfs = {'30823', '31051', '31610', '35370', '38361', '40644', '41075', '47075', '44640', '45496', '46489', '46831', '46897', '46901', '47023'};
         subjects_fieldmaps_for_DecMakBL_missing = {'44052'};
         subjects_preproc_for_DecMakBL_missing = {'44052'};
    end
 end
 
 %'_task-rt'
 %'_run-20'