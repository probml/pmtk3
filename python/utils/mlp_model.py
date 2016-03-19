# Multilayer perceptron for regression and classification
# Code based on https://github.com/HIPS/autograd/blob/master/examples/neural_net.py#L19

import autograd.numpy as np  # Thinly-wrapped numpy
from autograd.scipy.misc import logsumexp

def relu(x):
    np.maximum(0, x)

class MLP(object):
    def __init__(self, layer_sizes, output_type='regression', L2_reg=0.001, activation_type='tanh'):
        self.shapes = zip(layer_sizes[:-1], layer_sizes[1:])
        self.nparams = sum((m+1)*n for m, n in self.shapes)
        self.L2_reg = L2_reg
        self.output_type = output_type
        self.activation_type = activation_type

    def objective(self, W_vect, X, Y):
        if self.output_type == 'classification':
            return self.log_loss_classif(W_vect, X, Y)
        else:
            return self.log_loss_regression(W_vect, X, Y)
            
    def prediction(self, W_vect, X):
        if self.output_type == 'classification':
            return np.exp(self.predicted_class_logprobs(W_vect, X))
        else:
            return self.predicted_regression(W_vect, X)
            
    def unpack_layers(self, W_vect):
        '''Generator to return W,b for each layer'''
        for m, n in self.shapes:
            yield W_vect[:m*n].reshape((m,n)), W_vect[m*n:m*n+n]
            W_vect = W_vect[(m+1)*n:]

    def init_params(self):
        param_scale = 0.1
        params = np.random.randn(self.nparams) * param_scale
        return params
        
    def predicted_class_logprobs(self, W_vect, inputs):
        for W, b in self.unpack_layers(W_vect):
            outputs = np.dot(inputs, W) + b
            if self.activation_type == 'tanh':
                inputs = np.tanh(outputs)
            elif self.activation_type == 'relu':
                inputs = relu(outputs)
            else:
                raise ValueException('unknown activation_type {}'.format(self.activation_type))
        return outputs - logsumexp(outputs, axis=1, keepdims=True)
        
    def predicted_regression(self, W_vect, inputs):
        for W, b in self.unpack_layers(W_vect):
            outputs = np.dot(inputs, W) + b
            inputs = np.tanh(outputs)
        return outputs

    def log_loss_classif(self, W_vect, X, Y):
        log_prior = -self.L2_reg * np.dot(W_vect, W_vect)
        log_lik = np.sum(self.predicted_class_logprobs(W_vect, X) * Y)
        return - log_prior - log_lik
        
    def log_loss_regression(self, W_vect, X, Y):
        log_prior = -self.L2_reg * np.dot(W_vect, W_vect)
        Yhat = self.predicted_regression(W_vect, X)
        Y = np.ravel(Y)
        Yhat = np.ravel(Yhat)
        N = X.shape[0]
        log_lik = -0.5*np.sum(np.square(Y - Yhat))/N
        return - log_prior - log_lik   

    
    def classification_err(self, W_vect, X, Y):
        logits = self.predicted_class_logprobs(W_vect, X)
        return np.mean(np.argmax(Y, axis=1) != np.argmax(logits, axis=1))

    