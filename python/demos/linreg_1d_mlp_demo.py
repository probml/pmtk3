# MLP with no hidden layers, applied to 1d data.
# Should give same results as a linear model.

import autograd
import autograd.numpy as np
import autograd.util 
import matplotlib.pyplot as plt

from utils.optim_util import bfgs_fit, MinimizeLogger, plot_loss_trace, plot_param_trace
from demos.linreg_1d_plot_demo import plot_error_surface, make_data_linreg_1d
from utils.linreg_model import LinregModel
from utils.mlp_model import MLP

def main():
    np.random.seed(1)
    N = 50
    use_linear = False
    xtrain, Xtrain, ytrain, params_true, true_fun, fun_name = make_data_linreg_1d(N, use_linear)
    D = 1
    layer_sizes = [D, 1] # 1-dim  input, 1d output,  no hidden layers
    
    model = MLP(layer_sizes, False, 0)
    params_init = model.init_params() # W, b
    logger = MinimizeLogger(model.objective, (Xtrain, ytrain), print_freq=10)
    
    # Check that OLS and BFGS give same result
    linear_model = LinregModel(D, True)
    params_ols, loss_ols = linear_model.ols_fit(Xtrain, ytrain)
    
    obj_fun = model.objective
    grad_fun = autograd.grad(obj_fun)
    
    # Sanity check. Predictions only match if params_init is same order.
    lm_pred = linear_model.prediction(params_init, Xtrain)
    mlp_pred = model.prediction(params_init, Xtrain)
    assert(np.allclose(np.ravel(lm_pred), np.ravel(mlp_pred)))
    lm_loss = linear_model.objective(params_init, Xtrain, ytrain)
    mlp_loss = model.objective(params_init, Xtrain, ytrain)
    assert(np.allclose(lm_loss, mlp_loss))
    
    # End to end check
    params_bfgs, loss_bfgs, logger = bfgs_fit(params_init, obj_fun, grad_fun, (Xtrain, ytrain), logger)
    assert(np.allclose(params_bfgs, params_ols))
    assert(np.allclose(loss_bfgs, loss_ols))
  
    
    print "All assertions passed"

    # Plot loss vs time
    print logger.obj_trace
    ax = plot_loss_trace(logger.obj_trace, loss_ols) 
    ax.set_title('BFGS')
    
    # Plot 2d trajectory of parameter values over time
    # Note that params = [ W, b ]
    loss_fun = lambda w0, w1: model.objective(np.array([w0, w1]), Xtrain, ytrain)
    ax = plot_error_surface(loss_fun, params_ols)
    plot_param_trace(logger.param_trace, ax)
    ax.set_title('BFGS')
    plt.show()
    
if __name__ == "__main__":
    main()
    