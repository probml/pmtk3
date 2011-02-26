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


