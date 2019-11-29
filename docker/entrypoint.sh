#!/bin/bash

###############################################################################
# Docker Image Entry Point for the ASPLOS'20 Artifact Evaluation
#
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

cd /source

if [ "$1" == "" ]; then
    echo "Dropping into /bin/bash"
    exec "/bin/bash" 
else
    echo "Executing command: /bin/bash -c \"$@\"" 
    exec /bin/bash -c "$@"
fi