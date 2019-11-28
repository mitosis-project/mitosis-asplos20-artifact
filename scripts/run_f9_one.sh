#!/bin/bash

###############################################################################
# Script to run Figure 6 Evaluation of the paper
# 
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

#echo "************************************************************************"
#echo "ASPLOS'20 - Artifact Evaluation - Mitosis - Figure 9"
#echo "************************************************************************"

#ROOT=$(dirname `readlink -f "$0"`)
#source $ROOT/site_config.sh

PERF_EVENTS=cycles,dTLB-loads,dTLB-load-misses,dTLB-stores,dTLB-store-misses,dtlb_load_misses.walk_duration,dtlb_store_misses.walk_duration

#***********************Script-Arguments***********************
if [ $# -ne 2 ]; then
	echo "Run as: $0 benchmark config"
	exit
fi

BENCHMARK=$1
CONFIG=$2

validate_benchmark_config()
{
	CURR_BENCH=$1
	CURR_CONFIG=$2

	if [ $CURR_BENCH == "memcached" ] || [ $CURR_BENCH == "xsbench" ] || [ $CURR_BENCH == "graph500" ] ||
		[ $CURR_BENCH == "hashjoin" ] || [ $CURR_BENCH == "btree" ] || [ $CURR_BENCH == "canneal" ]; then
		: #echo "Benchmark: $CURR_BENCH"
	else
		echo "Invalid benchmark: $CURR_BENCH"
		exit
	fi

	if [ $CURR_CONFIG == "F" ] || [ $CURR_CONFIG == "FM" ] || [ $CURR_CONFIG == "FA" ] ||
		[ $CURR_CONFIG == "FAM" ] || [ $CURR_CONFIG == "I" ] || [ $CURR_CONFIG == "IM" ]; then
		: #echo "Config: $CURR_CONFIG"
	else
		echo "Invalid config: $CURR_CONFIG"
		exit
	fi
}
validate_benchmark_config $BENCHMARK $CONFIG

prepare_benchmark_name()
{
	PREFIX="bench_"
        POSTFIX="_mt"
	BIN=$PREFIX
	BIN+=$BENCHMARK
	BIN+=$POSTFIX
}
prepare_benchmark_name $BENCHMARK


#***********************Workload-Parameters***********************
test_and_set_pathnames()
{
	SCRIPTS=$(readlink -f "`dirname $(readlink -f "$0")`")
	ROOT="$(dirname "$SCRIPTS")"
	BENCHPATH=$ROOT"/bin/$BIN"
	PERF=$ROOT"/bin/perf"
	NUMACTL=$ROOT"/bin/numactl"
        if [ ! -e $BENCHPATH ]; then
                echo "Benchmark binary is missing"
                exit
        fi
        if [ ! -e $PERF ]; then
                echo "Perf binary is missing"
                exit
        fi
        if [ ! -e $NUMACTL ]; then
                echo "numactl is missing"
                exit
        fi
	DATADIR=$ROOT"/data/singlesocket/figure9/$BENCHMARK"
        thp=$(cat /sys/kernel/mm/transparent_hugepage/enabled)
        thp=$(echo $thp | awk '{print $1}')
        if [ $thp != "[always]" ]; then
                RUNDIR=$DATADIR/$(hostname)-config-$CONFIG-$(date +"%Y%m%d-%H%M%S")
        else
                RUNDIR=$DATADIR/$(hostname)-config-$CONFIG-$thp-$(date +"%Y%m%d-%H%M%S")
        fi

	mkdir -p $RUNDIR
	OUTFILE=$RUNDIR/perflog-$BENCHMARK-$(hostname)-$CONFIG.dat
}
test_and_set_pathnames

test_and_set_configs()
{
        CURR_CONFIG=$1
        LASTCHAR="${CURR_CONFIG: -1}"
        MITOSIS=0
        if [ $LASTCHAR == "M" ]; then
            MITOSIS="1"
        fi

        if [ $CURR_CONFIG == "FA" ] || [ $CURR_CONFIG == "FAM" ]; then
                echo 1 | sudo tee /proc/sys/kernel/numa_balancing > /dev/null
                if [ $? -ne 0 ]; then
                        echo "Error enabling AutoNUMA"
                        exit
                fi
        else
                echo 0 | sudo tee /proc/sys/kernel/numa_balancing > /dev/null
                if [ $? -ne 0 ]; then
                        echo "Error disabling AutoNUMA"
                        exit
                fi
        fi

        # obtain the number of available nodes
        NODESTR=$(numactl --hardware | grep available)
        NODE_MAX=$(echo ${NODESTR##*: } | cut -d " " -f 1)
        NODE_MAX=`expr $NODE_MAX - 1`
        CMD_PREFIX=$NUMACTL
        if [ $CURR_CONFIG = "I" ] || [ $CURR_CONFIG = "IM" ]; then
                CMD_PREFIX+=" --interleaving=all "
        fi

        if [ $CURR_CONFIG = "FM" ] || [ $CURR_CONFIG = "FAM" ] || [ $CURR_CONFIG = "IM" ]; then
                CMD_PREFIX+=" --pgtablerepl=$NODE_MAX "
        fi    
}
test_and_set_configs $CONFIG
echo $CMD_PREFIX

launch_benchmark_config()
{
	# --- clean up exisiting state/processes
	rm /tmp/alloctest-bench.ready &>/dev/null
	rm /tmp/alloctest-bench.done &> /dev/null
	killall bench_stream &>/dev/null
	LAUNCH_CMD="$CMD_PREFIX $BENCHPATH"
        echo $LAUNCH_CMD
        exit
	echo $LAUNCH_CMD >> $OUTFILE
	echo "$BENCHMARK -p $PT_NODE -d $DATA_NODE -r $CPU_NODE"
	$LAUNCH_CMD > /dev/null 2>&1 &
	BENCHMARK_PID=$!
	echo -e "\e[0mWaiting for benchmark: $BENCHMARK_PID to be ready"
	while [ ! -f /tmp/alloctest-bench.ready ]; do
		sleep 0.1
	done
	SECONDS=0
	launch_interference $CONFIG
	$PERF stat -x, -o $OUTFILE --append -e $PERF_EVENTS -p $BENCHMARK_PID &
	PERF_PID=$!
	echo -e "\e[0mWaiting for benchmark to be done"
	while [ ! -f /tmp/alloctest-bench.done ]; do
		sleep 0.1
	done
	DURATION=$SECONDS
	kill -INT $PERF_PID &> /dev/null
	wait $PERF_PID
	wait $BENCHMARK_PID 2>/dev/null
	echo "Execution Time (seconds): $DURATION" >> $OUTFILE
	echo "****success****" >> $OUTFILE
	echo "$BENCHMARK : $CONFIG completed...\n"
	killall bench_stream &>/dev/null
}
launch_benchmark_config
