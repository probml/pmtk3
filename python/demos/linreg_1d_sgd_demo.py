# 1d linear regression using SGD

#import numpy as np
import autograd
import autograd.numpy as np
import matplotlib.pyplot as plt
import os
from demos.linreg_1d_plot_demo import plot_error_surface, make_data_linreg_1d, plot_data_and_predictions
import utils.util as util
import utils.sgd_util as sgd
from utils.optim_util import plot_loss_trace, plot_param_trace, bfgs_fit, MinimizeLogger
from utils.linreg_model import LinregModel
from utils.mlp_model import MLP

def make_expt_config(N):
    batch_sizes = [N, 10]
    lr_decays = [0.99]
    momentums = [0, 0.9]
    init_lr = 0.005
    num_epochs = 20
    expt_config = []
    for batch_size in batch_sizes:
        for lr_decay in lr_decays:
            for momentum in momentums:
                config = {'batch_size': batch_size, 'lr_decay': lr_decay,
                    'momentum': momentum, 'optimizer': 'SGD',
                    'init_lr': init_lr, 'num_epochs': num_epochs, 'N': N}
                expt_config.append(config)
    return expt_config
    
def config_to_str(config):
    if config['optimizer'] == 'BFGS':
        cstr = '{}-{}-BFGS'.format(config['data_generator'],
                    config['model'])
    else:
        if config['batch_size'] == config['N']:
            batch_str = 'N'
        else:
            batch_str = '{}'.format(config['batch_size'])
        cstr1 = '{}-{}-batch{}-LR{:0.3f}-LRdecay{:0.3f}'.format(config['data_generator'],
                    config['model'], batch_str, config['init_lr'], config['lr_decay'])
        cstr2 = ''
        if config['method'] == 'momentum':
            cstr2 = 'mom{}'.format(config['mass'])
        if config['method'] == 'RMSprop':
            cstr2 = 'RMS{:0.3f}'.format(config['grad_sq_decay'])
        if config['method'] == 'ADAM':
            cstr2 = 'ADAM-{:0.3f}-{:0.3f}'.format(config['grad_decay'], config['grad_sq_decay'])
        cstr = cstr1 + '-' + cstr2
    return cstr
            
