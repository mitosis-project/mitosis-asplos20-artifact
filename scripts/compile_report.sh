#! /bin/bash

###############################################################################
# Site Configuration file
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

SCRIPTROOT=$(dirname `readlink -f "$0"`)
ROOT=$(dirname `readlink -f "$SCRIPTROOT"`)

FIGURESCIPTS=$ROOT/scripts/plotting/
LOGSCRIPT_F6F10=$ROOT/scripts/process_logs_f6f10.py

function generate_plots {
    echo " > $1"

    pushd "$1" > /dev/null

    echo " > Generating Plots" 

    echo "   > Figure 4"
    python3 $FIGURESCIPTS/figure4.py > /dev/null
    echo "   > Figure 6"
    python3 $FIGURESCIPTS/figure6.py > /dev/null
    # echo "   > Figure 9a"
    python3 $FIGURESCIPTS/figure9a.py > /dev/null
    # echo "   > Figure 9b"
    python3 $FIGURESCIPTS/figure9b.py > /dev/null
    echo "   > Figure 10a"
    python3 $FIGURESCIPTS/figure10a.py 
    echo "   > Figure 10b"
    python3 $FIGURESCIPTS/figure10b.py 
    echo "   > Table 5b"
    python3 $FIGURESCIPTS/table5.py 

    popd 
}

echo "Processing Logs.."

pushd "$ROOT/scripts" > /dev/null
python3 process_logs_fig_6-9-10.py
popd > /dev/null

echo "Generating Plots..."
pushd "$ROOT/evaluation" > /dev/null

generate_plots "reference"
generate_plots "measured"

# copy the no-data figures
pushd "$ROOT/evaluation" > /dev/null
make
popd > /dev/null


echo "Generating Reports..."
echo " > artifact-evaluation.html"
pandoc -o report/artifact-evaluation.html template/artifact-evaluation.md

echo " > artifact-evaluation.pdf"
pandoc -o report/artifact-evaluation.pdf template/artifact-evaluation.md

popd > /dev/null

echo "Opening PDF. evaluation/report/artifact-evaluation.pdf"
xdg-open $ROOT/evaluation/report/artifact-evaluation.pdf
