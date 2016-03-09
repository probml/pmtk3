# 1d linear regression using batch optimization

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize
import os
from utils.util import *
from utils.optim_util import *
from demos.linreg_1d_plot_demo import *

def get_gradient(params, X, y):
    '''x is N*D, y is N*1, params is D*1.
    Returns D*1 vector'''
    # gradient = (1/N) sum_n x(n,:)*yerr(n)   // row vector
    y_pred = get_prediction(params, X)
    N = y.shape[0]
    yerr = np.reshape((y_pred - y), (N, 1))
    gradient = np.sum(X * yerr, 0)/N # broadcast yerr along columns
    return gradient
    
def ols_fit(Xtrain, ytrain, initial_params):
    w_ols = np.linalg.lstsq(Xtrain, ytrain)[0]
    loss_ols = get_loss(ytrain, get_prediction(w_ols, Xtrain))
    return w_ols, loss_ols
    
def bfgs_fit(Xtrain, ytrain, initial_params):
    result = minimize(get_objective, initial_params, (Xtrain, ytrain),
        method='BFGS', jac=get_gradient)
    return result.x, result.fun

def bfgs_fit_with_logging(Xtrain, ytrain, initial_params):
    data = (Xtrain, ytrain)
    logger = MinimizeLogger(get_objective, data, 10)
    result = minimize(get_objective, initial_params, data,
        method='BFGS', jac=get_gradient, callback=logger.update)
    return result.x, result.fun, logger

def plot_error_surface_and_param_trace(xtrain, ytrain, w, wtrace, ttl=None, ax=None):
    '''wtrace is list of weight vectors'''
    if ax is None:
        fig = plt.figure()
        ax = fig.add_subplot(111)
    plot_error_surface(xtrain, ytrain, w, ax)
    n_steps = len(wtrace)
    xs = np.zeros(n_steps)
    ys = np.zeros(n_steps)
    for step in range(1, n_steps):
        xs[step] = wtrace[step][0]
        ys[step] = wtrace[step][1]
    ax.plot(xs, ys, 'o-')
    if ttl is not None:
        ax.set_title(ttl)

def main():
    np.random.seed(1)
    xtrain, ytrain, w_true = make_data_linreg_1d()
    N = xtrain.shape[0]
    D = 2
    Xtrain = np.c_[np.ones(N), xtrain] # add column of 1s
    w_init = np.zeros(D)
    
    w_ols, loss_ols = ols_fit(Xtrain, ytrain, w_init)
    w_bfgs, loss_bfgs = bfgs_fit(Xtrain, ytrain, w_init)  
    assert(np.allclose(w_bfgs, w_ols))
    assert(np.allclose(loss_bfgs, loss_ols))
    print "All assertions passed"

    w_bfgs, loss_bfgs, logger = bfgs_fit_with_logging(Xtrain, ytrain, w_init)
    ttl = 'BFGS'
    plot_loss_trace(logger.obj_trace, loss_ols, ttl)  
    plot_error_surface_and_param_trace(xtrain, ytrain, w_true, logger.param_trace, ttl)

if __name__ == "__main__":
    main()
    