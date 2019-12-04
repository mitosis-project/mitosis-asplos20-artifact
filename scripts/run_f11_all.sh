#!/bin/bash

###############################################################################
# Script to run Figure 11 Evaluation of the paper
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

echo "************************************************************************"
echo "ASPLOS'20 - Artifact Evaluation - Mitosis - Figure 11"
echo "************************************************************************"

ROOT=$(dirname `readlink -f "$0"`)
#source $ROOT/site_config.sh

# List of all benchmarks to run
BENCHMARKS="gups redis xsbench"
# List of all configs to run
CONFIGS="FTLPLD FTRPILD FTRPILDM"

for bench in $BENCHMARKS; do
	for config in $CONFIGS; do
		echo "******************$bench : $config***********************"
		bash $ROOT/run_f11_one.sh $bench $config
	done
done
# --- process the output logs
$ROOT/process_logs_core.py --quiet
