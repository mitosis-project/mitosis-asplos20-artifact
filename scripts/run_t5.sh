#!/bin/bash

#!/bin/bash

###############################################################################
# Script to run Figure 6 Evaluation of the paper
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

echo "************************************************************************"
echo "ASPLOS'20 - Artifact Evaluation - Mitosis - Table 5"
echo "************************************************************************"

ROOT=$(dirname `readlink -f "$0../"`)

NUMACTL="$ROOT/bin/numactl"
BENCHMARK="$ROOT/bin/bench_memops"
OUTFILE="$ROOT/evaluation/measured/table5/table5_absolute.csv"

NODESTR=$(numactl --hardware | grep available)
NODE_MAX=$(echo ${NODESTR##*: } | cut -d " " -f 1)
NODE_MAX=`expr $NODE_MAX - 1`

for NPAGES in 1 2048 1048576; do
  for THP in never always; do
      echo $THP | sudo tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null
      sudo mount -o remount,huge=$THP /dev/shm
      for MITOSIS in ON OFF; do

          OPTMIT=""
          ARGMIT=""
          if [ "$MITOSIS" == "ON" ]; then
              OPTMIT="--pgtablerepl=0-$NODE_MAX"
              ARGMIT="-m"
          fi

          ARGTHP=""
          if [ "$THP" == "always" ]; then
              ARGTHP="-l"
          fi

          $NUMACTL $OPTMIT -N 0 -m 0 -- $BENCHMARK $ARGMIT -s $NPAGES $ARGTHP >> $OUTFILE
      done
  done
done
