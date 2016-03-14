# 1d linear regression using batch optimization

import autograd
import autograd.numpy as np
import autograd.util 
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
    
    # Check that OLS and BFGS give same result
    params_ols, loss_ols = LinregModel.ols_fit(Xtrain, ytrain)
    obj_fun = LinregModel.objective
    grad_fun = LinregModel.gradient
    params_bfgs, loss_bfgs, logger = bfgs_fit(params_init, obj_fun, grad_fun, (Xtrain, ytrain), logger) 
    assert(np.allclose(params_bfgs, params_ols))
    assert(np.allclose(loss_bfgs, loss_ols))

    # Check that analytic gradient and automatic gradient give same result
    grad_fun = autograd.grad(obj_fun)
    grad_auto = grad_fun(params_init, Xtrain, ytrain)
    grad_finite_diff = autograd.util.nd(lambda p : obj_fun(p, Xtrain, ytrain), params_init)[0]
    grad_analytic = LinregModel.gradient(params_init, Xtrain, ytrain)
    assert(np.allclose(grad_auto, grad_finite_diff))
    assert(np.allclose(grad_auto, grad_analytic))

    params_autograd, loss_autograd = bfgs_fit(params_init, obj_fun, grad_fun, (Xtrain, ytrain)) 
    assert(np.allclose(params_bfgs, params_autograd))
    assert(np.allclose(loss_bfgs, loss_autograd))
    
    print "All assertions passed"

    # Plot loss vs time
    print logger.obj_trace
    ax = plot_loss_trace(logger.obj_trace, loss_ols) 
    ax.set_title('BFGS')
    
    # Plot 2d trajectory of parameter values over time
    loss_fun = lambda w0, w1: LinregModel.objective([w0, w1], xtrain, ytrain)
    ax = plot_error_surface(loss_fun, params_true)
    plot_param_trace(logger.param_trace, ax)
    ax.set_title('BFGS')
    plt.show()
    
if __name__ == "__main__":
    main()
    