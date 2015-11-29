#!/usr/bin/env python3
#
#       Author:    Srinivas Vasudevan
#       E-mail:    srvasude@google.com
#
#       File Name: contoursSSEDemo.py
#       Description:
#           Error surface for linear regression model.
#
#       Last Modified:
#           2015-11-21

import matplotlib.pyplot as pl
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
from utils import preprocessor_create
from utils import poly_data_make



def contoursSSEDemo():
  np.random.seed(0)
  N = 21
  x = np.random.randn(N,1)
  wtrue = [1, 1]
  sigma = 1
  y = wtrue[0] + wtrue[1]*x + sigma * np.random.randn(N, 1)
  X = np.concatenate((np.ones((N,1)), x.reshape(N,1)), axis=1)  

  return X,y

if __name__ == '__main__':
  X,y  = contoursSSEDemo()
  N = len(y)
  w = np.linalg.lstsq(X, y)[0]
  v = np.arange(-1, 3, .1)
  W0, W1 = np.meshgrid(v, v)
  
  SS = np.array([sum((w0*X[:,0] + w1*X[:,1].reshape(N,1) - y)**2)[0] for w0, w1 in zip(np.ravel(W0), np.ravel(W1))])
  SS = SS.reshape(W0.shape)
  
  fig = pl.figure()
  ax = fig.add_subplot(111, projection='3d')
  surf = ax.plot_surface(W0, W1, SS)
  pl.savefig('linregSurfSSE.png')
  pl.show()
  
  fig,ax = pl.subplots()
  ax.set_title('Sum of squares error contours for linear regression')
  CS = pl.contour(W0, W1, SS)
  pl.plot([.9492],[1.2565],'x')  

  pl.savefig('linregContoursSSE.png')
  pl.show()
