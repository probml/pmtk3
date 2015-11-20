#!/usr/bin/env python3
#
#       Author:    TianJun
#       E-mail:    tianjun.cpp@gmail.com
#       Website:   www.tianjun.ml
#
#       File Name: gaussPlotDemo.py
#       Description:
#           plot the gauss function
#
#       Last Modified:
#           2014-02-06 21:49:48


from scipy.stats import norm
import matplotlib.pylab as pl
import numpy as np

x = np.linspace(-3, 3, 100)
y = norm.pdf(x)
pl.plot(x, y)
pl.savefig('gaussPlotDemo.png')
pl.show()
