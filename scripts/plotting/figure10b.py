#!/usr/bin/python3
import matplotlib
matplotlib.use('Agg')

from pprint import pprint
import csv
import numpy
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib import cm

CSV_FILE="figure10/figure10b_absolute.csv"
COLOR_MAP='PRGn'

# the data labels we are interested in...
baseline = "LP-LD"
configs = [ "LP-LD", "TLP-LD" ,"TRPI-LD", "TRPI-LD+M" ]
workloads = ["GUPS", "BTree", "HashJoin", "Redis", "XSBench", "PageRank", "LibLinear", "Canneal"]



# this is the number of bars per workload
ndataseries = len(configs)

# get the color map per workload
colorsmap = cm.get_cmap(COLOR_MAP, ndataseries)

# the hatches for the highlights
hs = [ '/////', '']

# the width of the bar (should be < 1)
barwidth = 0.50

#
# Matplotlib Setup
#

matplotlib.rcParams['figure.figsize'] = 8.0, 2.5
plt.rc('legend',**{'fontsize':13, 'frameon': 'false'})



###############################################################################
# load the data
###############################################################################

data = dict()
for w in workloads :
    data[w] = dict()
    for c in configs :
        data[w][c] = (0,0)

with open(CSV_FILE, 'r') as datafile :
    csvreader = csv.reader(datafile, delimiter='\t', quotechar='|')
    first = True
    for row in csvreader :
        if first :
            first = False
            continue

        if len(row) == 0 or row[0] == "" :
            continue
        
        workload = row[0]
        config = row[1]
        if workload in workloads and config in configs :
            data[workload][config] = (float(row[2]), float(row[3]))


###############################################################################
# Plot the Graph
###############################################################################

totalbars = (len(workloads) * len(configs)) + len(workloads);

fig, ax = plt.subplots()

datalabels = []

ymin = 0
ymax = 1

idx = 0
for w in workloads :
    idx = idx + 1
    datalabels.append("")
    
    midpoint = float(idx + (idx + len(configs) - 1)) / 2.0

    ax.text(midpoint / totalbars, -0.50, w, 
            horizontalalignment='center', fontsize=10,
            transform=ax.transAxes)

    for c in configs :
        if c == "LP-LD":
            continue

        (totalcycles, walkcycles) = data[w][c]
        (base, _) = data[w][baseline]
        wcn = (walkcycles / (totalcycles + 1)) * (totalcycles/(base+1))
        tcn = totalcycles/(base+1)
        ymax = max(ymax, tcn)
        
        colors = (colorsmap(0), colorsmap(1))
        if "M" in c :
            colors = (colorsmap(2), colorsmap(3))

        r = ax.bar(idx, wcn, barwidth, color=colors[0], hatch=hs[0], edgecolor='k')
        r = ax.bar(idx, tcn - wcn, barwidth, color=colors[1], edgecolor='k', bottom=wcn)

        datalabels.append(c)
        idx = idx + 1

# add the last data label
datalabels.append("")

ax.set_ylabel('Normalized Runtime')
ax.set_ylim([ymin, ymax * 1.10])

#ax.set_yticks([0, 0.25, 0.5, 0.75, 1.0])
#ax.set_yticklabels(["0%", "25%", "50%", "75%", "100%"])
ax.set_xlim([0, idx])
ax.set_xticks(numpy.arange(idx)+0.05)
ax.set_xticklabels(datalabels, rotation=90, fontsize=9,
    horizontalalignment='center', linespacing=0)


ax.tick_params(axis=u'both', which=u'both',length=0)

ax.set_axisbelow(True)
ax.grid(which='major', axis='y', zorder=999999.0)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_visible(False)
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()


plt.savefig('figure10b.pdf', bbox_inches='tight')
plt.savefig('figure10b.png', bbox_inches='tight')
