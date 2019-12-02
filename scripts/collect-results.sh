#! /bin/bash

###############################################################################
# Deployment of Binaries
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

SCRIPTROOT=$(dirname `readlink -f "$0"`)
ROOT=$(dirname `readlink -f "$SCRIPTROOT"`)

source $ROOT/scripts/site_config.sh

echo "########################################################################"
echo "ASPLOS'20 - Artifact Evaluation - Mitosis"
echo "########################################################################"
echo ""
echo "Collecting results form $URL"

REMOTE=$(echo $URL | cut -d ":" -f1)
DIRECTORY=$(echo $URL | cut -d ":" -f2)

rsync -avz $URL/evaluation/measured/* $ROOT/evaluation/measured/

