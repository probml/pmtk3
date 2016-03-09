# 1d linear regression using SGD

import numpy as np
import matplotlib.pyplot as plt
import os
from demos.linreg_1d_batch_demo import *
from utils.util import *
from utils.optim_util import *

def main():
    np.random.seed(1)
    xtrain, ytrain, w_true = make_data_linreg_1d()
    N = xtrain.shape[0]
    Xtrain = np.c_[np.ones(N), xtrain] # add column of 1s
    w_ols, loss_ols = ols_fit(Xtrain, ytrain, np.zeros(2))
    
    init_lr = 0.01
    n_steps = 200
    batch_sizes = [N, 10]
    lr_decays = [1, 0.99]
    momentums = [True]
    folder = '/Users/kpmurphy/github/pmtk3/python/figures/'
    nexpts = len(batch_sizes) * len(lr_decays) * len(momentums)
    nrows, ncols = nsubplots(nexpts)
    #nrows, ncols = 4, 2
    loss_trace_fig = plt.figure("loss trace fig")
    param_trace_fig = plt.figure("param trace fig")
    expt = 1
    for batch_size in batch_sizes:
        for lr_decay in lr_decays:
            for momentum in momentums:
                logger = SGDLogger(print_freq=10)
                np.random.seed(1)
                batchifier = MiniBatcher(Xtrain, ytrain, batch_size)
                initial_params = np.zeros(2) 
                lr_fun = lambda(iter): get_learning_rate_exp_decay(iter, init_lr, lr_decay) 
                batch_size_frac = batch_size / np.float(N)
                
                ttl = 'B{:0.2f}-L{:0.2f}-M{}'.format(batch_size_frac, lr_decay, momentum)
                print 'starting experiment {}'.format(ttl)
                
                result = sgd_minimize(initial_params, batchifier, n_steps,
                    get_objective, get_gradient, lr_fun, momentum, callback=logger.update)
                #print('final objective {:0.2f}'.format(result.fun))
                #params = result.x 
                           
                ax = loss_trace_fig.add_subplot(nrows, ncols, expt)
                plot_loss_trace(logger.obj_trace, loss_ols, ttl, ax)
                ax = param_trace_fig.add_subplot(nrows, ncols, expt)
                plot_error_surface_and_param_trace(xtrain, ytrain, w_true, logger.param_trace, ttl, ax) 
                expt += 1
                
    plt.figure("loss trace fig")       
    suffix = '-M{}'.format(momentums[0])    
    fname = os.path.join(folder, 'linreg_1d_sgd_loss_trace{}.png'.format(suffix))
    plt.savefig(fname)
    
    plt.figure("param trace fig") 
    suffix = '-M{}'.format(momentums[0])          
    fname = os.path.join(folder, 'linreg_1d_sgd_param_trace{}.png'.format(suffix))
    plt.savefig(fname)
    
    plt.show()

if __name__ == "__main__":
    main()
 