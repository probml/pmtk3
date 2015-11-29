#!/usr/bin/env python

from scipy.stats import pareto
import numpy as np
import matplotlib.pylab as pl

delta = 1.5
huber = lambda x: (x**2/2) * (x <= delta) + (delta * abs(x) - delta**2/2) * (x > delta)
l2 = lambda x: abs(x)**2
l1 = abs

funs = [l2, l1, huber]
styles = ['r-', 'b:', 'g-.']
labels = ['l2', '11', 'huber']
x = np.arange(-3, 3, .01)

for i, fun in enumerate(funs):
    pl.plot(x, fun(x), styles[i], label=labels[i])

pl.axis([-3, 3, -0.5, 5])
pl.legend()
pl.savefig('huberLossDemo.png')
pl.show()
