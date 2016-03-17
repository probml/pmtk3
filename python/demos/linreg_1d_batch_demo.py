# 1d linear regression using batch optimization

import autograd
import autograd.numpy as np
import autograd.util 


from utils.optim_util import bfgs_fit
from demos.linreg_1d_plot_demo import  make_data_linreg_1d
from utils.linreg_model import LinregModel
    
def main():
    np.random.seed(1)
    xtrain, Xtrain, ytrain, params_true, true_fun, ttl = make_data_linreg_1d(21, 'linear')
    
    model = LinregModel(1, True)
    params_init = model.init_params()
    print model
    
    # Check that OLS and BFGS give same result
    params_ols, loss_ols = model.ols_fit(Xtrain, ytrain)
    obj_fun = model.objective
    grad_fun = model.gradient
    params_bfgs, loss_bfgs = bfgs_fit(params_init, obj_fun, grad_fun, (Xtrain, ytrain)) 
    assert(np.allclose(params_bfgs, params_ols))
    assert(np.allclose(loss_bfgs, loss_ols))

    # Check that analytic gradient and automatic gradient give same result
    # when evaluated on training data
    grad_fun = autograd.grad(obj_fun)
    grad_auto = grad_fun(params_init, xtrain, ytrain)
    grad_finite_diff = autograd.util.nd(lambda p : obj_fun(p, Xtrain, ytrain), params_init)[0]
    grad_analytic = model.gradient(params_init, Xtrain, ytrain)
    assert(np.allclose(grad_auto, grad_finite_diff))
    assert(np.allclose(grad_auto, grad_analytic))

    params_autograd, loss_autograd = bfgs_fit(params_init, obj_fun, grad_fun, (Xtrain, ytrain)) 
    assert(np.allclose(params_bfgs, params_autograd))
    assert(np.allclose(loss_bfgs, loss_autograd))
    
    print "All assertions passed"

    
if __name__ == "__main__":
    main()
    