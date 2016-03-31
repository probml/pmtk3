# Fit various models using sgd

#import numpy as np
import autograd
import autograd.numpy as np
import matplotlib.pyplot as plt
import os
import demos.linreg_1d_plot_demo as demo
import utils.util as util
import utils.optim_util as opt
from utils.linreg_model import LinregModel
from utils.mlp_model import MLP

def lr_fun_to_str(config):
    cstr = 'LR'
    if config.has_key('lr_fun'):
        cstr = cstr + config['lr_fun']
    if config.has_key('init_lr'):
        cstr = cstr + '{:0.3f}'.format(config['init_lr'])
    return cstr

def config_to_str(config):
    cstr0 = '{}-{}'.format(config['fun_type'], config['model_type'])
    if config['optimizer'] == 'BFGS':
        cstr = cstr0 + '-BFGS'
    else:
        if config['batch_size'] == config['N']:
            batch_str = 'N'
        else:
            batch_str = '{}'.format(config['batch_size'])
        cstr_batch = 'batch{}'.format(batch_str)
        cstr_lr = lr_fun_to_str(config)
        cstr = '-'.join([cstr0, cstr_batch, cstr_lr, config['sgd-method']]) 
    return cstr

        
def run_expt(config, loss_opt=0):
    ttl = config_to_str(config)
    print '\nstarting experiment {}'.format(ttl)
    print config
    
    Xtrain, Ytrain, params_true, true_fun, fun_name = demo.make_data_linreg_1d(config['N'], config['fun_type'])
    data_dim = Xtrain.shape[1]
    N = Xtrain.shape[0]
    Xtrain, Ytrain = opt.shuffle_data(Xtrain, Ytrain)
        
    model_type = config['model_type']
    if model_type == 'linear':
        model = LinregModel(data_dim, add_ones=True)
        params, loss = model.ols_fit(Xtrain, Ytrain)
    elif model_type[0:3] == 'mlp':
        _, layer_sizes = model_type.split(':')
        layer_sizes = [int(n) for n in layer_sizes.split('-')]
        model = MLP(layer_sizes, 'regression', L2_reg=0.001, Ntrain=N) 
    else:
        raise ValueError('unknown model type {}'.format(model_type))
            
    initial_params = model.init_params() 
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
        obj_fun = lambda params: model.PNLL(params, Xtrain, Ytrain)
        logger = opt.OptimLogger(lambda params, iter: obj_fun(params), store_freq=1, print_freq=10)   
        params = opt.bfgs(autograd.value_and_grad(obj_fun), initial_params, logger.callback, config['num_epochs'])
                     
    if config['optimizer'] == 'SGD':
        B = config['batch_size']
        M = N / B # num_minibatches_per_epoch (num iter per epoch)
        max_iters = config['num_epochs'] * M
        
        grad_fun = opt.build_batched_grad(model.gradient, config['batch_size'], Xtrain, Ytrain)
        #obj_fun = opt.build_batched_grad(model.PNLL, config['batch_size'], Xtrain, Ytrain)
        obj_fun = lambda params, iter: model.PNLL(params, Xtrain, Ytrain)
        logger = opt.OptimLogger(obj_fun, store_freq=M, print_freq=M*10, store_params=plot_params)         
            
        if config.has_key('lr_fun'):
            if config['lr_fun'] == 'exp':
                lr_fun = lambda iter: opt.lr_exp_decay(iter, config['init_lr'], config['lr_decay']) 
            elif config['lr_fun'] == 'const':
                lr_fun = opt.const_lr(config['init_lr']) 
            else:
                raise ValueError('Unknown lr-fun {}'.format(lr_fun))

        #sgd_fun = config['sgd-fun']
        #params = sgd_fun(grad_fun, initial_params, logger.callback, \
        #    max_iters, lr_fun, *config['args'])
        
        if config['sgd-method'] == 'momentum':
            params = opt.sgd(grad_fun, initial_params, logger.callback, \
            max_iters, lr_fun, config['mass'])
        elif config['sgd-method'] == 'RMSprop':
            params = opt.rmsprop(grad_fun, initial_params, logger.callback, \
                max_iters, lr_fun, config['grad_sq_decay'])
        elif config['sgd-method'] == 'ADAM':
            params = opt.adam(grad_fun, initial_params, logger.callback, \
                max_iters, lr_fun, config['grad_decay'], config['grad_sq_decay'])
        elif config['sgd-method'] == 'AutoADAM':
            eval_fn = lambda params: model.PNLL(params, Xtrain, Ytrain)
            params, lr, scores = opt.autoadam(grad_fun, initial_params, logger.callback, \
                max_iters, eval_fn, config['auto-method'])
            config['init_lr'] = lr
            config['lr_fun'] = 'const'
            ttl = config_to_str(config)
            print 'autoadam: chose {:0.3f} as lr'.format(lr)
            print scores
        else:
            raise ValueError('Unknown SGD method {}'.format(config['method']))
        
            

    training_loss = model.PNLL(params, Xtrain, Ytrain)
    print 'finished fitting, training loss {:0.3f}, {} obj calls, {} grad calls'.\
        format(training_loss, model.num_obj_fun_calls, model.num_grad_fun_calls)
    
    fig = plt.figure()
    ax = fig.add_subplot(plot_rows, plot_cols, 1)
    opt.plot_loss_trace(logger.obj_trace, loss_opt, ax)
    ax.set_title('final objective {:0.3f}'.format(training_loss))
    ax.set_xlabel('epochs')
    
    ax = fig.add_subplot(plot_rows, plot_cols, 2)
    ax.plot(logger.grad_norm_trace)
    ax.set_title('gradient norm vs num updates')
    
    if plot_data:
        ax = fig.add_subplot(plot_rows, plot_cols, 3)
        predict_fun = lambda X: model.predictions(params, X)
        demo.plot_data_and_predictions_1d(Xtrain, Ytrain, true_fun, predict_fun, ax)
    
    if plot_params:
        ax = fig.add_subplot(plot_rows, plot_cols, 4)
        loss_fun = lambda w0, w1: model.PNLL(np.array([w0, w1]), Xtrain, Ytrain)
        demo.plot_error_surface_2d(loss_fun, params, params_true, config['fun_type'], ax)
        demo.plot_param_trace_2d(logger.param_trace, ax)        
        
    fig.suptitle(ttl)
    folder = 'figures/linreg-sgd'        
    fname = os.path.join(folder, 'linreg_1d_sgd_{}.png'.format(ttl))
    plt.savefig(fname)
    return training_loss
  

         
              
