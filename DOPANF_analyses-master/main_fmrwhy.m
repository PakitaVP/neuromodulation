function main_fmrwhy()
    
   
    addpath('utils');
    current_OS = OS.WINDOWS;
    
    %Base dir containing subject folders
    baseDir = '';
    global spmpath;

    
    if ("MACOS" == current_OS)
        addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/bids-matlab'));
        spmpath = '/Users/lhellr/Documents/MATLAB/AdditionalStuff/spm12';
        addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/dicm2nii'));
        addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/raincloud_plot'));
        addpath(genpath('/Users/lhellr/Documents/MATLAB/AdditionalStuff/tapas'));
        addpath(genpath('/Volumes/JustData/Development/fMRwhy/fmrwhy'));
        settings_fn = '/Volumes/JustData/Development/DOPANF_analyses/fmrwhy_settings_DOPANF.m';
    elseif ("WINDOWS" == current_OS)
        addpath(genpath('C:\Users\lhellrung\Documents\MATLAB\Add-Ons\Toolboxes\bids-matlab'));
        addpath(genpath('C:\Users\lhellrung\Documents\MATLAB\Add-Ons\Toolboxes\dicm2nii'));
        addpath(genpath('C:\Users\lhellrung\Documents\MATLAB\Add-Ons\Toolboxes\raincloud_plot'));
        addpath(genpath('C:\Users\lhellrung\Documents\MATLAB\Add-Ons\Toolboxes\tapas'));
        addpath(genpath('C:\Development\fMRwhy\fmrwhy'));
        spmpath = 'C:\Users\lhellrung\Documents\MATLAB\Add-Ons\Toolboxes\spm12';
        settings_fn = 'C:\Development\DOPANF_analyses\fmrwhy_settings_DOPANF.m';
    end
    addpath(spmpath);

    
	tic;
    
    fmrwhy_workflow_qc(settings_fn)
    
    disp("Time for whole processing:");
    disp(toc);
end