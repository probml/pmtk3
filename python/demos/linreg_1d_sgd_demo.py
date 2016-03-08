# 1d linear regression using SGD

from utils import *
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize
import os

print nsubplots(5)

#######
# Make some data

np.random.seed(1)
N = 21
xtrain = np.linspace(0, 20, N)
sigma2 = 2
w_true = np.array([-1.5, 1/9.])
fun = lambda x: w_true[0] + w_true[1]*x
noise = np.random.normal(0, 1, xtrain.shape) * np.sqrt(sigma2)
ytrain = fun(xtrain) + noise

# Add columns of 1s
Xtrain = np.concatenate((np.ones((N,1)), xtrain.reshape(N,1)), axis=1)


#########
# Model and loss
def get_prediction(params, X, add_ones=False):
    '''x is N*D,  params is D*1.
    Returns N*1 vector'''
    N = X.shape[0]
    if add_ones:
        X = np.c_[np.ones(N), X]
    yhat = np.dot(X, params)
    return yhat

def get_loss(y, y_pred):
    '''y is N*1, y_pred is N*1.
    Returns scalar'''
    N = y.shape[0]
    return sum(np.square(y - y_pred))/N
    
def get_objective(params, X, y):
    return get_loss(y, get_prediction(params, X))

def obj_fun_batch(params):
    return get_objective(params, Xtrain, ytrain)
      
########## 
# Function to plot the observed data and predictions
def plot_data_and_pred(x, y, coef, draw_verticals=False):
    '''x is N*1, y is N*1, coef is 2*1'''
    x_range = np.linspace(np.min(x), np.max(x), 100)
    yhat_range = get_prediction(coef, x_range, True)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(x, y, 'o', label='observed')
    ax.plot(x_range, yhat_range, 'r-', label='predicted')
    if draw_verticals: # from observed value to predicted true
        yhat_sparse = get_prediction(coef, x, True)
        for x0, y0, yhat0 in zip(x, y, yhat_sparse):
            ax.plot([x0, x0],[y0, yhat0],'k-')
    plt.legend() #[line_pred, line_true], ['predicted', 'true'])
    plt.show()

#plot_data_and_pred(xtrain, ytrain, w_true, True)

########## 
# Plot error surface
def plot_error_surface(xtrain, ytrain, w):
    w0s = np.linspace(-2*w[0], 2*w[0], 10)
    w1s = np.linspace(-2*w[1], 2*w[1], 10)
    w0_grid, w1_grid = np.meshgrid(w0s, w1s)
    def loss(w0, w1):
        return obj_fun_batch([w0,w1])
    lossvec = np.vectorize(loss)
    z = lossvec(w0_grid, w1_grid)
    fig = plt.figure()
    ax  = fig.add_subplot(111)
    cs = ax.contour(w0s, w1s, z)
    ax.clabel(cs)
    ax.plot(w[0], w[1], 'rx', markersize=14)

#plot_error_surface(xtrain, ytrain, w_true)
  
def plot_error_surface_and_param_trace(xtrain, ytrain, w, wtrace, ttl=None):
    '''wtrace is list of weight vectors'''
    plot_error_surface(xtrain, ytrain, w)
    n_steps = len(wtrace)
    xs = np.zeros(n_steps)
    ys = np.zeros(n_steps)
    for step in range(1, n_steps):
        xs[step] = wtrace[step][0]
        ys[step] = wtrace[step][1]
    plt.plot(xs, ys, 'o-')
    if ttl is not None:
        plt.title(ttl)
    plt.show()
              
#w_trace = [np.zeros(2), np.random.randn(2)*0.1, w_true]
#plot_error_surface_and_param_trace(xtrain, ytrain, w_true, w_trace)
#plot_error_surface_and_param_trace(xtrain, ytrain, w_true, params_trace)

########## 
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
        plt.title(ttl)
    ax.set_ylabel("Loss")
    ax.set_xlabel("Training steps")

#plot_loss_trace([3,2,1], 0.5)


#######
# Batch training
   
