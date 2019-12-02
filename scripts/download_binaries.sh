#! /bin/bash

set -e

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

ZENODO_DOI=10.5281/zenodo.3558908

echo "Downloading artifact from doi::$ZENODO_DOI"

pushd $ROOT/precompiled > /dev/null

if [[ ! -f artifactfiles.list ]]; then
    echo "> Downloading artifact list using zenodo_get"
    zenodo_get.py -w artifactfiles.list $ZENODO_DOI
else
    echo "> Reusing artifact list"
fi

FILES=$(cat artifactfiles.list)

for f in $FILES; do
    echo "Downloading $f..."
    wget $f
done

md5sum -c md5sums.txt
 
popd > /dev/null