# optimzization utilties

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize

def plot_loss_trace(losses, loss_min=None, ax=None):
    '''Plot loss vs time.
    losses is a list of floats'''
    training_steps = len(losses)
    if ax is None:
        fig = plt.figure()
        ax = fig.add_subplot(111)
    #ax.plot(range(0, training_steps), losses, 'o-')
    # Skip the first step, which usually has very high loss
    ax.plot(range(1, training_steps), losses[1:], '-')
    if loss_min is not None:
        ax.axhline(loss_min, 0, training_steps, color='r')
        # Make sure horizontal line is visible by changing yscale
        ylim = ax.get_ylim()
        ax.set_ylim([0.9*loss_min, ylim[1]])
    #ax.set_ylabel("Loss")
    #ax.set_xlabel("Training steps")
    return ax
    
def plot_param_trace(params_trace, ax):
    '''Plot 2d trajectory of parameters on top of axis,
    param_trace is list of weight vectors'''
    n_steps = len(params_trace)
    xs = np.zeros(n_steps)
    ys = np.zeros(n_steps)
    for step in range(1, n_steps):
        xs[step] = params_trace[step][1]
        ys[step] = params_trace[step][0]
    ax.plot(xs, ys, 'o-')

class MinimizeLogger(object):
    '''Class to create a stateful callback function for scipy's minimize'''
    def __init__(self, obj_fun, grad_fun, args, print_freq=0, store_params=False):
        self.args = args
        self.param_trace = []
        self.obj_trace = []
        self.iter = 0
        self.print_freq = 0
        self.obj_fun = obj_fun
        self.grad_fun = grad_fun
        self.grad_norm_trace = []
        self.store_params = store_params
        
    def update(self, params):
        obj = self.obj_fun(params, *self.args)
        self.obj_trace.append(obj)
        gradient = self.grad_fun(params, *self.args)
        self.grad_norm_trace.append(np.linalg.norm(gradient))
        if self.store_params:
            self.param_trace.append(params) 
        if (self.print_freq > 0) and (self.iter % self.print_freq == 0):
            print "iteration {}, objective {:2.3f}".format(self.iter, obj)
        self.iter += 1

def bfgs_fit(params, obj_fun, grad_fun, args=None, callback_fun=None):
    result = minimize(obj_fun, params, args, method='BFGS', jac=grad_fun,
            callback=callback_fun)
    return result.x, result.fun

