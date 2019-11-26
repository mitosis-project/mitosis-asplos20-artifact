###############################################################################
# Makefile to build Binaries for the ASPLOS'20 Artifact Evaluation
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

all: mitosis-linux mitosis-numactl btree canneal graph500 \
     gups hashjoin liblinear pagerank redis xsbench memops


###############################################################################
# Submodules
###############################################################################

gitsubmodules:
	git submodule init 
	git submodule update

###############################################################################
# mitosis-linux
###############################################################################

sources/mitosis-linux/README: gitsubmodules
	echo "initialized git submodules"

sources/mitosis-linux/.config: sources/mitosis-linux.config
	cp sources/mitosis-linux.config sources/mitosis-linux/.config

mitosis-linux: sources/mitosis-linux/.config sources/mitosis-linux/README
	+make CC=gcc-8 -C sources/mitosis-linux
	(cd sources/mitosis-linux \
		&& fakeroot make-kpkg --initrd kernel_image kernel_headers)

###############################################################################
# mitosis-numactl
###############################################################################

sources/mitosis-numactl/README.md: gitsubmodules
	echo "initialized git submodules"

sources/mitosis-numactl/configure:
	(cd sources/mitosis-numactl && ./autogen.sh)

sources/mitosis-numactl/Makefile: sources/mitosis-numactl/configure
	(cd sources/mitosis-numactl && ./configure)

mitosis-numactl: sources/mitosis-numactl/Makefile sources/mitosis-numactl/README.md
	+make -C sources/mitosis-numactl 
	cp sources/mitosis-numactl/.libs/libnuma.la build
	cp sources/mitosis-numactl/.libs/libnuma.so* build
	cp sources/mitosis-numactl/.libs/numactl build


###############################################################################
# Workloads
###############################################################################

sources/mitosis-workloads/README.md: gitsubmodules
	echo "initialized git submodules"

###############################################################################
# BTree
###############################################################################

btree :

###############################################################################
# Canneal
###############################################################################

canneal :

###############################################################################
# Graph500
###############################################################################

graph500 :

###############################################################################
# Gups
###############################################################################

gups :

###############################################################################
# HashJoin
###############################################################################

hashjoin :

###############################################################################
# LibLinear
###############################################################################

liblinear :

###############################################################################
# PageRank
###############################################################################

pagerank :

###############################################################################
# Redis
###############################################################################

redis :

###############################################################################
# XSBench
###############################################################################

xsbench :

memops`:
