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

SRC_SCRIPT="canneal_netlist.pl"
URL_SCRIPT="https://parsec.cs.princeton.edu/download/other/canneal_netlist.pl"
if [ ! -e $SRC_SCRIPT ]; then
    echo "Canneal gen script is missing. Downloading it now..."
    wget $URL_SCRIPT
    if [ $? -ne 0 ]; then
        echo "Error in downloading canneal gen script"
        exit
    fi
fi

chmod +x $SRC_SCRIPT
echo "Generating small dataset..."
./$SRC_SCRIPT 10000 11000 100000000 > canneal_small
#echo "Generating large dataset..."
