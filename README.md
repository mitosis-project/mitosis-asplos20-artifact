Mitosis ASPLOS'20 Artifact Evaluation
=====================================

This repository contains scripts for the ASPLOS'20 artifact evaluation
of the paper **Mitosis: Transparently Self-Replicating Page-Tables 
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

 * `precompiled` contains the downloaded binaries
 * `build` contains the locally compiled binaries
 * `sources` contains the source code of the binaries
 * `datasets` contains the datasets required for the binaries
 * `scripts` contains scripts to run the experiments
 * `bin` points to the used binaries for the evaluation (you can use 
   `scripts/toggle_build.sh` to switch between precompiled and locally 
   compined binaries)


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
                     git wget kernel-package fakeroot ccache \
                     libncurses5-dev wget pandoc libevent-dev \
                     libreadline-dev python3-setuptools
```                       

In addition the following python libraries, installed with pip

```
pip3 install wheel
pip3 install zenodo-get

```

**Docker** There is a docker image which you can use to compile. You can do
`make docker-shell` to obtain a shell in the docker container, or just to 
compile everything type `make docker-compile`.


Obtaining Pre-Compiled Binaries
-------------------------------

This repository does not contain any source code or binaries. There are scripts
which download the pre-compiled binaries, or source code for compilation.

**Obtaining Pre-Compiled Binaries**

To obtain the pre-compiled binaries execute:

```
./scripts/download_binaries.sh
```
The pre-compiled binaries are available on [Zenodo.org](https://zenodo.org/record/3558908). 
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
 * memcached: `make memcached`


Evaluation Preparation
----------------------

To run the evaluations of the paper, you need a suitable machine (see Hardware 
Dependencies) and you need to boot your machine with the Mitosis-Linux you
downloaded or compiled yourself. Both, the kernel image and the headers!.

To install the kernel module for page-table dumping you need to execute:
```
make install lkml
```

It's best to compile it on the machine runnig Mitosis-Linux. 
```
make mitosis-page-table-dump
```
Deploying
---------

To deploy the binaries and scripts, just clone the repository on the target 
machine. Or you can set your target host-name and directory in 
`./scripts/site_config.sh`

```
./scripts/deploy.sh
```

Preparing Datasets
------------------

Some workloads require datasets to run. Scripts to download or generate the datasets
are placed in `datasets/`. These datasets require approximately 100GB of disk space.
Generate datasets as:

```
datasets/prepare_liblinear_dataset.sh
datasets/prepare_canneal_datasets.sh
```


Running the Experiments
-----------------------

Before you start running the experiments, make sure you fill in the site
configuration file `site-config.sh`.

To run all experiments, execute (this may take a while...)

```
scripts/run_all.sh
```

To run the experiments for a single figure, do:

 * Figure 6 - `./scripts/run_f6_all.sh`
 * Figure 9a - `./scripts/run_f9a_all.sh`
 * Figure 9b - `./scripts/run_f9b_all.sh`
 * Figure 10a - `./scripts/run_10a_all.sh`
 * Figure 10b - `./scripts/run_10b_all.sh`
 * Figure 11 - `./scripts/run_f11.sh`
 * Table 5 - `./scripts/run_t5.sh`

You can also execute each bar of Figure-6, Figure-9 and Figure-10 separately.
For Figure-6 and Figure-10, execute as:

```
./scripts/run_f6f10_one.sh BENCHMARK CONFIG
```
For Figure-9, execute as:

```
./scripts/run_f9_one.sh BENCHMARK CONFIG`
```

Naming conventions for arguments:

 * Use "small letters" for benchmark name (e.g., btree, xsbench).
 * Use "CAPITAL LETTERS" for configuration name (e.g., TLPLD, RPILDM).

Refer to `./scripts/run_f6_all.sh` and `./scripts/run_f10a_all.sh` for more examples on how to
execute a single benchmark configuration.

All output logs will be redirected to "evaluation/measured/$FIGURENUM".

To process the logs for Figure-6, Figure-9 and Figure-10, execute:

```
./scripts/process_logs_fig_6-9-10.py`
```

Collecting Experiment Data
--------------------------

In case you used the deploy script, you can execute
```
./scripts/collect-results.sh
```
To copy the results from the remote machine to your local one.

Compare the Experiments
-----------------------

When you collected all the experimental data, you can compare them against
the reference data shown in the paper:

```
./scripts/compile_report.sh
```


Paper Citation
--------------

TBD

