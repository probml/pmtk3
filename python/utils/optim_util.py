# optimzization utilties

import numpy as np
import matplotlib.pyplot as plt
import os
from collections import namedtuple

# Class to create a stateful callback function for scipy's minimize
class MinimizeLogger(object):
    def __init__(self, obj_fun, args, print_freq=0):
        self.args = args
        self.param_trace = []
        self.obj_trace = []
        self.iter = 0
        self.print_freq = 0
        self.obj_fun = obj_fun
        
    def update(self, params):
        obj = self.obj_fun(params, *self.args)
        self.obj_trace.append(obj)
        self.param_trace.append(params) # could take a lot of space
        if (self.print_freq > 0) and (iter % self.print_freq == 0):
            print "iteration {0}, objective {0:2.3f}".format(iter, obj)
        self.iter += 1

# Class to create a stateful callback function for sgd
class SGDLogger(object):
    def __init__(self, print_freq=0):
        self.param_trace = []
        self.obj_trace = []
        self.iter = 0
        self.print_freq = 0
        
    def update(self, params, obj, gradient):
        self.obj_trace.append(obj)
        self.param_trace.append(params) # could take a lot of space
        if (self.print_freq > 0) and (iter % self.print_freq == 0):
            print "iteration {0}, objective {0:2.3f}".format(iter, obj)
        self.iter += 1
    
#
# Function to plot loss vs time
def plot_loss_trace(losses, loss_min=None, ttl=None, ax=None):
    ''' losses is a list of floats'''
    training_steps = len(losses)
    if ax is None:
        fig = plt.figure()
        ax = fig.add_subplot(111)
    ax.plot(range(0, training_steps), losses, 'o-')
    if loss_min is not None:
        ax.axhline(loss_min, 0, training_steps)
        # Make sure horizontal line is visible by changing yscale
        ylim = ax.get_ylim()
        ax.set_ylim([0.9*loss_min, ylim[1]])
    if ttl is not None:
       ax.set_title(ttl)
    ax.set_ylabel("Loss")
    ax.set_xlabel("Training steps")
    
#########
# SGD helpers

# Shuffle rows (for SGD)
def shuffle_data(X, y):
    N = y.shape[0]
    perm = np.arange(N)
    np.random.shuffle(perm)
    return X[perm], y[perm]

# Batchifier class based on
#https://tensorflow.googlesource.com/tensorflow/+/master/tensorflow/examples/tutorials/mnist/input_data.py

class MiniBatcher(object):
    def __init__(self, X, y, batch_size):
        self.num_examples = X.shape[0]
        self.batch_size = batch_size
        self.X, self.y = shuffle_data(X, y) 
        #self.X, self.y = X, y
        self.index_in_epoch = 0
        self.epochs_completed = 0
        
    def next_batch(self):
        start = self.index_in_epoch
        self.index_in_epoch += self.batch_size
        if self.index_in_epoch > self.num_examples:
            self.epochs_completed += 1
            self.X, self.y = shuffle_data(self.X, self.y)
            start = 0
            self.index_in_epoch = self.batch_size
        stop = self.index_in_epoch
        return self.X[start:stop], self.y[start:stop]

# simple test
if False:
    np.random.seed(1)
    batch_size = 5
    Xtrain = np.arange(0,100)
    ytrain = Xtrain
    batchifier = MiniBatcher(Xtrain, ytrain, batch_size)
    for iter in range(5):
        Xb, yb = batchifier.next_batch()
        print iter
        print Xb


######
# Learning rate functions

    
#https://www.tensorflow.org/versions/r0.7/api_docs/python/train.html#exponential_decay
#decayed_learning_rate = learning_rate *
#                        decay_rate ^ (global_step / decay_steps)
def get_learning_rate_exp_decay(global_step, base_lr=0.01, decay_rate=0.9, decay_steps=2, staircase=True):
    if staircase:
        exponent = global_step / decay_steps # integer division
    else:
        exponent = global_step / np.float(decay_steps) 
    return base_lr * np.power(decay_rate, exponent)
   
   
# http://scikit-learn.org/stable/modules/generated/sklearn.linear_model.SGDRegressor.html                                                                            
# eta = eta0 / pow(t, power_t) [default]
def get_learning_rate_inv_scaling(t, base_lr=0.01, power_t=0.25):
   return base_lr / np.power(t+1, power_t)

def plot_lr_trace():
    lr_trace = []
    for iter in range(10):
        #lr = learning_rate_inv_scaling(iter)
        lr = get_learning_rate_exp_decay(iter, 0.01, 1)
        lr_trace.append(lr)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(lr_trace)
    plt.show()
    return(lr_trace)


#######
  
def sgd_minimize(params, batchifier, training_steps, obj_fun, grad_fun, 
       lr_fun, use_momentum=False, velocity_decay=0.9, callback=None):
    '''Returns a struct just like scipy's minimize'''                                                                                                                                                                                                   
    D = params.shape[0]
    params_avg = params
    velocity = np.zeros(D)
    for iter in range(training_steps):
        X_batch, y_batch = batchifier.next_batch()
        obj = obj_fun(params, X_batch, y_batch)
        gradient = grad_fun(params, X_batch, y_batch)
        lr = lr_fun(iter)
        if use_momentum:
            velocity = velocity_decay * velocity - lr * gradient
            params = params + velocity
        else:
            params = params - lr * gradient
        params_avg = (iter*params_avg + params)/(iter+1) 
        if callback is not None:
            callback(params, obj, gradient)  
    Result = namedtuple('Result', 'x xavg fun nit')
    return Result(params, params_avg, obj, iter)  


