cd //lhnas.econ.uzh.ch/JustData/Projects/DOPANF/Data/DOPANF_QA

# T1
for f in `find ./sub-*/ -type f -name "*T1w.nii"`; do echo $f; echo tar -cvf $f.gz $f; rm $f;done|sh

# fieldmaps
for f in `find ./sub-*/ -type f -name "*1.nii"`; do  echo $f; echo tar -cvf $f.gz $f; rm $f;done|sh

for f in `find ./sub-*/ -type f -name "*2.nii"`; do  echo $f; echo tar -cvf $f.gz $f; rm $f;done|sh


# bold
for f in `find ./sub-*/ -type f -name "*bold.nii"`; do  echo $f; echo tar -cvf $f.gz $f; rm $f;done|sh

# physio
for f in `find ./sub-*/ -type f -name "*physio.tsv"`; do  echo $f; echo tar -cvf $f.gz $f; rm $f;done|sh