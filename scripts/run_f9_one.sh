#!/bin/bash

###############################################################################
# Script to run Figure 9 Evaluation of the paper
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

#PERF_EVENTS=cycles,dTLB-loads,dTLB-load-misses,dTLB-stores,dTLB-store-misses,dtlb_load_misses.walk_duration,dtlb_store_misses.walk_duration
PERF_EVENTS=cycles,dTLB-loads,dTLB-load-misses,dTLB-stores,dTLB-store-misses,dtlb_load_misses.walk_duration,dtlb_store_misses.walk_duration,page_walker_loads.dtlb_l1,page_walker_loads.dtlb_l2,page_walker_loads.dtlb_l3,page_walker_loads.dtlb_memory,page_walker_loads.dtlb_l1,page_walker_loads.dtlb_l2,page_walker_loads.dtlb_l3,page_walker_loads.dtlb_memory,LLC-loads,LLC-load-misses,LLC-stores,LLC-store-misses
NR_PTCACHE_PAGES=1100000 # --- 2GB per socket
XSBENCH_ARGS=" -- -p 25000000 -g 920000 "
GRAPH500_ARGS=" -- -s 29 -e 21"
BENCH_ARGS=""


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
        FIRST_CHAR=${CURR_CONFIG:0:1}
        if [ $FIRST_CHAR == "T" ]; then
                CURR_CONFIG=${CURR_CONFIG:1}
        fi
	if [ $CURR_CONFIG == "F" ] || [ $CURR_CONFIG == "FM" ] || [ $CURR_CONFIG == "FA" ] ||
		[ $CURR_CONFIG == "FAM" ] || [ $CURR_CONFIG == "I" ] || [ $CURR_CONFIG == "IM" ]; then
		: #echo "Config: $CURR_CONFIG"
	else
		echo "Invalid config: $CURR_CONFIG"
		exit
	fi
}

prepare_benchmark_name()
{
	PREFIX="bench_"
        POSTFIX="_mt"
	BIN=$PREFIX
	BIN+=$BENCHMARK
	BIN+=$POSTFIX
}

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
	DATADIR=$ROOT"/evaluation/measured/figure9/$BENCHMARK"
        RUNDIR=$DATADIR/$(hostname)-config-$BENCHMARK-$CONFIG-$(date +"%Y%m%d-%H%M%S")
	mkdir -p $RUNDIR
        if [ $? -ne 0 ]; then
                echo "Error creating output directory: $RUNDIR"
        fi
	OUTFILE=$RUNDIR/perflog-$BENCHMARK-$(hostname)-$CONFIG.dat
}

test_and_set_configs()
{
        CURR_CONFIG=$1
        FIRST_CHAR=${CURR_CONFIG:0:1}
        thp="never"
        if [ $FIRST_CHAR == "T" ]; then
                thp="always"
        fi
        echo $thp | sudo tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null
        if [ $? -ne 0 ]; then
                echo  "ERROR setting thp to: $thp"
                exit
        fi
        echo $thp | sudo tee /sys/kernel/mm/transparent_hugepage/defrag > /dev/null
        if [ $? -ne 0 ]; then
                echo "ERROR setting thp to: $thp"
                exit
        fi

        AUTONUMA="0"
        if [ $CURR_CONFIG == "FA" ] || [ $CURR_CONFIG == "FAM" ] || [ $CURR_CONFIG == "TFA" ] || [ $CURR_CONFIG == "TFAM" ]; then
                AUTONUMA="1"
        fi
        echo $AUTONUMA | sudo tee /proc/sys/kernel/numa_balancing > /dev/null
        if [ $? -ne 0 ]; then
                echo "ERROR setting AutoNUMA to: $AUTONUMA"
                exit
        fi
        # obtain the number of available nodes
        NODESTR=$(numactl --hardware | grep available)
        NODE_MAX=$(echo ${NODESTR##*: } | cut -d " " -f 1)
        NODE_MAX=`expr $NODE_MAX - 1`
        CMD_PREFIX=$NUMACTL

        # --- check interleaving
        if [ $CURR_CONFIG == "I" ] || [ $CURR_CONFIG == "IM" ] || [ $CURR_CONFIG == "TI" ] || [ $CURR_CONFIG == "TIM" ]; then
                CMD_PREFIX+=" --interleave=$NODE_MAX"
        fi

        # --- check page table replication
        LAST_CHAR="${CURR_CONFIG: -1}"
        if [ $LAST_CHAR == "M" ]; then
                CMD_PREFIX+=" --pgtablerepl=$NODE_MAX "
                echo 0 | sudo tee /proc/sys/kernel/pgtable_replication > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication to $0"
                        exit
                fi
                # --- drain first then reserve
                echo -1 | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication_cache to $0"
                        exit
                fi
                echo $NR_PTCACHE_PAGES | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication_cache to $NR_PTCACHE_PAGES"
                        exit
                fi
        else
                # --- enable default page table allocation
                echo -1 | sudo tee /proc/sys/kernel/pgtable_replication > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication to -1"
                        exit
                fi
                # --- drain page table cache
                echo -1 | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication to 0"
                        exit
                fi
        fi

        if [ $BENCHMARK == "xsbench" ]; then
                BENCH_ARGS=$XSBENCH_ARGS
        elif [ $BENCHMARK == "graph500" ]; then
                BENCH_ARGS=$GRAPH500_ARGS
        fi

}

prepare_datasets()
{
	SCRIPTS=$(readlink -f "`dirname $(readlink -f "$0")`")
        ROOT="$(dirname "$SCRIPTS")"
	# --- only for canneal and liblinear
	if [ $1 == "canneal" ]; then
		$ROOT/datasets/prepare_canneal_datasets.sh large
	fi
}

launch_benchmark_config()
{
	# --- clean up exisiting state/processes
	rm /tmp/alloctest-bench.ready &>/dev/null
	rm /tmp/alloctest-bench.done &> /dev/null
	killall bench_stream &>/dev/null
	LAUNCH_CMD="$CMD_PREFIX $BENCHPATH $BENCH_ARGS"
	echo $LAUNCH_CMD >> $OUTFILE
	$LAUNCH_CMD > /dev/null 2>&1 &
	BENCHMARK_PID=$!
	echo -e "\e[0mWaiting for benchmark: $BENCHMARK_PID to be ready"
	while [ ! -f /tmp/alloctest-bench.ready ]; do
		sleep 0.1
	done
	SECONDS=0
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
	echo "$BENCHMARK : $CONFIG completed."
        echo ""
	killall bench_stream &>/dev/null
}

# --- prepare the setup
validate_benchmark_config $BENCHMARK $CONFIG
prepare_benchmark_name $BENCHMARK
test_and_set_pathnames
test_and_set_configs $CONFIG
prepare_datasets $BENCHMARK
# --- finally, launch the job
launch_benchmark_config
