#!/bin/bash

# Create folders and symbolic links to files
QAPATH='/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_QA'
cd $QAPATH
PREPROCPATH='/Volumes/JustData-1/Projects/DOPANF/Data/DOPANF_PREPROC'

for fd in `find . -iname 'sub-*' -type d -depth 1`; do for ff in `find $fd -iname '*' -type d -maxdepth 3`; do echo mkdir -p ../DOPANF_PREPROC/$ff;done;done|sh

for f in `find . -iname '[a-z|A-Z]*' -type f -depth 1`; do echo cp $f $PREPROCPATH/$f ;done|sh

for fd in `find . -iname 'sub-*' -type d -depth 1`; do for ff in `find $fd -iname '*' -type f`; do MYPATH=$(pwd); echo ln -s $MYPATH/$ff $PREPROCPATH/$ff;done;done|sh