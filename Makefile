###############################################################################
# Makefile to build Binaries for the ASPLOS'20 Artifact Evaluation
#
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

all: mitosis-linux mitosis-numactl btree canneal graph500 \
     gups hashjoin liblinear pagerank redis xsbench memops \
     memcached

CC = gcc-8

###############################################################################
# mitosis-linux
###############################################################################

LDEPS=sources/mitosis-linux/README

sources/mitosis-linux/README:
	echo "initialized git submodules"
	git submodule init 
	git submodule update

sources/mitosis-linux/.config: $(LDEPS) sources/mitosis-linux.config
	cp sources/mitosis-linux.config sources/mitosis-linux/.config

mitosis-linux: $(LDEPS) sources/mitosis-linux/.config 
	+make CC=$(CC) -C sources/mitosis-linux
	cp sources/mitosis-linux/arch/x86_64/boot/bzImage build
	cp sources/mitosis-linux/vmlinux build
	echo $(MAKEFLAGS)
	echo $(MFLAGS)
	(cd sources/mitosis-linux && \
		MAKEFLAGS= MFLAGS= CC=$(CC) fakeroot make-kpkg --initrd --append-to-version=-mitosis kernel_image  kernel_headers)
	cp sources/*.deb build

###############################################################################
# mitosis-numactl
###############################################################################

NDEPS=sources/mitosis-workloads/README.md

sources/mitosis-numactl/README.md:
	echo "initialized git submodules"
	git submodule init 
	git submodule update

sources/mitosis-numactl/configure:
	(cd sources/mitosis-numactl && ./autogen.sh)

sources/mitosis-numactl/Makefile: sources/mitosis-numactl/configure
	(cd sources/mitosis-numactl && ./configure)

mitosis-numactl: $(NDEPS)sources/mitosis-numactl/Makefile
	+make -C sources/mitosis-numactl 
	cp sources/mitosis-numactl/.libs/libnuma.la build
	cp sources/mitosis-numactl/.libs/libnuma.so* build
	cp sources/mitosis-numactl/.libs/numactl build


###############################################################################
# Workloads
###############################################################################

WORKLOADS=sources/mitosis-workloads
WDEPS=sources/mitosis-workloads/README.md

sources/mitosis-workloads/README.md:
	echo "initialized git submodules"
	git submodule init 
	git submodule update


###############################################################################
# BTree
###############################################################################

btree : $(WDEPS)
	+make -C $(WORKLOADS) btree
	cp $(WORKLOADS)/bin/bench_btree_st build
	cp $(WORKLOADS)/bin/bench_btree_mt build
	cp $(WORKLOADS)/bin/bench_btree_dump build


###############################################################################
# Canneal
###############################################################################

canneal : $(WDEPS)
	+make -C $(WORKLOADS) canneal
	cp $(WORKLOADS)/bin/bench_canneal_st build
	cp $(WORKLOADS)/bin/bench_canneal_dump build
	cp $(WORKLOADS)/bin/bench_canneal_mt build


###############################################################################
# Graph500
###############################################################################

graph500 : $(WDEPS)
	+make -C $(WORKLOADS) graph500
	cp $(WORKLOADS)/bin/bench_graph500_mt build
	cp $(WORKLOADS)/bin/bench_graph500_st build


###############################################################################
# Gups
###############################################################################

gups : $(WDEPS)
	+make -C $(WORKLOADS) gups
	cp $(WORKLOADS)/bin/bench_gups_st build


###############################################################################
# HashJoin
###############################################################################

hashjoin : $(WDEPS)
	+make -C $(WORKLOADS) hashjoin
	cp $(WORKLOADS)/bin/bench_hashjoin_st build
	cp $(WORKLOADS)/bin/bench_hashjoin_mt build
	cp $(WORKLOADS)/bin/bench_hashjoin_dump build


###############################################################################
# LibLinear
###############################################################################

liblinear : $(WDEPS)
	+make -C $(WORKLOADS) liblinear
	cp $(WORKLOADS)/bin/bench_liblinear_st build


###############################################################################
# PageRank
###############################################################################

pagerank : $(WDEPS)
	+make -C $(WORKLOADS) pagerank
	cp $(WORKLOADS)/bin/bench_pagerank_st build


###############################################################################
# Redis
###############################################################################

redis : $(WDEPS)
	+make -C $(WORKLOADS) redis
	cp $(WORKLOADS)/bin/bench_redis_st build


###############################################################################
# XSBench
###############################################################################

xsbench : $(WDEPS)
	+make -C $(WORKLOADS) xsbench
	cp $(WORKLOADS)/bin/bench_xsbench_mt build
	cp $(WORKLOADS)/bin/bench_xsbench_dump build
	

###############################################################################
# Memcached
###############################################################################

memcached : $(WDEPS)
	+make -C $(WORKLOADS) memcached
	cp $(WORKLOADS)/bin/bench_memcached_mt build


###############################################################################
# Memops
###############################################################################

memops: $(WDEPS)
	+make -C $(WORKLOADS) memops
	cp $(WORKLOADS)/bin/bench_memops build
