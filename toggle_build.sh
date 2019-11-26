#!/bin/bash

###############################################################################
# Script to run all evaluations of the paper
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

echo "########################################################################"
echo "ASPLOS'20 - Artifact Evaluation - Mitosis"
echo "########################################################################"
echo ""
echo "Binary Selector"

ROOT=$(dirname `readlink -f "$0"`)

BINDIRECTORY=$(readlink $ROOT/bin)
BINDIR=$(basename $BINDIRECTORY)

if [[ "$BINDIR" == "build" ]]; then
	echo "Using locally compiled binaries"
	rm -f $ROOT/bin
	ln -s $ROOT/precompiled $ROOT/bin
	exit 0
fi

if [[ "$BINDIR" == "precompiled" ]]; then
	echo "Using pre-compiled binaries"
	rm -f $ROOT/bin
	ln -s $ROOT/build $ROOT/bin
fi
