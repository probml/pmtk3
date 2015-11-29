#!/usr/bin/env python3
#
#       Author:    Srinivas Vasudevan
#       E-mail:    srvasude@google.com
#
#       File Name: linregResiduals.py
#       Description:
#         Linear regression on data with residuals.
#
#       Last Modified:
#           2015-11-21

import matplotlib.pyplot as pl
import numpy as np
from utils import poly_data_make


N = 21
x, y, _, _, _, _ = poly_data_make(sampling='thibaux', n=N)
X = np.concatenate((np.ones((N,1)), x.reshape(N,1)), axis=1)  
w = np.linalg.lstsq(X, y)[0]
y_estim = np.dot(X,w)

pl.plot(X[:,1],y,'o')
pl.plot(X[:,1],y_estim,'-')
pl.savefig('linregResidualsNoBars.png')
pl.show()

for x0, y0, y_hat in zip(X[:,1], y, y_estim):
  pl.plot([x0, x0],[y0,y_hat],'k-')
pl.plot(X[:,1],y,'o')
pl.plot(X[:,1],y_estim,'-')

pl.savefig('linregResidualsBars.png')
pl.show()
