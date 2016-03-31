# optimzization utilties

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize, minimize_scalar

def plot_loss_trace(losses, loss_min=None, ax=None):
    '''Plot loss vs number of function evals.
    losses is a list of floats'''
    if ax is None:
        fig = plt.figure()
        ax = fig.add_subplot(111)
    ax.plot(losses[1:], '-')
    if loss_min is not None:
        ax.axhline(loss_min, 0, len(losses), color='r')
        # Make sure horizontal line is visible by changing yscale
        ylim = ax.get_ylim()
        ax.set_ylim([0.9*loss_min, ylim[1]])
    #ax.set_ylabel("Loss")
    #ax.set_xlabel("Training steps")
    return ax
    


class OptimLogger(object):
    '''Class to create a stateful callback function for optimizers,
    of the form callback(params, iter, grad).
    This calls obj_fun(params, iter) at each iteration.'''
    def __init__(self, obj_fun=None, store_freq=1, print_freq=0, store_params=False):
        self.param_trace = []
        self.grad_norm_trace = []
        self.obj_trace = []
        self.iter_trace = []
        self.print_freq = print_freq
        self.store_freq = store_freq
        self.store_params = store_params
        self.obj_fun = obj_fun
        
    def callback(self, params, iter, gradient):
        if self.obj_fun is not None:
            obj = self.obj_fun(params, iter)
        else:
            obj = 0
        if (self.print_freq > 0) and (iter % self.print_freq == 0):
            print "iteration {}, objective {:2.3f}".format(iter, obj)
        if (self.store_freq > 0) and (iter % self.store_freq == 0):
            self.obj_trace.append(obj)
            if gradient is not None:
                self.grad_norm_trace.append(np.linalg.norm(gradient))
            self.iter_trace.append(iter)
            if self.store_params:
                self.param_trace.append(params) 


           

# Shuffle rows (for SGD)
def shuffle_data(X, y):
    N = y.shape[0]
    perm = np.arange(N)
    np.random.shuffle(perm)
    return X[perm], y[perm]
    
######
# Learning rate functions
    
def grid_search_1d(eval_fun, param_list):
    #scores = np.apply_along_axis(eval_fun, 0, param_list)
    scores = [eval_fun(p) for p in param_list]
    istar = np.nanargmin(scores)
    return param_list[istar], scores
    
def const_lr(lr=0.001):
    fn = lambda(iter): lr
    return fn
    
#https://www.tensorflow.org/versions/r0.7/api_docs/python/train.html#exponential_decay
#decayed_learning_rate = learning_rate *
#                        decay_rate ^ (global_step / decay_steps)
def lr_exp_decay(t, base_lr=0.001, decay_rate=0.9, decay_steps=100, staircase=True):
    if staircase:
        exponent = t / decay_steps # integer division
    else:
        exponent = t / np.float(decay_steps) 
    return base_lr * np.power(decay_rate, exponent)
   
   
# http://scikit-learn.org/stable/modules/generated/sklearn.linear_model.SGDRegressor.html                                                                            
# eta = eta0 / pow(t, power_t) [default]
def lr_inv_scaling(t, base_lr=0.001, power_t=0.25):
   return base_lr / np.power(t+1, power_t)
   

#http://leon.bottou.org/projects/sgd
def lr_bottou(t, base_lr=0.001, power_t=0.75, lam=1):
   return base_lr / np.power(1 + lam*base_lr*t, power_t)


def plot_lr_trace():
    lr_trace = []
    for iter in range(500):
        lr = lr_exp_decay(iter, 0.01, 0.9, 100, False)
        lr_trace.append(lr)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(lr_trace)
    plt.show()

    
######
# Modified from https://github.com/HIPS/autograd/blob/master/examples/optimizers.py



        
def sgd(grad, x, callback=None, num_iters=100, lr_fun=const_lr(), mass=0.9):
    """Stochastic gradient descent with momentum.
    grad() must have signature grad(x, i), where i is the iteration number."""
    velocity = np.zeros(len(x))
    for i in range(num_iters):
        g = grad(x, i)
        if callback: callback(x, i, g)
        #self.velocity = self.mass * self.velocity + lr * gradient_vec 
        velocity = mass * velocity - (1.0 - mass) * g
        step_size = lr_fun(i)
        x += step_size * velocity
    return x

