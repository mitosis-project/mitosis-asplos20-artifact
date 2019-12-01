#!/usr/bin/python3

import matplotlib
matplotlib.use('Agg')

import csv
import numpy
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib import cm


CSV_FILE="figure4/figure4_normalized.csv"
COLOR_MAP='PRGn'


#
# Matplotlib Setup
#

matplotlib.rcParams['figure.figsize'] = 8.0, 2.5
plt.rc('legend',**{'fontsize':13, 'frameon': 'false'})

###############################################################################
# load the data
###############################################################################
data = []
labels = []
legendnames = []
with open(CSV_FILE, 'r') as datafile :
    csvreader = csv.reader(datafile, delimiter='\t', quotechar='|')
    first = True
    for row in csvreader :
        if first :
            first = False
            data = [[] for x in row[1:]]
            legendnames = row[1:]
            continue
        labels.append(row[0])
        for i in range(0, len(row[1:])) :
            data[i].append(float(row[i+1].replace("%", "")))

###############################################################################
# 
###############################################################################

# number of data series
ndataseries = len(data)

# colormap
colorsmap = cm.get_cmap(COLOR_MAP, ndataseries)

# hatches
hs = [ '///', '\\\\\\', '--', '*']

# the number of groups
N = len(labels)

# indices are offest by the number of groups
ind = numpy.arange(N)

# the width is 1 over number of data series + 1
width = 1./(ndataseries + 1)


fig, ax = plt.subplots()


legends = []
n = 0
for v in data:
    r = ax.bar(ind+n*width, v, width*0.75, color=colorsmap(n), hatch=hs[n], edgecolor='k')
    legends.append((r, legendnames[n]))
    n+=1




# set the y-axis lables
ax.set_ylabel('Percentage of Remote PTE')
ax.set_yticks([0, 25, 50, 75, 100])
ax.set_yticklabels(["0%", "25%", "50%", "75%", "100%"])

# set the x-lables
ax.set_xticks(ind + (n-1)/2.0*width)
ax.set_xticklabels(labels) #, rotation=45)
ax.set_xlabel("workload")

# disable border around plot
ax.set_axisbelow(True)
ax.grid(which='major', axis='y', zorder=999999.0)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_visible(False)


lgnd_boxes, lgnd_labels = zip(*legends)
ax.legend(lgnd_boxes, lgnd_labels, loc=3, ncol=4, 
          borderaxespad=0., mode="expand",
          bbox_to_anchor=(-0.15, 1.01, 1.15, .102))

# safe the figure
plt.savefig('figure04.pdf', bbox_inches='tight')
plt.savefig('figure04.png', bbox_inches='tight')
