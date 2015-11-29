#!/usr/bin/env python

from scipy.stats import t, laplace, norm
import numpy as np
import matplotlib.pylab as pl

x = np.linspace(-4, 4, 100)
pl.title('|x|^0.2')
pl.plot(x, np.absolute(x)**.2)
pl.savefig('lossFunctionFig_01.png')

pl.figure()
pl.title('|x|')
pl.plot(x, np.absolute(x))
pl.savefig('lossFunctionFig_02.png')

pl.figure()
pl.title('|x|^2')
pl.plot(x, np.absolute(x)**2)
pl.savefig('lossFunctionFig_03.png')
pl.show()
