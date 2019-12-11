#!/bin/bash

###############################################################################
# Script to get kdd2012 public dataset for LibLinear
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

echo "************************************************************************"
echo "ASPLOS'20 - Artifact Evaluation - Mitosis - DATASET"
echo "************************************************************************"

# --- generate both datasets by default
GEN_SMALL=1
GEN_LARGE=1

if [ $# -eq 1 ]; then
	if [ $1 == "small" ]; then
		GEN_LARGE=0
	elif [ $1 == "large" ]; then
		GEN_SMALL=0
	fi
fi

ROOT=$(dirname `readlink -f "$0"`)
SRC_SCRIPT="$ROOT/canneal_netlist.pl"

URL_SCRIPT="https://parsec.cs.princeton.edu/download/other/canneal_netlist.pl"
if [ ! -e $SRC_SCRIPT ]; then
    echo "Canneal gen script is missing. Downloading it now..."
    wget $URL_SCRIPT -P $ROOT/
    if [ $? -ne 0 ]; then
        echo "Error in downloading canneal gen script"
        exit
    fi
fi

chmod +x $SRC_SCRIPT
if [ $GEN_SMALL -eq 1 ]; then
	if [ ! -e $ROOT/canneal_small ]; then
		echo "Generating small dataset for canneal. This will take a while..."
		$SRC_SCRIPT 10000 11000 100000000 > $ROOT/canneal_small
		echo "Dataset is ready now."
	else
		echo "Dataset found. Reusing the existing one."
	fi
fi
if [ $GEN_LARGE -eq 1 ]; then
	if [ ! -e $ROOT/canneal_large ]; then
		echo "Generating large dataset for canneal. This will take a while..."
		$SRC_SCRIPT 120000 11000 1200000000 > $ROOT/canneal_large
		echo "Dataset is ready now."
	fi
fi
