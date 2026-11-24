# scan_processing

Processing pipeline for MRI scans

Edit main to specify 
* List of subjects to process
* input paths to the table specifying run acquisition numbers and path to base directory with all subjects
* list of processing steps to execute

Main will do the segmentation for all subjects such that the processed T1 is available for further processing. Then it will call processSession.m for each subject-session pair. ProcessSession will construct a metainfo struct with file paths etc, and then call a batch script for each processing step, e.g. batch_slicetime.m. The processing steps will be collected in a matlabbatch and executed for each run.

### Timing tests

Tested on 3 subjects with 2 sessions each. Only executed slicetiming for each one, and each session had one run which was the same length for all of them. Results:

* Normal for loop: 277
* parfor over subjects (for loop over sessions): 176
* parfor over subject-session pairs: 120
