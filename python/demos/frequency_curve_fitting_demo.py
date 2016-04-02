from __future__ import division
import numpy as np
from numpy import linalg as la
import matplotlib
matplotlib.use('TKAgg')
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider
from scipy.optimize import minimize

"""
On An Absolute Criterion for Fitting Frequency Curves
http://www.jstor.org/stable/2246266

R.A Fisher said in this essay that "it(Least Square Method) is obviously
inapplicable to fit frequency curve".

The following is a proof-of-concept demo that shows one CAN fit a frequency curve
using Least Square and it's "good to the eye", quantitativly good and fast.
The result is also compared with MLE which is proposed in this essay as well.

The only trick for using least square is that one has to scale the loss function
to help optimizer cope with numerical instability caused by probability density
functions.
"""

def GaussianPdf(x, params):
  m = params[0] # mean
  s = params[1] # std
  PI = np.pi
  return 1/(s * np.sqrt(2 * PI)) * np.exp(-(x - m)**2/(2 * s**2))


def ConstructLeastSquareLossFunc(X, Y, model):
  pairs = zip(X, Y)
  def LossFunc(params):
    # the L2 loss is scaled by 5000
    return 5000.0 * sum([(model(x, params) - y)**2 for (x, y) in pairs])
  return LossFunc


def ConstructNegtiveLogLikelihood(sample, model):
  def LogLikelihood(params):
    return -1.0 * sum([np.log(model(x, params)) for x in sample])
  return LogLikelihood


def DrawSamplesFromNormalDistribution(N, mean=200.0, std=300.0):
  return np.random.normal(mean, std, N)


def main():
  # Draw samples from a Gaussian distribution with given mean and standard deviation
  N, mean, std = 10000, 100.0, 150.0
  samples = DrawSamplesFromNormalDistribution(N, mean=mean, std=std)
  print "Ground truth mean and std: %d, %d" % (mean, std)


  # Use least square to fit a Gaussian PDF model
  hist, bin_edges = np.histogram(samples, bins=len(samples)/20, density=True)
  X, Y = bin_edges[0: -1], hist
  lossFunc = ConstructLeastSquareLossFunc(X, Y, model=GaussianPdf)
  lsq_result = minimize(lossFunc, [0.0, 100.0], method='BFGS')
  print "Least square estimated mean and std: %f, %f" % tuple(lsq_result.x)

  # Use MLE to fit a Gaussian PDF model
  lossFunc = ConstructNegtiveLogLikelihood(samples, model=GaussianPdf)
  mle_result = minimize(lossFunc, [0.0, 100.0], method='BFGS')
  print "MLE estimated mean and std: %f, %f" % tuple(mle_result.x)

  # Visualize the density historgram of the samples
  plt.plot(X, Y, 'o')
  # Visualize the least square estimated Gaussian PDF
  F = [GaussianPdf(x, lsq_result.x) for x in X]
  plt.plot(X, F, '-', color='r')
  # Visualize the MLE estimated Gaussian PDF
  F = [GaussianPdf(x, mle_result.x) for x in X]
  plt.plot(X, F, '-', color='g')
  plt.show()

if __name__ == "__main__":
    main()