def main():
    N = 50
    num_epochs = 100
   
    #fun_type = 'linear-uncentered'
    #fun_type = 'sine'
    fun_type = 'quad'
    
    model_type = 'mlp:1-10-1'
                
    bfgs_config = {'fun_type': fun_type, 'N': N, 'model_type': model_type, 
                    'optimizer': 'BFGS', 'num_epochs': num_epochs}
    np.random.seed(1)           
    loss_opt = run_expt(bfgs_config)
           
    configs = []                                                                                    

    configs.append({'fun_type': fun_type, 'N': N, 'model_type': model_type,  
                'optimizer': 'SGD', 'batch_size': 10,  'num_epochs': num_epochs,
                'lr_fun': 'const', 'init_lr': 0.005,  
                'sgd-method': 'ADAM',
                'grad_decay': 0.9, 'grad_sq_decay': 0.999})
    
    '''
    configs.append({'fun_type': fun_type, 'N': N, 'model_type': model_type,  
                'optimizer': 'SGD', 'batch_size': 10,  'num_epochs': num_epochs,
                'lr_fun': 'const', 'init_lr': 0.005,  
                'sgd-fun': opt.adam, 'sgd-method': 'ADAM',
                'args': {'grad_decay': 0.9, 'grad_sq_decay': 0.999}})
    '''
          
    configs.append({'fun_type': fun_type, 'N': N, 'model_type': model_type,  
                'optimizer': 'SGD', 'batch_size': 10,  'num_epochs': num_epochs,  
                'sgd-method': 'AutoADAM',  'auto-method': 'bounded',
                'grad_decay': 0.9, 'grad_sq_decay': 0.999})
    
                
    for expt_num, config in enumerate(configs):
        np.random.seed(1)
        run_expt(config, loss_opt)
      
    plt.show()


if __name__ == "__main__":
    main()
 