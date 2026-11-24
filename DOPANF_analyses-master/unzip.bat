cd //lhnas.econ.uzh.ch/JustData/Projects/DOPANF/Data/DOPANF_QA

# T1
for f in `find . -type f -name "*T1w.nii.gz"`; do echo gunzip $f; done|sh

# fieldmaps
 for f in `find . -type f -name "*1.nii.gz"`; do echo gunzip $f; done|sh

 for f in `find . -type f -name "*2.nii.gz"`; do echo gunzip $f; done|sh

# bold
for f in `find . -type f -name "*bold.nii.gz"`; do echo gunzip $f; done|sh
