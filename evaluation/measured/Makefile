###############################################################################
# Makefile to build Binaries for the ASPLOS'20 Artifact Evaluation
#
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

all: figure01.png figure03.png figure04.png figure06.png \
	 figure09a.png figure09b.png figure10a.png figure10b.png \
	 figure11.png table5.png table6.png

%.png :
	cp ../template/nodata.png $@

clean: 
	rm -rf *.png *.pdf
