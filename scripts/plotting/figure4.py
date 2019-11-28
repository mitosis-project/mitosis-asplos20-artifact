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


pages = 100
traps = 5000

data = [
    {
        'label': 'Canneal', 
        'data': [  0.10862, 0.8580, 0.3336, 0.4322],
    },

    {
        'label': 'Memcached', 
        'data': [  0.10862, 0.8580, 0.3336, 0.4322],
    },
    {
        'label': 'XSBench', 
        'data': [  0.10862, 0.8580, 0.3336, 0.4322],
    },
    {
        'label': 'Graph500', 
        'data': [  0.10862, 0.8580, 0.3336, 0.4322],
    },
    {
        'label': 'HashJoin', 
        'data': [  0.10862, 0.8580, 0.3336, 0.4322],
    },
    {
        'label': 'Btree', 
        'data': [  0.10862, 0.8580, 0.3336, 0.4322],
    }
]    

labels = [  ]
legendnames = ["Socket 0", "Socket 1", "Socket 2", "Socket 3"]

data_transformed = [ [ 0 for j in data] for i in legendnames ]

n = 0
for d in data :
    labels.append(d['label'])
    for i in range(0, len(d['data'])) :
        data_transformed[i][n] = (d['label'], d['data'][i])
    n = n + 1
print(data_transformed)

ndataseries = 7
colorsmap = cm.get_cmap('gist_gray', ndataseries)
colors = [colorsmap(1), colorsmap(2), colorsmap(3), colorsmap(4)]
hs = [ '/', '\\\\\\', '///', '--', '///']

#
# Barchart
# 

N = len(labels)
ind = numpy.arange(N)
width = 1./(ndataseries + 1)

fig, ax = plt.subplots()


legends = []
n = 0
for i in data_transformed:
    v = [ val for (l, val) in i]
    print(v)
    print(ind)
    r = ax.bar(ind+n*width, v, width, color=colors[n], hatch=hs[n], edgecolor='k')
    legends.append((r, legendnames[n]))
    n+=1


#fig.suptitle("Appel + Li microbenchmark results")
#ax.set_xlabel('Strategy')
ax.set_ylabel('Percentage')
ax.set_yticks([0, 0.25, 0.5, 0.75, 1.0])
ax.set_yticklabels(["0%", "25%", "50%", "75%", "100%"])
ax.set_xticks(ind + (n-1)/2.0*width)
ax.set_xticklabels(labels) #, rotation=45)
configure_plot(ax)
lgnd_boxes, lgnd_labels = zip(*legends)
ax.legend( lgnd_boxes, lgnd_labels,               loc=3, ncol=4, borderaxespad=0., 
          mode="expand",
          bbox_to_anchor=(-0.15, 1.01, 1.15, .102))


plt.savefig('figure4.pdf', bbox_inches='tight')

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
