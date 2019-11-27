#! /bin/bash

###############################################################################
# Site Configuration file
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################


pushd evaluation > /dev/null

echo "Generating Report..."
pandoc -o artifact-evaluation.html artifact-evaluation.md
pandoc -o artifact-evaluation.pdf artifact-evaluation.md

popd > /dev/null

xdg-open evaluation/artifact-evaluation.pdf
