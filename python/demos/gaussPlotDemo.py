#!/usr/bin/env python3

# Plot the standard gaussian distribution.

from scipy.stats import norm
import matplotlib.pylab as pl
import numpy as np

x = np.linspace(-3, 3, 100)
y = norm.pdf(x)
pl.plot(x, y)
pl.savefig('gaussPlotDemo.png')
pl.show()
