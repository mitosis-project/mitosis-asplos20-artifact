###############################################################################
# Makefile to build Binaries for the ASPLOS'20 Artifact Evaluation
#
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

all: mitosis-linux mitosis-linux.deb mitosis-numactl btree canneal \
	 graph500 gups hashjoin liblinear pagerank redis xsbench memops \
     memcached

linux: mitosis-linux mitosis-linux.deb mitosis-numactl

workloads: btree canneal graph500 gups hashjoin liblinear pagerank redis \
		   xsbench memops memcached

CC = gcc

NPROCS:=1
OS:=$(shell uname -s)

ifeq ($J,)
ifeq ($(OS),Linux)
  NPROCS := $(shell nproc)
else ifeq ($(OS),Darwin)
  NPROCS := $(shell system_profiler | awk '/Number of CPUs/ {print $$4}{next;}')
endif # $(OS)
else
	NPROCS := $J
endif 


###############################################################################
# Docker Image
###############################################################################

IMAGE=asplos20-mitosis-dockerimage
USER:=$(shell id -u)

docker-image : docker/Dockerfile
	docker build -t $(IMAGE) docker
	
docker-run:
	docker run -u $(USER) -i -t \
    --mount type=bind,source=$(CURDIR),target=/source \
    $(IMAGE)


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
	+$(MAKE) EXTRAVERSION=-mitosis ARCH=x86_64 CC=$(CC) \
		-C sources/mitosis-linux
	cp sources/mitosis-linux/arch/x86_64/boot/bzImage build
	cp sources/mitosis-linux/vmlinux build

mitosis-linux.deb: $(LDEPS) sources/mitosis-linux/.config
	(cd sources/mitosis-linux && \
		MAKEFLAGS= MFLAGS= CC=$(CC) fakeroot make-kpkg -j $(NPROCS) \
		--initrd --append-to-version=-mitosis kernel_image  kernel_headers)
	cp sources/*.deb build

mitosis-perf:
	+$(MAKE) EXTRAVERSION=-mitosis ARCH=x86_64 CC=$(CC) \
		-C sources/mitosis-linux/tools/perf
	cp sources/mitosis-linux/tools/perf/perf build


###############################################################################
# mitosis-numactl
###############################################################################

NDEPS=sources/mitosis-workloads/README.md

sources/mitosis-numactl/README.md :
	echo "initialized git submodules"
	git submodule init 
	git submodule update

sources/mitosis-numactl/configure:
	(cd sources/mitosis-numactl && ./autogen.sh)

sources/mitosis-numactl/Makefile: sources/mitosis-numactl/configure
	(cd sources/mitosis-numactl && ./configure)

mitosis-numactl: $(NDEPS) sources/mitosis-numactl/Makefile
	+$(MAKE) -C sources/mitosis-numactl 
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
	+$(MAKE) -C $(WORKLOADS) btree
	cp $(WORKLOADS)/bin/bench_btree_st build
	cp $(WORKLOADS)/bin/bench_btree_mt build
	cp $(WORKLOADS)/bin/bench_btree_dump build


###############################################################################
# Canneal
###############################################################################

canneal : $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) canneal
	cp $(WORKLOADS)/bin/bench_canneal_st build
	cp $(WORKLOADS)/bin/bench_canneal_mt build


###############################################################################
# Graph500
###############################################################################

graph500 : $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) graph500
	cp $(WORKLOADS)/bin/bench_graph500_mt build
	cp $(WORKLOADS)/bin/bench_graph500_st build


###############################################################################
# Gups
###############################################################################

gups : $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) gups
	cp $(WORKLOADS)/bin/bench_gups_st build
	cp $(WORKLOADS)/bin/bench_gups_toy build


###############################################################################
# HashJoin
###############################################################################

hashjoin : $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) hashjoin
	cp $(WORKLOADS)/bin/bench_hashjoin_st build
	cp $(WORKLOADS)/bin/bench_hashjoin_mt build
	cp $(WORKLOADS)/bin/bench_hashjoin_dump build


###############################################################################
# LibLinear
###############################################################################

liblinear : $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) liblinear
	cp $(WORKLOADS)/bin/bench_liblinear_mt build


###############################################################################
# PageRank
###############################################################################

pagerank : $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) pagerank
	cp $(WORKLOADS)/bin/bench_pagerank_mt build


###############################################################################
# Redis
###############################################################################

redis : $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) redis
	cp $(WORKLOADS)/bin/bench_redis_st build


###############################################################################
# XSBench
###############################################################################

xsbench : $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) xsbench
	cp $(WORKLOADS)/bin/bench_xsbench_mt build
	cp $(WORKLOADS)/bin/bench_xsbench_dump build
	

###############################################################################
# Memcached
###############################################################################

memcached : $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) memcached
	cp $(WORKLOADS)/bin/bench_memcached_mt build


###############################################################################
# Memops
###############################################################################

memops: $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) memops
	cp $(WORKLOADS)/bin/bench_memops build


###############################################################################
# Stream
###############################################################################

stream: $(WDEPS)
	+$(MAKE) -C $(WORKLOADS) stream
	cp $(WORKLOADS)/bin/bench_stream build
	cp $(WORKLOADS)/bin/bench_stream_numa build

###############################################################################
# Clean
###############################################################################

clean:
	+$(MAKE) -C $(WORKLOADS) clean

clean-workloads:
	+$(MAKE) -C $(WORKLOADS) clean
