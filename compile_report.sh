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


function generate_plots {
    echo " > $1"

    pushd "$1" > /dev/null

    pushd "singlesocket" > /dev/null
    echo "   > Single Socket Benchmarks"
    python3 ./process_logs.py
    popd > /dev/null

    pushd "multisocket" > /dev/null
    echo "   > Multi Socket Benchmarks"
    python3 ./process_logs.py
    popd > /dev/null

    echo " > Generating Figure" 

    popd > /dev/null
}

pushd "$ROOT/evaluation" > /dev/null

echo "Generating Plots..."


generate_plots "reference"
generate_plots "measured"

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
pandoc -o artifact-evaluation.html artifact-evaluation.md

echo " > artifact-evaluation.pdf"
pandoc -o artifact-evaluation.pdf artifact-evaluation.md

popd > /dev/null

echo "Opening PDF."
xdg-open evaluation/artifact-evaluation.pdf
