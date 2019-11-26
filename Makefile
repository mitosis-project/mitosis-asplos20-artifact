###############################################################################
# Makefile to build Binaries for the ASPLOS'20 Artifact Evaluation
#
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

all: mitosis-linux mitosis-numactl btree canneal graph500 \
     gups hashjoin liblinear pagerank redis xsbench memops

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

WDEPS=sources/mitosis-workloads/README.md

sources/mitosis-workloads/README.md:
	echo "initialized git submodules"
	git submodule init 
	git submodule update

###############################################################################
# BTree
###############################################################################

btree : $(WDEPS)

###############################################################################
# Canneal
###############################################################################

canneal : $(WDEPS)

###############################################################################
# Graph500
###############################################################################

graph500 : $(WDEPS)

###############################################################################
# Gups
###############################################################################

gups : $(WDEPS)

###############################################################################
# HashJoin
###############################################################################

hashjoin : $(WDEPS)

###############################################################################
# LibLinear
###############################################################################

liblinear : $(WDEPS)

###############################################################################
# PageRank
###############################################################################

pagerank : $(WDEPS)

###############################################################################
# Redis
###############################################################################

redis : $(WDEPS)

###############################################################################
# XSBench
###############################################################################

xsbench : $(WDEPS)

###############################################################################
# Memops
###############################################################################

memops: $(WDEPS)