def rmsprop(grad, x, callback=None, num_iters=100, lr_fun=const_lr(), gamma=0.9, eps = 10**-8):
    """Root mean squared prop: See Adagrad paper for details."""
    avg_sq_grad = np.ones(len(x))
    for i in range(num_iters):
        g = grad(x, i)
        if callback: callback(x, i, g)
        avg_sq_grad = avg_sq_grad * gamma + g**2 * (1 - gamma)
        step_size = lr_fun(i)
        x -= step_size * g/(np.sqrt(avg_sq_grad) + eps)
    return x

def adam(grad, x, callback=None, num_iters=100, lr_fun=const_lr(), b1=0.9, b2=0.999, eps=10**-8):
    """Adam as described in http://arxiv.org/pdf/1412.6980.pdf.
    It's basically RMSprop with momentum and some correction terms."""
    print 'adam b1 {:0.3f}'.format(b1)
    m = np.zeros(len(x))
    v = np.zeros(len(x))
    for i in range(num_iters):
        g = grad(x, i)
        if callback: callback(x, i, g)
        m = (1 - b1) * g      + b1 * m  # First  moment estimate.
        v = (1 - b2) * (g**2) + b2 * v  # Second moment estimate.
        mhat = m / (1 - b1**(i + 1))    # Bias correction.
        vhat = v / (1 - b2**(i + 1))
        step_size = lr_fun(i)
        x -= step_size*mhat/(np.sqrt(vhat) + eps)
    return x

    
def autoadam(grad, x, callback, max_iters, param_eval_fun, method='grid', min_lr=1e-4, max_lr=1, \
            b1=0.9, b2=0.999, eps=10**-8):
    max_iters_tuning = int(np.ceil(max_iters * 0.1))
    def lr_eval_fun(lr):
        params = adam(grad, x, None, max_iters_tuning, const_lr(lr), b1, b2, eps)
        return param_eval_fun(params)
    if method == 'grid':
        candidate_lrs = np.linspace(min_lr, max_lr, 5)
        lr, scores = grid_search_1d(lr_eval_fun, candidate_lrs)
    else:
        res = minimize_scalar(lr_eval_fun, bounds=[min_lr, max_lr], method='bounded', \
                options = {'maxiter': 5, 'xatol': 1e-2, 'disp': False})
        scores = []
        lr = res.x
    params = adam(grad, x, callback, max_iters, const_lr(lr), b1, b2, eps)
    return params, lr, scores

def bfgs_fit(params, obj_fun, grad_fun, args=None, callback_fun=None):
    '''This wraps scipy.minimize. So callback has the signature 
    callback(params).'''
    result = minimize(obj_fun, params, args, method='BFGS', jac=grad_fun,
            callback=callback_fun)
    return result.x, result.fun
    
# Modified from 
# https://github.com/HIPS/neural-fingerprint/blob/2003a28d5ae4a78d99fdc06db8671b994f88c5a6/neuralfingerprint/optimizers.py
def bfgs(obj_and_grad, x, callback=None, num_iters=100):
    '''This uses callback(params, iter, grad)'''
    def epoch_counter():
        epoch = 0
        while True:
            yield epoch
            epoch += 1
    ec = epoch_counter()
    wrapped_callback=None
    if callback:
        def wrapped_callback(params):
            res = obj_and_grad(params)
            grad = res[1]
            callback(params, next(ec), grad)
    res =  minimize(fun=obj_and_grad, x0=x, jac =True, callback=wrapped_callback,
                    method = 'BFGS', options = {'maxiter':num_iters, 'disp':True, 'gtol': 1e-3})
    return res.x
    


######
# From https://github.com/HIPS/neural-fingerprint/blob/2003a28d5ae4a78d99fdc06db8671b994f88c5a6/neuralfingerprint/util.py#L126-L138
def get_ith_minibatch_ixs(i, num_datapoints, batch_size):
    num_minibatches = num_datapoints / batch_size + ((num_datapoints % batch_size) > 0)
    i = i % num_minibatches
    start = i * batch_size
    stop = start + batch_size
    return slice(start, stop)

def build_batched_grad(grad, batch_size, inputs, targets):
    """Grad has signature(weights, inputs, targets)."""
    def batched_grad(weights, i):
        cur_idxs = get_ith_minibatch_ixs(i, len(targets), batch_size)
        return grad(weights, inputs[cur_idxs], targets[cur_idxs])
    return batched_grad
    
