# 1d linear regression using batch optimization

import autograd
import autograd.numpy as np
#import numpy as np
import matplotlib.pyplot as plt

from utils.optim_util import bfgs_fit, MinimizeLogger, plot_loss_trace, plot_param_trace
from demos.linreg_1d_plot_demo import plot_error_surface, make_data_linreg_1d
from utils.linreg_model import LinregModel
    
def main():
    np.random.seed(1)
    xtrain, ytrain, params_true = make_data_linreg_1d()
    N = xtrain.shape[0]
    D = 2
    Xtrain = np.c_[np.ones(N), xtrain] # add column of 1s
    
    params_init = np.zeros(D)
    logger = MinimizeLogger(LinregModel.objective, (Xtrain, ytrain), print_freq=10)
    
    params_ols, loss_ols = LinregModel.ols_fit(Xtrain, ytrain)
    #obj_fun = lambda params: LinregModel.objective(params, Xtrain, ytrain)
    #grad_fun = lambda params: LinregModel.gradient(params, Xtrain, ytrain)
    obj_fun = LinregModel.objective
    grad_fun = LinregModel.gradient
    params_bfgs, loss_bfgs, logger = bfgs_fit(params_init, obj_fun, grad_fun, (Xtrain, ytrain), logger) 
    assert(np.allclose(params_bfgs, params_ols))
    assert(np.allclose(loss_bfgs, loss_ols))

    
    grad_fun = autograd.grad(obj_fun)
    params_autograd, loss_autograd = bfgs_fit(params_init, obj_fun, grad_fun, (Xtrain, ytrain)) 
    assert(np.allclose(params_bfgs, params_autograd))
    assert(np.allclose(loss_bfgs, loss_autograd))
    
    print "All assertions passed"

    print logger.obj_trace
    ax = plot_loss_trace(logger.obj_trace, loss_ols) 
    ax.set_title('BFGS')
    
    loss_fun = lambda w0, w1: LinregModel.objective([w0, w1], xtrain, ytrain)
    ax = plot_error_surface(loss_fun, params_true)
    plot_param_trace(logger.param_trace, ax)
    ax.set_title('BFGS')
    plt.show()
    
if __name__ == "__main__":
    main()
    