# 1d linear regression.
# Make the data and plot it.

import numpy as np
import matplotlib.pyplot as plt
from utils.linreg_model import LinregModel

def make_fun_1d(fun_type):
    if fun_type == 'linear':
        params_true = np.array([0.1, -1.5])
        true_fun = lambda x: params_true[1] + params_true[0]*x
        ttl = 'w*x + b'
    if fun_type == 'sine':
        params_true = np.array([1, -1.5])
        true_fun = lambda x: params_true[1] + params_true[0]*np.sin(x)
        ttl = 'w*sin(x) + b' 
    return params_true, true_fun, ttl
        
# Sample (x,y) pairs from a noisy function 
def make_data_linreg_1d(N, fun_type):
    params_true, true_fun, fun_name = make_fun_1d(fun_type) 
    xtrain = np.linspace(0, 20, N)
    ytrain_clean = true_fun(xtrain) 
    sigma2 = 0.5
    noise = np.random.normal(0, 1, xtrain.shape) * np.sqrt(sigma2)
    ytrain_noisy = ytrain_clean + noise   
    Xtrain = np.reshape(xtrain, (N, 1))
    return xtrain, Xtrain, ytrain_noisy, params_true, true_fun, fun_name

# Plot 2d error surface around model's parameter vaulues
def plot_error_surface(loss_fun, params_opt, params_true, ax=None):
    if ax is None:
        fig = plt.figure()
        ax = fig.add_subplot(111) 
    w1s = np.linspace(-2, 1.5, 100)
    w0s = np.linspace(-1, 1, 100)
    w0_grid, w1_grid = np.meshgrid(w0s, w1s)
    lossvec = np.vectorize(loss_fun)
    z = lossvec(w1_grid, w0_grid)
    cs = ax.contour(w1s, w0s, z)
    ax.clabel(cs)
    ax.plot(params_opt[1], params_opt[0], 'rx', markersize=14)
    ax.plot(params_true[1], params_true[0], 'k+', markersize=14)
    return ax

def plot_data_and_predictions(xtrain, ytrain, true_fun, pred_fun, ax=None):
    if ax is None:
        fig = plt.figure()
        ax = fig.add_subplot(111)
    ax.plot(xtrain, ytrain, 'o', label='observed')
    x_range = np.linspace(np.min(xtrain), np.max(xtrain), 100)
    x_range = np.reshape(x_range, [100,1])
    yhat_range = pred_fun(x_range)
    ax.plot(x_range, yhat_range, 'r--', label='predicted')
    y_range = true_fun(x_range)
    ax.plot(x_range, y_range, 'k-', label='truth')
    return ax
    
def main():
    for linear_fun in [True,False]:
        np.random.seed(1)
        N = 50
        xtrain, Xtrain, ytrain, params_true, true_fun, ttl = make_data_linreg_1d(N, linear_fun)
        model = LinregModel(1, True)
        params_ols, loss_ols = model.ols_fit(Xtrain, ytrain)
        
        # Plot data
        predict_fun = lambda x: model.prediction(params_ols, x)
        ax = plot_data_and_predictions(xtrain, ytrain, true_fun, predict_fun)
        ax.set_title(ttl)
        
        # Plot error surface
        loss_fun = lambda w0, w1: model.objective([w0, w1], xtrain, ytrain)
        ax  = plot_error_surface(loss_fun, params_ols)
        ax.set_title(ttl)
    plt.show()
    
if __name__ == "__main__":
    main()
    