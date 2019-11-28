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
#echo "ASPLOS'20 - Artifact Evaluation - Mitosis - Figure 6&10"
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

	if [ $CURR_BENCH == "gups" ] || [ $CURR_BENCH == "btree" ] || [ $CURR_BENCH == "hashjoin" ] ||
		[ $CURR_BENCH == "redis" ] || [ $CURR_BENCH == "xsbench" ] || [ $CURR_BENCH == "pagerank" ] ||
		[ $CURR_BENCH == "liblinear" ] || [ $CURR_BENCH == "canneal" ]; then
		: #echo "Benchmark: $CURR_BENCH"
	else
		echo "Invalid benchmark: $CURR_BENCH"
		exit
	fi

	if [ $CURR_CONFIG == "LPLD" ] || [ $CURR_CONFIG == "LPRD" ] || [ $CURR_CONFIG == "LPRDI" ] ||
		[ $CURR_CONFIG == "RPLD" ] || [ $CURR_CONFIG == "RPILD" ] || [ $CURR_CONFIG == "RPRD" ] ||
		[ $CURR_CONFIG == "RPIRDI" ] || [ $CURR_CONFIG == "RPILDM" ]; then
		: #echo "Config: $CURR_CONFIG"
	else
		echo "Invalid config: $CURR_CONFIG"
		exit
	fi
}
validate_benchmark_config $BENCHMARK $CONFIG

prepare_benchmark_name()
{
	if [ $1 == "gups" ] || 	[ $1 == "btree" ] || [ $1 == "redis" ] || [ $1 == "hashjoin" ]; then
		POSTFIX="_st"
	else
		POSTFIX="_mt"
	fi
	PREFIX="bench_"
	BIN=$PREFIX
	BIN+=$BENCHMARK
	BIN+=$POSTFIX
}
prepare_benchmark_name $BENCHMARK


#***********************Workload-Parameters***********************
CPU_NODE=0
DATA_NODE=0
PT_NODE=0
MITOSIS=0

prepare_basic_config_params()
{
	CURR_CONFIG=$1
	# --- setup page table node
	if [ $CURR_CONFIG == "LPLD" ] || [ $CURR_CONFIG == "LPRD" ] || [ $CURR_CONFIG == "LPRDI" ]; then
		PT_NODE=0
	else
		PT_NODE=1
	fi

	# --- setup data node
	if [ $CURR_CONFIG == "LPLD" ] || [ $CURR_CONFIG == "RPLD" ] || [ $CURR_CONFIG == "RPILD" ]; then
		DATA_NODE=0
	else
		DATA_NODE=1
	fi

	# --- setup cpu node
		CPU_NODE=0

	# --- setup mitosis
	if [ $CURR_CONFIG == "RPILDM" ]; then
		PT_NODE=1
		DATA_NODE=0
		MITOSIS=1
	fi

	# --- setup interference node
	INT_NODE=1
}
prepare_basic_config_params $CONFIG
#echo "PTNODE:   $PT_NODE"
#echo "DATANODE: $DATA_NODE"
#echo "CPU_NODE: $CPU_NODE"

prepare_all_pathnames()
{
	SCRIPTS=$(readlink -f "`dirname $(readlink -f "$0")`")
	ROOT="$(dirname "$SCRIPTS")"
	BENCHPATH=$ROOT"/bin/$BIN"
	PERF=$ROOT"/bin/perf"
	INT_BIN=$ROOT"/bin/bench_stream"
	NUMACTL=$ROOT"/bin/numactl"
        if [ ! -e $BENCHPATH ]; then
            echo "Benchmark binary is missing"
            exit
        fi
        if [ ! -e $PERF]; then
            echo "Perf binary is missing"
            exit
        fi
        if [ ! -e $NUMACTL ]; then
            echo "numactl is missing"
            exit
        fi
        if [ ! -e $INT_BIN ]; then
            echo "Interference binary is missing"
            exit
        fi

	DATADIR=$ROOT"/data/singlesocket/figure4/$BENCHMARK"
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
prepare_all_pathnames

launch_interference()
{
	CURR_CONFIG=$1
	if [ $CURR_CONFIG == "LPRDI" ] || [ $CURR_CONFIG == "RPILD" ] || [ $CURR_CONFIG == "RPIRDI" ]; then
		$NUMACTL -c $INT_NODE -m $INT_NODE $INT_BIN > /dev/null 2>&1 &
		if [ $? -ne 0 ]; then
			echo "Failure launching interference"
			exit
		fi
	fi
}

launch_benchmark_config()
{
	# --- clean up exisiting state/processes
	rm /tmp/alloctest-bench.ready &>/dev/null
	rm /tmp/alloctest-bench.done &> /dev/null
	killall bench_stream &>/dev/null
	LAUNCH_CMD="$BENCHPATH -p $PT_NODE -d $DATA_NODE -r $CPU_NODE"
        echo $LAUNCH_CMD
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
