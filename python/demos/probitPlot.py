#!/usr/bin/env python

# Plots Sigmoid vs. Probit.

from scipy.special import expit
from scipy.stats import norm
import numpy as np
import matplotlib.pylab as pl

x = np.arange(-6, 6, 0.1)
l = np.sqrt(np.pi/8); 
pl.plot(x, expit(x), 'r-', label='sigmoid')
pl.plot(x, norm.cdf(l*x), 'b--', label='probit')

pl.axis([-6, 6, 0, 1])
pl.legend()
pl.savefig('probitPlot.png')
pl.show()
