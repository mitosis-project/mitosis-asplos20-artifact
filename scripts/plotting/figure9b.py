#!/usr/bin/python3
import matplotlib
matplotlib.use('Agg')

from pprint import pprint
import csv
import numpy
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib import cm

CSV_FILE="figure09.csv"
COLOR_MAP='PRGn'

# the data labels we are interested in...
baseline = "TF"
datalabels = [ "TF" ,"TF+M", "TF-A", "TF-A+M", "TI", "TI+M" ]
workloads = ["BTree", "HashJoin", "XSBench", "Graph500", "Canneal"]

#
# Matplotlib Setup
#

matplotlib.rcParams['figure.figsize'] = 8.0, 2.5
plt.rc('legend',**{'fontsize':13, 'frameon': 'false'})



###############################################################################
# load the data
###############################################################################
data = dict()
for d in datalabels :
    data[d] = dict()

labels = []
legendnames = []
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
        if config in datalabels:
            data[config][workload] = (float(row[2]), float(row[3]), 0.0, 0.0)

ndataseries = len(datalabels)
colorsmap = cm.get_cmap(COLOR_MAP, ndataseries)
hs = [ '/////', '']


#
# normalize values
#

for c in datalabels :
    for w in workloads :
        (tc, wc, ntc, nwc) = data[c][w]
        (n, _, _, _) = data[baseline][w]
        data[c][w] = (tc, wc, tc/(n+1), (wc / (tc + 1)) * (tc/(n+1))) 



N = len(workloads)
ind = numpy.arange(N)
width = 1./(ndataseries + 1)

fig, ax = plt.subplots()



legends = []
n = 0


for i in data:
    values = [data[i][w] for w in workloads]

    walkcycles = [ wc for (_, _ , _, wc) in values]
    totalcycles = [ tc-wc for (_, _, tc, wc) in values]
    
    if "M" in i :
        r = ax.bar(ind+n*width, walkcycles, width * 0.75, color=colorsmap(2), hatch=hs[0], edgecolor='k')
        r = ax.bar(ind+n*width, totalcycles, width * 0.75, color=colorsmap(3), edgecolor='k', bottom=walkcycles)            
    else :
        r = ax.bar(ind+n*width, walkcycles, width * 0.75, color=colorsmap(0), hatch=hs[0], edgecolor='k')
        r = ax.bar(ind+n*width, totalcycles, width * 0.75, color=colorsmap(1), edgecolor='k', bottom=walkcycles)    

    
    for j in ind :
        ax.text(j + (n - 0.25)*width, 0, datalabels[n] + "    ", fontsize=6, rotation=90)

    n+=1


ax.set_ylabel('Normalized Runtime')
#ax.set_yticks([0, 0.25, 0.5, 0.75, 1.0])
#ax.set_yticklabels(["0%", "25%", "50%", "75%", "100%"])
ax.set_xticks(ind + (len(datalabels) - 1) / 2.0 * width)
ax.tick_params(axis=u'both', which=u'both',length=0)
ax.set_xticklabels([ "\n\n" + w  for w in workloads]) #, rotation=45)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()



plt.savefig('figure09a.pdf', bbox_inches='tight')
plt.savefig('figure09a.png', bbox_inches='tight')

