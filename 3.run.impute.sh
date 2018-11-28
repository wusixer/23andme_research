#!/bin/bash -l
echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "Task index number : $SGE_TASK_ID"
echo "=========================================================="

#$-P addiction
#$-j y
#$-o qlog # NOTE: create qlog directory first before run the script 
#$-l h_rt=48:00:00
#$-N impute.chr  # let's call the job be this name, I thought it's quite explanatory
#$-t 1-22  #let's set up a batch job, each sub task takes care of one chromo.

module load python
module load impute

python impute2.py $SGE_TASK_ID


echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="
