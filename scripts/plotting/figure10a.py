#!/usr/bin/python3
import matplotlib
matplotlib.use('Agg')

import numpy
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib import cm

import matplotlib

#matplotlib.rcParams['figure.figsize'] = 15.0, 10.0
matplotlib.rcParams['figure.figsize'] = 8.0, 2.5
#plt.rc('legend',**{'fontsize':13})
plt.rc('legend',**{'fontsize':13, 'frameon': 'false'})

def configure_plot(ax):
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.get_xaxis().tick_bottom()
    ax.get_yaxis().tick_left()


datalabels = [ "LP-LD" ,"RPI-LD", "RPI-LD+M"]

data = [
    {
        'label': 'GUPS', 
        'data': {
            "LP-LD" :  (2000, 1343),
            "RPI-LD" :  (2000, 1343),
            "RPI-LD+M" :  (2000, 1343)
        }
    },
    {
        'label': 'BTree', 
        'data': {
            "LP-LD" :  (2000, 1343),
            "RPI-LD" :  (2000, 1343),
            "RPI-LD+M" :  (2000, 1343)
        }
    },
    {
        'label': 'HashJoin', 
        'data': {
            "LP-LD" :  (2000, 1343),
            "RPI-LD" :  (2000, 1343),
            "RPI-LD+M" :  (2000, 1343)
        }
    },
    {
        'label': 'Redis', 
        'data': {
            "LP-LD" :  (2000, 1343),
            "RPI-LD" :  (2000, 1343),
            "RPI-LD+M" :  (2000, 1343)
        }
    },
    {
        'label': 'XSBench', 
        'data': {
            "LP-LD" :  (2000, 1343),
            "RPI-LD" :  (2000, 1343),
            "RPI-LD+M" :  (2000, 1343)
        }
    },
    {
        'label': 'PageRank', 
        'data': {
            "LP-LD" :  (2000, 1343),
            "RPI-LD" :  (2000, 1343),
            "RPI-LD+M" :  (2000, 1343)
        }
    },
    {
        'label': 'LIbLinear', 
        'data': {
            "LP-LD" :  (2000, 1343),
            "RPI-LD" :  (2000, 1343),
            "RPI-LD+M" :  (2000, 1343)
        }
    },
    {
        'label': 'Canneal', 
        'data': {
            "LP-LD" :  (2000, 1343),
            "RPI-LD" :  (2000, 1343),
            "RPI-LD+M" :  (2000, 1343)
        }
    },
]    

labels = [  ]

n = 0

data_transformed = dict()

for d in datalabels :
    data_transformed[d] = []
data_transformed["_"] = [(0,0) for x in data[0]['data']]


for d in data :
    labels.append("\n\n\n" + d['label'])
    for dp in d['data'] :
        data_transformed[dp].append(d['data'][dp])
    n = n + 1

print(data_transformed)

ndataseries = 3
colorsmap = cm.get_cmap('gist_gray', 3)
colors = [colorsmap(1), colorsmap(1), colorsmap(2)]
hs = [ '---', '']

#
# Barchart
# 

N = len(labels)
ind = numpy.arange(N)
width = 1./(ndataseries + 4)

fig, ax = plt.subplots()


legends = []
n = 0
for i in datalabels:
    walkcycles = [ wc for (_, wc) in data_transformed[i]]
    totalcycles = [ tc-wc for (tc, wc) in data_transformed[i]]
    
    r = ax.bar(ind+(n+0.5)*1.5*width, walkcycles, width, color=colors[n % 3], hatch=hs[0], edgecolor='k')
    r = ax.bar(ind+(n+0.5)*1.5*width, totalcycles, width, color=colors[n % 3], edgecolor='k', bottom=walkcycles)

    for j in ind :
        ax.text(j + (n + 0.2)*1.5*width, -100, datalabels[n], fontsize=6, rotation=90)

    n+=1


#fig.suptitle("Appel + Li microbenchmark results")
#ax.set_xlabel('Strategy')
ax.set_ylabel('Runtime')
#ax.set_yticks([0, 0.25, 0.5, 0.75, 1.0])
#ax.set_yticklabels(["0%", "25%", "50%", "75%", "100%"])
ax.set_xticks(ind + (n+2)/2.0*width)
ax.tick_params(axis=u'both', which=u'both',length=0)
ax.set_xticklabels(labels) #, rotation=45)
configure_plot(ax)



plt.savefig('figure10a.pdf', bbox_inches='tight')

#    fig, ax = plt.subplots()
#    rects1 = ax.bar(ind, bars_tux, width, color='r', yerr=err_tux)
#    rects2 = ax.bar(ind+1*width, bars_bf, width, color='y', yerr=err_bf)
#    ax.set_xlabel('Heap size')
#    ax.set_ylabel('Execution time [s]')
#    ax.set_xticks(ind+1*width)
#    ax.set_xticklabels( heaps )
#    ax.legend( (rects1[0], rects2[0]), taglines, loc="upper left" )
#    pdf.savefig()
#
#    fig, ax = plt.subplots()
#    rects1 = ax.bar(ind, heap_tux, width, color='r')
#    rects2 = ax.bar(ind+1*width, heap_bf, width, color='y')
#    ax.set_xlabel('Config')
#    ax.set_ylabel('Heap size [bytes]')
#    ax.set_xticks(ind+1*width)
#    ax.set_xticklabels( bf[1] )
#    ax.legend( (rects1[0], rects2[0]), taglines, loc="upper left" )
#    pdf.savefig()
#
#    fig, ax = plt.subplots()
#    rects1 = ax.bar(ind, coll_tux, width, color='r')
#    rects2 = ax.bar(ind+1*width, coll_bf, width, color='y')
#    ax.set_xlabel('Config')
#    ax.set_ylabel('# Collections')
#    ax.set_xticks(ind+1*width)
#    ax.set_xticklabels( bf[1] )
#    ax.legend( (rects1[0], rects2[0]), taglines, loc="upper right" )
#    pdf.savefig()
#
#    fig, ax = plt.subplots()
#    rects1 = ax.bar(ind, peak_tux, width, color='r')
#    rects2 = ax.bar(ind+1*width, peak_bf, width, color='y')
#    ax.set_xlabel('Config')
#    ax.set_ylabel('Heap Peak [bytes]')
#    ax.set_xticks(ind+1*width)
#    ax.set_xticklabels( bf[1] )
#    ax.legend( (rects1[0], rects2[0]), taglines, loc="upper left" )
#    pdf.savefig()
