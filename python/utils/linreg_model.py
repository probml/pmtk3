import autograd.numpy as np  # Thinly-wrapped numpy
from utils.optim_util import squared_loss

class LinregModel(object):
    '''Linear regression class.
    In the functions below, we assume X is N*D, and params is D*1'''
    def __init__(self):
        pass
        
    @staticmethod
    def prediction(params, X):
        if len(X.shape)==1:
            # Add columns of 1s (we assume params[0] is bias term)
            N = X.shape[0]
            X = np.c_[np.ones(N), X]
        yhat = np.dot(X, params)
        return yhat
    
    @staticmethod
    def objective(params, X, y):
        return squared_loss(LinregModel.prediction(params, X), y)
        
    @staticmethod
    def gradient(params, X, y):
        # gradient of objective = (1/N) sum_n x(n,:)*yerr(n)   // row vector
        y_pred = LinregModel.prediction(params, X)
        N = y.shape[0]
        yerr = np.reshape((y_pred - y), (N, 1))
        gradient = np.sum(X * yerr, 0)/N # broadcast yerr along columns
        return gradient
  
    @staticmethod 
    def ols_fit(Xtrain, ytrain):
        w_ols = np.linalg.lstsq(Xtrain, ytrain)[0]
        loss_ols = squared_loss(LinregModel.prediction(w_ols, Xtrain), ytrain)
        return w_ols, loss_ols
 