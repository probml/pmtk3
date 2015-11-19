#!/usr/bin/env python

import numpy as np
import matplotlib.pylab as pl

e = np.exp(1)
x = np.linspace(-10, 10, 1000)
y = e**x / (e**x + 1)
pl.plot(x, y)
pl.title('sigmoid function')
pl.savefig('sigmoidPlot.png')
pl.show()
