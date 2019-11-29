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

URL="wget https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/kdd12.bz2"
echo "Downloading kdd12..."
wget -c $URL
bunzip2 kdd12.bz2
