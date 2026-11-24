cd //lhnas.econ.uzh.ch/JustData/Projects/DOPANF/Data/DOPANF_QA

# T1
for f in `find ./sub-*/ -type f -name "*T1w.nii.gz"`; do echo $f; echo gunzip $f; done|sh

# fieldmaps
 for f in `find ./sub-*/ -type f -name "*1.nii.gz"`; do echo $f; echo gunzip $f; done|sh

 for f in `find ./sub-*/ -type f -name "*2.nii.gz"`; do echo $f; echo gunzip $f; done|sh

# bold
for f in `find ./sub-*/ -type f -name "*bold.nii.gz"`; do echo $f; echo gunzip $f; done|sh

# physio
for f in `find ./sub-*/ -type f -name "*tsv.gz"`; do echo $f; echo gunzip $f; done|sh
