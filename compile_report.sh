#! /bin/bash

###############################################################################
# Site Configuration file
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################


echo "Generating Plots..."
echo " > TODO!"

pushd evaluation > /dev/null

echo "Generating Reports..."
echo " > artifact-evaluation.html"
pandoc -o artifact-evaluation.html artifact-evaluation.md

echo " > artifact-evaluation.pdf"
pandoc -o artifact-evaluation.pdf artifact-evaluation.md

popd > /dev/null

echo "Opening PDF."
xdg-open evaluation/artifact-evaluation.pdf
