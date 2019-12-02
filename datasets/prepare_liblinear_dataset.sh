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

ROOT=$(dirname `readlink -f "$0"`)

URL="wget https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/kdd12.bz2"
echo "Downloading kdd12..."
wget -c $URL -P $ROOT
echo "Download Completed."
echo "Extracting now. This may take a while..."
bunzip2 -f $ROOT/kdd12.bz2 > $ROOT/kdd12
