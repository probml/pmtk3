# 1d linear regression.
# Make the data and plot it.

import numpy as np
import matplotlib.pyplot as plt

# Sample (x,y) pairs from a straight line. 
def make_data_linreg_1d(N=21):
    xtrain = np.linspace(0, 20, N)
    sigma2 = 2
    w_true = np.array([-1.5, 1/9.])
    fun = lambda x: w_true[0] + w_true[1]*x
    noise = np.random.normal(0, 1, xtrain.shape) * np.sqrt(sigma2)
    ytrain = fun(xtrain) + noise    
    return xtrain, ytrain, w_true

def get_prediction(params, X):
    '''x is N*D,  params is D*1.
    Returns N*1 vector'''
    if len(X.shape)==1:
        # Add columns of 1s (we assume params[0] is bias term)
        N = X.shape[0]
        X = np.c_[np.ones(N), X]
    yhat = np.dot(X, params)
    return yhat
    
def get_loss(y_pred, y):
    '''y is N*1, y_pred is N*1.
    Returns scalar'''
    N = y.shape[0]
    return sum(np.square(y - y_pred))/N

def get_objective(params, X, y):
    return get_loss(get_prediction(params, X), y)
        
# Plot error surface
def plot_error_surface(xtrain, ytrain, w, ax=None):
    if ax is None:
        fig = plt.figure()
        ax = fig.add_subplot(111)
    w0s = np.linspace(-2*w[0], 2*w[0], 10)
    w1s = np.linspace(-2*w[1], 2*w[1], 10)
    w0_grid, w1_grid = np.meshgrid(w0s, w1s)
    def loss(w0, w1):
        return get_objective([w0, w1], xtrain, ytrain)
    lossvec = np.vectorize(loss)
    z = lossvec(w0_grid, w1_grid)
    cs = ax.contour(w0s, w1s, z)
    ax.clabel(cs)
    ax.plot(w[0], w[1], 'rx', markersize=14)

# Function to plot the observed data and predictions
def plot_data_and_pred(x, y, coef, draw_verticals=False):
    '''x is N*1, y is N*1, coef is 2*1'''
    x_range = np.linspace(np.min(x), np.max(x), 100)
    yhat_range = get_prediction(coef, x_range)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(x, y, 'o', label='observed')
    ax.plot(x_range, yhat_range, 'r-', label='predicted')
    if draw_verticals: # from observed value to predicted true
        yhat_sparse = get_prediction(coef, x)
        for x0, y0, yhat0 in zip(x, y, yhat_sparse):
            ax.plot([x0, x0],[y0, yhat0],'k-')
    plt.legend() #[line_pred, line_true], ['predicted', 'true'])
    plt.show()
    
def main():
    np.random.seed(1)
    xtrain, ytrain, w_true = make_data_linreg_1d()
    plot_data_and_pred(xtrain, ytrain, w_true, True)
    plot_error_surface(xtrain, ytrain, w_true)

if __name__ == "__main__":
    main()
    