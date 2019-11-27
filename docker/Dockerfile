###############################################################################
# Docker Image Entry Point for the ASPLOS'20 Artifact Evaluation
#
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

FROM ubuntu:18.04
MAINTAINER Reto Achermann <reto.achermann@inf.ethz.ch>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    build-essential libncurses-dev \
    bison flex libssl-dev libelf-dev \
    libnuma-dev python3 python3 python3-pip \
    git wget pandoc fakeroot ccache \
    kernel-package python3-matplotlib python3-numpy 

COPY entrypoint.sh /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]