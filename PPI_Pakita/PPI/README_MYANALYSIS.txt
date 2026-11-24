PPI Analysis

1) PPPI_FSFAST_WRAPPER.m
check paths of first levels
choose seed region
check output paths
This is using SPM8 by definition (called within the script)

2) If needed, do imcalcs
for allruns or r4-r1, choose PPI_imcalc_* file and run it
also here, check input path and seed for analysis aimed for

3) Second Level stats
Start SPM12 first!!!!
Otherwise contrast manager will crash
second_level_PPI_batch_onesample_mergedatasets.m 
for cofeed & cojames data with t-test including DOFL if chosen