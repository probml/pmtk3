# Functions related to stochastic gradient descent (SGD)

import numpy as np
import matplotlib.pyplot as plt
#from collections import namedtuple

# Class to create a stateful callback function for sgd
class SGDLogger(object):
    def __init__(self, print_freq=0, store_params=False):
        self.param_trace = []
        self.grad_norm_trace = []
        self.obj_trace = []
        self.iter = 0
        self.print_freq = print_freq
        self.store_params = store_params
        
    def update(self, params, obj, gradient, epoch, batch_num):
        self.obj_trace.append(obj)
        self.grad_norm_trace.append(np.linalg.norm(gradient))
        if self.store_params:
            self.param_trace.append(params) 
        if (self.print_freq > 0) and (self.iter % self.print_freq == 0):
            print "epoch {}, batch num {}, iteration {}, objective {:2.3f}".format(
                epoch, batch_num, self.iter, obj)
        self.iter += 1
    

    
#########
# SGD helpers

# Shuffle rows (for SGD)
def shuffle_data(X, y):
    N = y.shape[0]
    perm = np.arange(N)
    np.random.shuffle(perm)
    return X[perm], y[perm]

def make_batches(N_data, batch_size):
    return [slice(i, min(i+batch_size, N_data))
            for i in range(0, N_data, batch_size)]
                        
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
def lr_exp_decay(t, base_lr=0.001, decay_rate=0.9, decay_steps=2, staircase=True):
    if staircase:
        exponent = t / decay_steps # integer division
    else:
        exponent = t / np.float(decay_steps) 
    return base_lr * np.power(decay_rate, exponent)
   
   
# http://scikit-learn.org/stable/modules/generated/sklearn.linear_model.SGDRegressor.html                                                                            
# eta = eta0 / pow(t, power_t) [default]
def lr_inv_scaling(t, base_lr=0.001, power_t=0.25):
   return base_lr / np.power(t+1, power_t)

def plot_lr_trace():
    lr_trace = []
    for iter in range(10):
        #lr = lr_inv_scaling(iter)
        lr = lr_exp_decay(iter, 0.01, 1)
        lr_trace.append(lr)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(lr_trace)
    plt.show()
    return(lr_trace)


#######

class SGDUpdater(object):
    '''Class to update parameters in stochastic gradient descent.
    Several algorithms are supported.
    SGD with momentum:
        vel_t = mom_decay * vel_{t-1} + lr_t * g_t 
        delta_t = - vel_t
    RMSprop is this algorithm:    
        mean_square_t = rms_decay * mean_square_{t-1} + (1-rms_decay) * g_t ** 2
        vel_t = mom_decay * vel_{t-1} + lr_t * g_t / sqrt(mean_square + epsilon)
        delta_t = -vel_t
    See http://www.cs.toronto.edu/~tijmen/csc321/slides/lecture_slides_lec6.pdf.
    '''  
    def __init__(self, lr_fun, momentum_decay, rms_decay):
        '''lr_fun(iter, epoch) computes learning rate.
        Set rms_decay=0 to use standard SGD with momentum.
        Set momentum_decay=0 to use standard SGD.'''
        self.lr_fun = lr_fun
        self.momentum_decay = momentum_decay
        self.rms_decay = rms_decay
        self.velocity = []
        self.mean_squared_gradients = []
        self.iter = 0
        
    def init(self, params):
        D = len(params)
        self.velocity = np.zeros(D)
        self.mean_squared_gradients = np.zeros(D)
        
    def update(self, params, obj_value, gradient_vec, epoch):
        self.iter = self.iter + 1
        lr = self.lr_fun(self.iter, epoch)
        if self.rms_decay > 0:
            self.mean_squared_gradients = self.rms_decay * self.mean_squared_gradients + (1-self.rms_decay)*np.square(gradient_vec)
            eps = 1e-10
            denominator = np.sqrt(self.mean_squared_gradients + eps)
        else:
            denominator = 1
        self.velocity = self.momentum_decay * self.velocity + lr * gradient_vec / denominator
        params = params - self.velocity
        return params

              
def sgd_minimize(params, obj_fun, grad_fun, X, y, batch_size, num_epochs, 
       param_updater, callback_fun=None): 
    param_updater.init(params)                                                                                                                                                                                                
    N = X.shape[0]
    batch_indices = make_batches(N, batch_size)
    for epoch in range(num_epochs):
        X, y = shuffle_data(X, y) 
        for batch_num, batch_idx in enumerate(batch_indices):
            X_batch, y_batch = X[batch_idx], y[batch_idx]
            obj_value = obj_fun(params, X_batch, y_batch)
            gradient_vec = grad_fun(params, X_batch, y_batch)
            params = param_updater.update(params, obj_value, gradient_vec, epoch)
            if callback_fun is not None:
                callback_fun(params, obj_value, gradient_vec, epoch, batch_num)  
    return params, obj_value 

