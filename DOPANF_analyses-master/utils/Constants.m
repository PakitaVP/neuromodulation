 classdef Constants
    properties( Constant = true )
         nr_runs_TaskNF_session1 = 5
         nr_runs_TaskNF_session2 = 4
         nr_runs_TaskAdaptiveED = 3
         nr_runs_TaskNonAdpativeED = 2
         task_naming = {'EPI_NFTraining_Run1', 'EPI_NFTraining_Run2', 'EPI_NFTraining_Run3', 'EPI_NFTraining_Run4','EPI_NFTraining_Run5', 'EPI_NFTask_Run1', 'EPI_NFTask_Run2', 'EPI_NFTask_Run3', 'EPI_BLTask_Run1', 'EPI_BLTask_Run2'};
         runs_per_task = containers.Map({'NFTRAINING_SESSION1','NFTRAINING_SESSION2','NFTASK','BLTASK'}, {5,4,3,2})
    end
 end