###############################################################################
# Makefile to build Binaries for the ASPLOS'20 Artifact Evaluation
#
# Paper: Mitosis - Mitosis: Transparently Self-Replicating Page-Tables 
#                  for Large-Memory Machines
# Authors: Reto Achermann, Jayneel Gandhi, Timothy Roscoe, 
#          Abhishek Bhattacharjee, and Ashish Panwar
###############################################################################

plots: plots-measured plots-reference


plots-measured:
	+$(MAKE) -C measured

plots-reference:
	+$(MAKE) -C reference

clean-measured:
	+$(MAKE) -C measured clean

clean-reference:
	+$(MAKE) -C reference clean	

clean:  clean-measured clean-reference
