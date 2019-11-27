#! /bin/bash

###############################################################################
# Site Configuration file
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

ZENODO_DOI=10.5281/zenodo.3552960

# zenodo_get.py -w WGET  10.5281/zenodo.3552960

FILES=""

for f in $FILES; do
    echo "Downloading $f..."
    (cd precompiled && wget $f)
done
 