# Least squares  
w_ols = np.linalg.lstsq(Xtrain, ytrain)[0]
        
# Use numerical gradient
result = minimize(obj_fun_batch, np.zeros(2))
w_hat = result.x
assert(np.allclose(w_hat, w_ols))

def get_gradient(params, X, y):
    '''x is N*D, y is N*1, params is D*1.
    Returns D*1 vector'''
    # gradient = (1/N) sum_n x(n,:)*yerr(n)   // row vector
    y_pred = get_prediction(params, X)
    N = y.shape[0]
    yerr = np.reshape((y_pred - y), (N, 1))
    gradient = np.sum(X * yerr, 0)/N # broadcast yerr along columns
    return gradient
        
def grad_fun_batch(params):
    return get_gradient(params, Xtrain, ytrain)
    
# Use BGFGs
result = minimize(obj_fun_batch, np.zeros(2), method='BFGS', jac=grad_fun_batch)
w_hat = result.x
assert(np.allclose(w_hat, w_ols))

loss_ols = get_loss(ytrain, get_prediction(w_ols, Xtrain))
assert(np.allclose(result.fun, loss_ols))

print 'batch training done'

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

class Batchifier(object):
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
            self.index_in_epoch = batch_size
        stop = self.index_in_epoch
        return self.X[start:stop], self.y[start:stop]

# simple test
'''
np.random.seed(1)
batch_size = 10
batchifier = Batchifier(Xtrain, ytrain, batch_size)
for iter in range(5):
    Xb, yb = batchifier.next_batch()
    print iter
    print Xb
'''

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

#print plot_lr_trace()

#######
  
def SGD(params, batchifier, training_steps, obj_fun, grad_fun, 
       lr_fun, use_momentum=False, velocity_decay=0.9, print_freq=0,
       store_params_trace=False): 
    ''' Returns params, params_avg, obj_trace, params_trace'''                                                                                                                                                                                                    
    obj_trace = [] 
    params_trace = []  
    params_avg = params
    params_avg_trace = []
    D = params.shape[0]
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
        obj_trace.append(obj)
        if store_params_trace: # uses a lot of space...
            params_trace.append(params)
            params_avg_trace.append(params_avg)
        if (print_freq > 0) and (iter % print_freq == 0):
            print "iteration {0} objective {1}".format(iter, obj)
    return params, params_avg, obj_trace, params_trace, params_avg_trace

##########

init_lr = 0.01
n_steps = 200
batch_sizes = [10, N]
lr_decays = [1, 0.95]
momentums = [True]
folder = '/Users/kpmurphy/github/pmtk3/python/figures/'
n_expts = len(batch_sizes) * len(lr_decays) * len(momentums)

for batch_size in batch_sizes:
    for lr_decay in lr_decays:
        for momentum in momentums:
            np.random.seed(1)
            batchifier = Batchifier(Xtrain, ytrain, batch_size)
            params = np.zeros(2) 
            lr_fun = lambda(iter): get_learning_rate_exp_decay(iter, init_lr, lr_decay) 
            batch_size_frac = batch_size / np.float(N)
            ttl = 'batch={:0.2f}-lrdecay={:0.2f}-mom={}'.format(batch_size_frac, lr_decay, momentum)
            print 'starting experiment {}'.format(ttl)
            
            params, params_avg, obj_trace, params_trace, params_avg_trace = SGD(params,
                batchifier, n_steps,  get_objective, get_gradient, lr_fun,
                use_momentum=momentum, print_freq=20, store_params_trace=True)
          
            fig = plt.figure()
            ax = fig.add_subplot(111)
            plot_loss_trace(obj_trace, loss_ols, ttl)
            fname = os.path.join(folder, 'linreg_1d_sgd_loss_trace_{}.png'.format(ttl))
            plt.savefig(fname)
            
            plot_error_surface_and_param_trace(xtrain, ytrain, w_true, params_trace, ttl)
            fname = os.path.join(folder, 'linreg_1d_sgd_param_trace_{}.png'.format(ttl))
            plt.savefig(fname)

