# 1d linear regression.
# Make the data and plot it.

import autograd.numpy as np  # Thinly-wrapped numpy
#import numpy as np
import matplotlib.pyplot as plt
from utils.linreg_model import LinregModel

# Sample (x,y) pairs from a straight line or a sine wave (plus noise). 
def make_data_linreg_1d(N=21, linear=True):
    xtrain = np.linspace(0, 20, N)
    sigma2 = 2
    w_true = np.array([-1.5, 1/9.])
    if linear:
        fun = lambda x: w_true[0] + w_true[1]*x
    else:
        fun = lambda x: w_true[0] + w_true[1]*np.sin(x)
    noise = np.random.normal(0, 1, xtrain.shape) * np.sqrt(sigma2)
    ytrain = fun(xtrain) + noise    
    return xtrain, ytrain, w_true

# Plot 2d error surface around model's parameter vaulues
def plot_error_surface(loss_fun, params, ax=None):
    if ax is None:
        fig = plt.figure()
        ax = fig.add_subplot(111)
    w0s = np.linspace(-2*params[0], 2*params[0], 10)
    w1s = np.linspace(-2*params[1], 2*params[1], 10)
    w0_grid, w1_grid = np.meshgrid(w0s, w1s)
    lossvec = np.vectorize(loss_fun)
    z = lossvec(w0_grid, w1_grid)
    cs = ax.contour(w0s, w1s, z)
    ax.clabel(cs)
    ax.plot(params[0], params[1], 'rx', markersize=14)
    return ax

# Function to plot the observed data and predictions
def plot_data_and_pred(x, y, predict_fun, draw_verticals=True):
    x_range = np.linspace(np.min(x), np.max(x), 100)
    yhat_range = predict_fun(x_range)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(x, y, 'o', label='observed')
    ax.plot(x_range, yhat_range, 'r-', label='predicted')
    if draw_verticals: # from observed value to predicted true
        yhat_sparse = predict_fun(x)
        for x0, y0, yhat0 in zip(x, y, yhat_sparse):
            ax.plot([x0, x0],[y0, yhat0],'k-')
    plt.legend() #[line_pred, line_true], ['predicted', 'true'])
    
def main():
    np.random.seed(1)
    xtrain, ytrain, params_true = make_data_linreg_1d()
    predict_fun = lambda x: LinregModel.prediction(params_true, x)
    plot_data_and_pred(xtrain, ytrain, predict_fun)
    loss_fun = lambda w0, w1: LinregModel.objective([w0, w1], xtrain, ytrain)
    plot_error_surface(loss_fun, params_true)
    plt.show()
    
if __name__ == "__main__":
    main()
    