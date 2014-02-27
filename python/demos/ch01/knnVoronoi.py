#!/usr/bin/env python

from scipy.spatial import KDTree, Voronoi, voronoi_plot_2d
import matplotlib.pylab as pl
import numpy as np

data = np.random.rand(25, 2)
tree = KDTree(data)
vor = Voronoi(data)
x = np.linspace(0, 1, 200)
y = np.linspace(0, 1, 200)
xx, yy = np.meshgrid(x, y)
xy = np.c_[xx.ravel(), yy.ravel()]

print('Using scipy.spatial.voronoi_plot_2d, wait...')
voronoi_plot_2d(vor)
pl.savefig('knnVoronoi_1.png')

print('Using scipy.spatial.KDTree, wait a few seconds...')
pl.figure()
pl.plot(data[:, 0], data[:, 1], 'ko')
pl.pcolormesh(x, y, tree.query(xy)[1].reshape(200, 200))
pl.savefig('knnVoronoi_2.png')
pl.show()
