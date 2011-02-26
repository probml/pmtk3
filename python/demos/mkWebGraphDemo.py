#!/usr/bin/python2.6
import os, sys
import networkx # http://networkx.lanl.gov/
import cPickle

'''Parse some html pages and build an adjacency matrix.
Written by Eric Brochu and Nando de Freitas.
Modified by Kevin Murphy, 20 Feb 2011.
'''

def parseFiles(folder):
    '''Make a dictionary, keys are filenames, value is list of files that are pointed to'''
    fnames = os.listdir(folder)
    links = {}
    for file in fnames:
        links[file] = []
        filename = os.path.join(folder, file)
        print 'processing ', filename
        f = open(filename, 'r')
        for line in f.readlines():
            while True:
                p = line.partition('<a href="http://')[2]
                if p=='':
                    break
                (url, _, line) = p.partition('\">')
                links[file].append(url)
                print "file %s links to %s" % (file, url)
        f.close()
    return links


def mkGraph(mydict):
    '''Convert dictionary into weighted digraph'''
    DG = networkx.DiGraph()                                    
    DG.add_nodes_from(mydict.keys())
    edges = []
    for key, values in mydict.iteritems():
        eweight = {}
        # for each node on our list of values, increment a counter
        for v in values:
            if v in eweight:
                eweight[v] += 1
            else:
                eweight[v] = 1
        # for each unique target we connect to, create a weighted edge
        for succ, weight in eweight.iteritems():
            edges.append([key, succ, {'weight':weight}])
    DG.add_edges_from(edges)
    return DG

def plotGraph(DG):
    '''Visualize network'''
    pmtkFigureFolder = os.environ['PMTKFIGUREFOLDER']
    import matplotlib.pyplot as plt
    plt.figure(figsize=(9,9))
    pos=networkx.spring_layout(DG,iterations=10)
    #networkx.draw(DG,pos,node_size=0,alpha=0.4,edge_color='r', font_size=16)
    networkx.draw_circular(DG)
    plt.savefig(os.path.join(pmktFigureFolder, "link_graph.pdf"))
    plt.show()


#def pmtkInit():
#    pmtkFolder = os.environ['PMTKPYTHONHOME']
#    execfile(os.path.join(pmtkFolder, 'pmtk3PythonInit.py'))

def DGtoAdjMat(DG)
    NX = DG.nnodes()
    fnames = DG.nodes()
    T = matrix(numpy.zeros((NX, NX)))
    # Map from names to numbers
    f2i = dict((fn, i) for i, fn in enumerate(fnames))
    for predecessor, successors in DG.adj.iteritems():
        for s, edata in successors.iteritems():
            T[f2i[predecessor], f2i[s]] = edata['weight']
    return T
 
def main():
    #pmtkInit()
    pmtkDataFolder = os.environ['PMTKDATAFOLDER']
    mydict = parseFiles(os.path.join(pmtkDataFolder, 'smallWeb'))
    fnames = mydict.keys()
    DG = mkGraph(mydict)
    plotGraph(DG)
    #pmtkTmpFolder = os.environ['PMTKTMPFOLDER']
    # Save file
    tmpName = os.path.join(pmtkDataFolder, 'smallWeb', 'DG.pkl')
    cPickle.dump(DG, open(tmpName, 'w'))
    # DG = cPickle.load(fname)
    DGtoAdjMat(DG)
if __name__ == '__main__':
	main()
