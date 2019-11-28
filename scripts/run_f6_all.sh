#!/bin/bash

###############################################################################
# Script to run Figure 6 Evaluation of the paper
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

echo "************************************************************************"
echo "ASPLOS'20 - Artifact Evaluation - Mitosis - Figure 6"
echo "************************************************************************"

#ROOT=$(dirname `readlink -f "$0"`)
#source $ROOT/site_config.sh

THP="never"
configure_thp()
{
        echo $THP | sudo tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null
        if [ $? -ne 0 ]; then
                echo "Error disabling THP"
                exit
        fi
        echo $THP | sudo tee /sys/kernel/mm/transparent_hugepage/defrag > /dev/null
        if [ $? -ne 0 ]; then
                echo "Error disabling THP"
                exit
        fi
}
configure_thp

# List of all benchmarks to run
BENCHMARKS="pagerank"
# List of all configs to run
#CONFIGS="LPLD LPRD LPRDI RPLD RPILD RPRD RPIRDI"
CONFIGS="LPLD"

for bench in $BENCHMARKS; do
	for config in $CONFIGS; do
		echo "******************$bench: $config***********************"
		bash run_f6f10_one.sh $bench $config
	done
done
