#!/usr/bin/python3
import matplotlib
matplotlib.use('Agg')

from pprint import pprint
import csv
import numpy
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib import cm

CSV_FILE="table5/table5_absolute.csv"
COLOR_MAP='PRGn'

# the data labels we are interested in...
baseline = "Default"
configstrings   = [ "4kB", "1MB", "4GB" ]
configs = [4096, 2048*4096, 1048576 * 4096]

workloads = ["MAP", "PROTECT", "UNMAP", "MAP_SHARED", "PROTECT_SHARED", "UNMAP_SHARED"]
datacolumns = {
	'label' : -1,
	'npages' : -1,
	'pagesize' : -1,
	'mitosis' : -1,
	'min' : -1,
	'avg' : -1,
	'max' : -1,
    '95th' : -1, 
}


# this is the number of bars per workload
ndataseries = len(configs)

# get the color map per workload
colorsmap = cm.get_cmap(COLOR_MAP, ndataseries)

# the hatches for the highlights
hs = [ '/////', '']

# the width of the bar (should be < 1)
barwidth = 0.75

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
        data[w][c] = [(0,0,0,0), (0,0,0,0)]

with open(CSV_FILE, 'r') as datafile :
    csvreader = csv.reader(datafile, delimiter='\t', quotechar='|')
    first = True

    for row in csvreader :

        if len(row) == 0 or row[0] == ""  :
            continue

        if first :
            idx = 0
            for r in row:
                datacolumns[r.strip()] = idx
                idx = idx + 1
            first = False
            continue

        workload = row[datacolumns['label']]
        
        if workload not in workloads :
            continue

        npages = int(row[datacolumns['npages']])
        pagesize = int(row[datacolumns['pagesize']])
        config = npages * pagesize
        ismitosis = False
        if row[datacolumns['mitosis']] == "1" :
            ismitosis = True
        
        dmin = int(row[datacolumns['min']])/npages;
        davg = int(row[datacolumns['avg']])/npages;
        dmax = int(row[datacolumns['99th']])/npages;

        if workload in workloads and config in configs :
            if ismitosis :
                data[workload][config] = [data[workload][config][0], (ismitosis, dmin, davg, dmax)]
            else :
                data[workload][config] = [(ismitosis, dmin, davg, dmax), data[workload][config][1]] 

###############################################################################
# Plot the Graph
###############################################################################

totalbars = (3 * len(workloads) * len(configs)) + 2*len(workloads);

fig, ax = plt.subplots()

datalabels = []

ymin = 0
ymax = 1

idx = 0

legends = {
    'Default' : None,
    'Mitosis' : None
}

for w in workloads :
    idx = idx + 1
    datalabels.append("")

    idx = idx + 1
    datalabels.append("")    
    
    midpoint = float(idx + (idx + 3*len(configs) - 1 )) / 2.0 - 1
    midpoint = idx + (3*(len(configs) - 1) / 2.0)


    ax.text(midpoint / totalbars, -0.35, w, 
            horizontalalignment='center', fontsize=9,
            transform=ax.transAxes)

    for c in configs :
        for (ismitosis, dmin, davg, dmax) in data[w][c] :
            #   (base, _) = data[w][baseline]
            ymax = max(ymax, dmax)
            
            if ismitosis :
                color = colorsmap(0)
            else :
                color = colorsmap(1)        

            bar = ax.bar(idx, davg, barwidth,color=color, hatch=hs[0], edgecolor='k')
            r = ax.errorbar(idx, davg, yerr=[[davg - dmin], [dmax - davg]])

            if ismitosis :
                legends['Mitosis'] = bar
            else :
                legends['Default'] = bar

            idx = idx + 1


        idx = idx + 1
        if c > (1 << 30) :
            datalabels.append("%u GB" % (c >> 30))
        elif c > (1 << 20) :
             datalabels.append("%u MB" % (c >> 20))
        elif c > (1 << 10) :
            datalabels.append("%u kB" % (c >> 10))
        else :
            datalabels.append("%u" % c)
        for (ismitosis, dmin, davg, dmax) in data[w][c]:
            datalabels.append("")

        


# add the last data label
datalabels.append("")

ax.set_ylabel('latency per page [cycles]')
#ax.set_ylim([ymin, ymax * 1.10])

#ax.set_yticks([0, 0.25, 0.5, 0.75, 1.0])
#ax.set_yticklabels(["0%", "25%", "50%", "75%", "100%"])
ax.set_xlim([0, idx])
ax.set_xticks(numpy.arange(idx) + 0.5)
ax.set_xticklabels(datalabels, rotation=90, fontsize=8,
    horizontalalignment='center', linespacing=0)


ax.tick_params(axis=u'both', which=u'both',length=0)

ax.set_axisbelow(True)
ax.grid(which='major', axis='y', zorder=999999.0)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_visible(False)
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()


ax.legend([legends[l] for l in legends.keys()], legends.keys(), loc=4, ncol=4, 
          borderaxespad=0.,
          bbox_to_anchor=(-0.15, 1.01, 1.15, .102))

plt.savefig('table5.pdf', bbox_inches='tight')
plt.savefig('table5.png', bbox_inches='tight')
