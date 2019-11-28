#! /bin/bash

###############################################################################
# Site Configuration file
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

ROOT=$(dirname `readlink -f "$0"`)

FIGURESCIPTS=$ROOT/scripts/plotting/

function generate_plots {
    echo " > $1"

    pushd "$1" > /dev/null

    pushd "singlesocket" 
    echo "   > Single Socket Benchmarks"
    python3 ./process_logs.py > /dev/null
    popd 

    pushd "multisocket"
    echo "   > Multi Socket Benchmarks"
    python3 ./process_logs.py > /dev/null
    popd 

    echo " > Generating Plots" 

    echo "   > Figure 4"
    python3 $FIGURESCIPTS/figure4.py > /dev/null
    echo "   > Figure 6"
    python3 $FIGURESCIPTS/figure6.py > /dev/null
    echo "   > Figure 9a"
    python3 $FIGURESCIPTS/figure9a.py > /dev/null
    echo "   > Figure 9b"
    python3 $FIGURESCIPTS/figure9b.py > /dev/null
    echo "   > Figure 10a"
    python3 $FIGURESCIPTS/figure10a.py > /dev/null
    echo "   > Figure 10b"
    python3 $FIGURESCIPTS/figure10b.py > /dev/null

    popd 
}

pushd "$ROOT/evaluation" > /dev/null

echo "Generating Plots..."

generate_plots "reference"
#generate_plots "measured"

echo " > TODO!"
echo " > Figure 1"
echo " > Figure 3"
echo " > Figure 4"
echo " > Figure 6"
echo " > Figure 9"
echo " > Figure 10"
echo " > Figure 11"
echo " > Table 5"
echo " > Table 6"

echo "Generating Reports..."
echo " > artifact-evaluation.html"
pandoc -o report/artifact-evaluation.html template/artifact-evaluation.md

echo " > artifact-evaluation.pdf"
pandoc -o report/artifact-evaluation.pdf template/artifact-evaluation.md

popd > /dev/null

echo "Opening PDF. evaluation/report/artifact-evaluation.pdf"
xdg-open evaluation/report/artifact-evaluation.pdf
