Mitosis ASPLOS'20 Artifact Evaluation
=====================================

This repository contains scripts for the ASPLOS'20 artifact evaluation
of the paper **Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
for Large-Memory Machines** by Reto Achermann, Jayneel Gandhi, 
Timothy Roscoe, Abhishek Bhattacharjee, and Ashish Panwar.

The scripts in this paper can be used to reproduce the figures in the paper. 


Authors
-------
 
 * Reto Achermann (ETH Zurich)
 * Jayneel Gandhi (VMWware)
 * Timothy Roscoe (ETH Zurich)
 * Abhishek Bhattacharjee (Yale University)
 * Ashish Panwar (IISc Bangalore)


License
-------

See LICENSE file.


Directory Structure
-------------------

 * `/precompiled` contains the downloaded binaries
 * `/build` contains the locally compiled binaries
 * `/sources` contains the source code of the binaries


Hardware Dependencies
---------------------

Some of the workingset sizes of the workloads are hardcoded in the binaries.
To run them, you need to have a multi-socket machine with at least 128GB of 
memory *per* NUMA node. e.g. 4 socket Intel Xeon E7-4850v3 with 14 cores and 
128GB memory per-socket (512 GB total memory)


Software Dependencies
---------------------

The scripts, compilation and binaries are tested on Ubuntu 18.04 LTS. Other 
Linux distributions may work, but are not tested.

In addition to the packages shipped with Ubuntu 18.04 LTS the following 
packets are required:

```
sudo apt-get install build-essential libncurses-dev \
                     bison flex libssl-dev libelf-dev \
                     libnuma-dev python3 python3 python3-pip \
                     python3-matplotlib python3-numpy \
                     git wget
```                       

In addition the following python libraries, installed with pip

```
pip3 install zenodo-get

```


Obtaining Pre-Compiled Binaries
-------------------------------

This repository does not contain any source code or binaries. There are scripts
which download the pre-compiled binaries, or source code for compilation.

**Obtaining Pre-Compiled Binaries**

To obtain the pre-compiled binaries execute:

```
./download_binaries.sh
```
The pre-compiled binaries are available on (https://zenodo.org/)[Zenodo.org]. 
You can download them manually and place them in the `precompiled` directory. 


Obtaining Source Code and Compile
---------------------------------

If you don't want to compile from scratch, you can skip this section.

The source code for the Linux kernel and evaluated worloads are available on 
GitHub. To obtain the source code you can initialize the corresponding git 
submodules. **Note: the repositories are private at this moment**

```
git submodule init
git submodule update
```

To compile everything just type `make`

To compile the different binaries individually, type:

 * Mitosis Linux Kernel:  `make mitosis-linux`
 * Mitosis numactl: `make mitosis-numactl`
 * BTree: `make btree`
 * Canneal: `make canneal`
 * Graph500: `make graph500`
 * GUPS: `make gups`
 * HashJoin: `make hashjoin`
 * LibLinear: `make liblinear`
 * PageRank: `make pagerank`
 * Redis: `make redis`
 * XSBench: `make xsbench`
 * memops: `make memops`


Evaluation Preparation
----------------------

To run the evaluations of the paper, you need a suitable machine (see Hardware 
Dependencies) and you need to boot your machine with the Mitosis-Linux you
downloaded or compiled yourself. 

TODO: install the kernel module...


Running the Experiments
-----------------------

Before you start running the experiments, make sure you fill in the site
configuration file `site-config.sh`.

The process of running an experiment is as follows: the script will copy the
required binaries to the target machine, execute the workload and collect 
the results. This requires an SSH connection to the test machine.

To run all experiments, execute (this may take a while...)

```
./run_all.sh
```

To run the experiments for a single figure, do:

 * Figure 1 - `./run_f1.sh`
 * Figure 3 - `./run_f3.sh`
 * Figure 4 - `./run_f4.sh`
 * Figure 6 - `./run_f6.sh`
 * Figure 9 - `./run_f9.sh`
 * Figure 10 - `./run_f10.sh`
 * Figure 11 - `./run_f11.sh`
 * Table 5 - `./run_t5.sh`
 * Table 6 - `./run_t6.sh`


Compare the Experiments
-----------------------

When you collected all the experimental data, you can compare them against
the reference data shown in the paper:

```
./compare_all.sh
```


Paper Citation
--------------

TBD

