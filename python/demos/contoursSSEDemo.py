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
#           2015-11-28

import matplotlib.pyplot as pl
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
from utils import poly_data_make

def contoursSSEDemo():
  N = 21
  x,y,_,_,_,_ = poly_data_make(sampling='thibaux', n=N)
  X = np.concatenate((np.ones((N,1)), x.reshape(N,1)), axis=1)

  return X,y

if __name__ == '__main__':
  X,y  = contoursSSEDemo()
  N = len(y)
  w = np.linalg.lstsq(X, y)[0]
  #print sum((np.dot(X,w)-y)**2)
  v = np.arange(-6, 6, .1)
  W0, W1 = np.meshgrid(v, v)
  #print W0, W1
  
  SS = np.array([sum((w0*X[:,0] + w1*X[:,1] - y)**2) for w0, w1 in zip(np.ravel(W0), np.ravel(W1))])
  #print SS
  SS = SS.reshape(W0.shape)
  
  fig = pl.figure()
  ax = fig.add_subplot(111, projection='3d')
  surf = ax.plot_surface(W0, W1, SS)
  pl.savefig('linregSurfSSE.png')
  pl.show()
  
  fig,ax = pl.subplots()
  ax.set_title('Sum of squares error contours for linear regression')
  CS = pl.contour(W0, W1, SS)
  pl.plot([-4.351],[0.5377],'x')  

  pl.savefig('linregContoursSSE.png')
  pl.show()
