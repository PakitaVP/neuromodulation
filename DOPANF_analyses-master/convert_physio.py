import os
import shutil
import glob
import matplotlib.pyplot as plt
import numpy as np
import nibabel as nib

from scanphyslog2bids.core import PhilipsPhysioLog

log_file = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc/sub-45496/ses-1/func/sub-45496_ses-1_task-NFTraining_run-5_physio.log'
out_dir = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc/sub-45496/ses-1/func'  # where the BIDSified data should be saved

# fmri_file is used to extract metadata, such as TR and number of volumes
fmri_file = '/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA/derivatives/fmrwhy-preproc/sub-45496/ses-1/func/sub-45496_ses-1_task-NFTraining_run-5_bold.nii' 
fmri_img = nib.load(fmri_file)
n_dyns = fmri_img.shape[-1]
tr = np.round(fmri_img.header['pixdim'][4], 3)

# Create PhilipsPhysioLog object with info
phlog = PhilipsPhysioLog(f=log_file, tr=tr, n_dyns=n_dyns, sf=500, manually_stopped=False)

# Load in data, do some preprocessing
phlog.load()

# Try to align physio data with scan data, using a particular method
# (either "vol_markers", "gradient_log", or "interpolation")
phlog.align(trigger_method='gradient_log')  # load and find vol triggers

# Write out BIDS files
phlog.to_bids(out_dir)  # writes out .tsv.gz and .json files