def main():
    np.random.seed(1)
    folder = 'figures/linreg-sgd'
    if not os.path.exists(folder):
      os.mkdir('figures')
      os.mkdir('figures/linreg-sgd')

    N = 50
    init_lr = 0.05
    num_epochs = 50
   
    #fun_type = 'linear'
    #fun_type = 'sine'
    fun_type = 'quad'
    
    #model_type = 'linear'
    model_type = 'mlp:1-10-1'
                
    configs = []
    # BFGS has to be the first config, in order to compute loss_opt
    configs.append({'data_generator': fun_type,
                    'N': N,
                    'model': model_type,
                    'optimizer': 'BFGS'})

    configs.append({'data_generator': fun_type,
                    'N': N,
                    'model': model_type,
                    'optimizer': 'SGD',
                    'batch_size': 10,
                    'num_epochs': num_epochs,
                    'init_lr': init_lr,
                    'lr_decay': 0.9,
                    'method': 'momentum',
                    'mass': 0})

    configs.append({'data_generator': fun_type,
                    'N': N,
                    'model': model_type,
                    'optimizer': 'SGD',
                    'batch_size': 10,
                    'num_epochs': num_epochs,
                    'init_lr': init_lr,
                    'lr_decay': 0.9,
                    'method': 'momentum',
                    'mass': 0.9})

    configs.append({'data_generator': fun_type,
                    'N': N,
                    'model': model_type,
                    'optimizer': 'SGD',
                    'batch_size': 10,
                    'num_epochs': num_epochs,
                    'init_lr': init_lr,
                    'lr_decay': 0.9,
                    'method': 'RMSprop',
                    'grad_sq_decay': 0.9})

    configs.append({'data_generator': fun_type,
                    'N': N,
                    'model': model_type,
                    'optimizer': 'SGD',
                    'batch_size': 10,
                    'num_epochs': num_epochs,
                    'init_lr': init_lr,
                    'lr_decay': 0,
                    'method': 'ADAM',
                    'grad_decay': 0.9,
                    'grad_sq_decay': 0.999})
  
    params_opt = None
    loss_opt = None
    for expt_num, config in enumerate(configs):
        np.random.seed(1)
        ttl = config_to_str(config)
        print '\nstarting experiment {}'.format(ttl)
        print config
        
        xtrain, Xtrain, ytrain, params_true, true_fun, fun_name = make_data_linreg_1d(config['N'], config['data_generator'])
        data_dim = Xtrain.shape[1]
        
        if model_type == 'linear':
            model = LinregModel(data_dim, add_ones=True)
            params_opt, loss_opt = model.ols_fit(Xtrain, ytrain)
        elif model_type[0:3] == 'mlp':
            _, layer_sizes = model_type.split(':')
            layer_sizes = [int(n) for n in layer_sizes.split('-')]
            model = MLP(layer_sizes, 'regression', L2_reg=0.001) 
        else:
             raise ValueError('unknown model type {}'.format(model_type))
                
        initial_params = model.init_params() 
        obj_fun = model.objective
        grad_fun = autograd.grad(obj_fun)
        
        param_dim = len(initial_params)
        plot_data = (data_dim == 1)
        plot_params = (param_dim == 2)
        nplots = 2
        if plot_data: 
            nplots += 1
        if plot_params:
            nplots += 1
        plot_rows, plot_cols = util.nsubplots(nplots)
         
        if config['optimizer'] == 'BFGS':
            logger = MinimizeLogger(obj_fun, grad_fun, (Xtrain, ytrain), print_freq=1, store_params=True)
            params, loss = bfgs_fit(initial_params, obj_fun, grad_fun, (Xtrain, ytrain), logger.update) 
            loss_avg = loss
            if params_opt is None:
                params_opt = params
                loss_opt = loss
                
        if config['optimizer'] == 'SGD':
            logger = sgd.SGDLogger(print_freq=20, store_params=True)
            lr_fun = lambda iter, epoch: sgd.lr_exp_decay(iter, config['init_lr'], config['lr_decay']) 
            
            if config['method'] == 'momentum':
                sgd_updater = sgd.SGDMomentum(lr_fun, config['mass'])
            if config['method'] == 'RMSprop':
                sgd_updater = sgd.RMSprop(lr_fun, config['grad_sq_decay'])
            if config['method'] == 'ADAM':
                sgd_updater = sgd.ADAM(config['init_lr'], config['grad_decay'], config['grad_sq_decay'])
                
            params, params_avg, loss_on_batch = sgd.sgd_minimize(initial_params, obj_fun, grad_fun,
                Xtrain, ytrain, config['batch_size'], config['num_epochs'], 
                sgd_updater, logger.update)
            loss = obj_fun(params, Xtrain, ytrain)
            loss_avg = obj_fun(params_avg, Xtrain, ytrain)
                        
                   
        fig = plt.figure()
        ax = fig.add_subplot(plot_rows, plot_cols, 1)
        plot_loss_trace(logger.obj_trace, loss_opt, ax)
        ax.set_title('final objective {:0.3f}, {:0.3f}'.format(loss, loss_avg))
        
        ax = fig.add_subplot(plot_rows, plot_cols, 2)
        ax.plot(logger.grad_norm_trace)
        ax.set_title('gradient norm vs num updates')
        
        if plot_data:
            ax = fig.add_subplot(plot_rows, plot_cols, 3)
            predict_fun = lambda X: model.prediction(params, X)
            plot_data_and_predictions(xtrain, ytrain, true_fun, predict_fun, ax)
        
        if plot_params:
            ax = fig.add_subplot(plot_rows, plot_cols, 4)
            loss_fun = lambda w0, w1: model.objective([w0, w1], xtrain, ytrain)
            plot_error_surface(loss_fun, params_opt, params_true, fun_type, ax)
            plot_param_trace(logger.param_trace, ax)        
         
        fig.suptitle(ttl)
        fname = os.path.join(folder, 'linreg_1d_sgd_{}.png'.format(ttl))
        plt.savefig(fname)
    
    plt.show()


if __name__ == "__main__":
    main()
 