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
echo "Deployment of Binaries and Scripts to $URL"

REMOTE=$(echo $URL | cut -d ":" -f1)
DIRECTORY=$(echo $URL | cut -d ":" -f2)

echo "remote-host: $REMOTE"
echo "remote-directory: $DIRECTORY"

echo "create target directory"
ssh $REMOTE "mkdir -p $DIRECTORY/evaluation/measured"

echo "deploying files"
rsync -avz $ROOT/bin $ROOT/precompiled $ROOT/build $ROOT/datasets \
           $ROOT/scripts $URL
