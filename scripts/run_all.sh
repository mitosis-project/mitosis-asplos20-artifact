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

ROOT=$(dirname `readlink -f "$0"`)

source $ROOT/site_config.sh

echo "========================================================================"
echo ">> ROOT = $ROOT"
echo ">> Target Machine = $MACHINE"
echo ">> Running ALL evaluations."
echo "========================================================================"


echo "========================================================================"
echo "Running Figure 6 Evaluation"
echo "========================================================================"

$ROOT/run_f6_all.sh

echo "========================================================================"
echo "Running Figure 9A Evaluation"
echo "========================================================================"

$ROOT/run_f9a_all.sh

echo "========================================================================"
echo "Running Figure 9B Evaluaton"
echo "========================================================================"

$ROOT/run_f9b_all.sh

echo "========================================================================"
echo "Running Figure 10A Evaluation"
echo "========================================================================"

$ROOT/run_f10a_all.sh

echo "========================================================================"
echo "Running Figure 10B Evaluation"
echo "========================================================================"

$ROOT/run_f10b_all.sh

echo "========================================================================"
echo "Running Figure 11 Evaluation"
echo "========================================================================"

$ROOT/run_f11_all.sh

echo "========================================================================"
echo "Running Table 5 Evaluation"
echo "========================================================================"

$ROOT/run_t5.sh

echo "========================================================================"
echo "Running Table 6 Evaluation"
echo "========================================================================"

$ROOT/run_t6.sh

echo "========================================================================"
echo ">> Done."
echo "========================================================================"
