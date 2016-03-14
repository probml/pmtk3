# 1d linear regression using SGD

#import numpy as np
import autograd
import autograd.numpy as np
import matplotlib.pyplot as plt
import os
from demos.linreg_1d_plot_demo import plot_error_surface, make_data_linreg_1d
from utils.util import nsubplots
import utils.sgd_util as sgd
from utils.optim_util import plot_loss_trace, plot_param_trace
from utils.linreg_model import LinregModel

def make_expt_config(N):
    batch_sizes = [N, 10]
    lr_decays = [0.99]
    momentums = [0, 0.9]
    init_lr = 0.005
    n_steps = 200
    expt_config = []
    for batch_size in batch_sizes:
        for lr_decay in lr_decays:
            for momentum in momentums:
                config = {'batch_size': batch_size, 'lr_decay': lr_decay,
                    'momentum': momentum,
                    'init_lr': init_lr, 'n_steps': n_steps, 'N': N}
                expt_config.append(config)
    return expt_config
    
def config_to_str(config):
    batch_size_frac = config['batch_size'] / np.float(config['N'])
    cstr = 'B{:0.2f}-L{:0.2f}-M{}'.format(batch_size_frac, config['lr_decay'],
            config['momentum'])
    return cstr
            
def main():
    np.random.seed(1)
    xtrain, ytrain, params_true = make_data_linreg_1d()
    N = xtrain.shape[0]
    Xtrain = np.c_[np.ones(N), xtrain] # add column of 1s
    w_ols, loss_ols = LinregModel.ols_fit(Xtrain, ytrain)
    
    expt_configs = make_expt_config(N)
    nexpts = len(expt_configs)
    print nexpts
    
    nrows, ncols = nsubplots(nexpts)
    #nrows, ncols = 4, 2
    loss_trace_fig = plt.figure("loss trace fig")
    param_trace_fig = plt.figure("param trace fig")
    folder = 'figures'
    
    for expt_num, config in enumerate(expt_configs):
        logger = sgd.SGDLogger(print_freq=10)
        np.random.seed(1)
        batchifier = sgd.MiniBatcher(Xtrain, ytrain, config['batch_size'])
        initial_params = np.zeros(2) 
        lr_fun = lambda(iter): sgd.get_learning_rate_exp_decay(iter,
                    config['init_lr'], config['lr_decay']) 
       
        ttl = config_to_str(config)
        print '\nstarting experiment {}'.format(ttl)
        print config

        obj_fun = LinregModel.objective
        #grad_fun = LinregModel.gradient
        grad_fun = autograd.grad(obj_fun)
        result = sgd.sgd_minimize(initial_params, obj_fun, grad_fun,
            batchifier, config['n_steps'], lr_fun, config['momentum'],
            callback=logger.update)
        print result
                
        plotnum = expt_num + 1
        ax = loss_trace_fig.add_subplot(nrows, ncols, plotnum)
        plot_loss_trace(logger.obj_trace, loss_ols, ax)
        ax.set_title(ttl)
        
        ax = param_trace_fig.add_subplot(nrows, ncols, plotnum)
        loss_fun = lambda w0, w1: LinregModel.objective([w0, w1], xtrain, ytrain)
        plot_error_surface(loss_fun, params_true, ax)
        plot_param_trace(logger.param_trace, ax) 
        ax.set_title(ttl)
                
    plt.figure("loss trace fig")         
    fname = os.path.join(folder, 'linreg_1d_sgd_loss_trace.png')
    plt.savefig(fname)
    
    plt.figure("param trace fig")         
    fname = os.path.join(folder, 'linreg_1d_sgd_param_trace.png')
    plt.savefig(fname)
    
    plt.show()


if __name__ == "__main__":
    main()
 