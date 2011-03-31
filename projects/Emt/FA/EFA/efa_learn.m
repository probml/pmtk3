function [models] = efa_learn(X,R, W, params, options)

  [method] = myProcessOptions(options,'method','MM');
  params.N = efa_get_N(X);
  
  %Select and run learning method
  switch(method)
    case 'MM' %Maximize-Maximize method
     models = efa_max_all(X,R, W, params, options);
    case 'SS' %Sample-Sample method
     models = efa_sample_all(X,R, W, params, options);
    case 'SM' %Sample-Maximize method
     models = efa_sample_max(X,R, W, params, options);
  end

end

function model = efa_max_all(X,R, W, params, options);

  %Set optimizer parameters  
  [opt_options.TolFun, opt_options.TolX, opt_options.MaxIter, opt_options.MaxFunEvals, opt_options.display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-6,'MaxIter',2000, 'MaxFunEvals',2000, 'display', 0);
  opt_options.Method    = 'lbfgs';
  opt_options.DerivativeCheck = 'off';

  %Get number of data cases
  N = efa_get_N(X);
  params.N          = N;

  %Initialize W
  if(isempty(W));
    W = efa_init_params(params,'all');
  end

  %Run optimizer
  W = minFunc(@efa_loglik,W,opt_options,X,R,[],params,'all');
  model = efa_unpack_params(W,params,'all');
  model.params = params;
end

function model = efa_sample_max(X,R,W,params,options)

  %Get number of data cases
  N = efa_get_N(X);
  params.N = N;

  %Set optimizer parameters  
  [opt_options.TolFun, opt_options.TolX, opt_options.MaxIter, opt_options.MaxFunEvals, opt_options.display] = myProcessOptions(options, 'TolFun',1e-10, 'TolX', 1e-10,'OptMaxIter',5, 'MaxFunEvals',5, 'display', 0);
  opt_options.Method    = 'lbfgs';
  opt_options.DerivativeCheck = 'off';

  %Set options for sampling latent variables
  [samp_options.numLeaps,samp_options.numIter,samp_options.sampleLag,samp_options.burnin,samp_options.method] = myProcessOptions(options, 'numLeaps',5,'numIter',1,'sampleLag',1,'burnin',0,'infer_method','S');
  NS = samp_options.numIter;

  %Set EM parameters  
  [MaxIter, Tol] = myProcessOptions(options, 'EMMaxIter',100, 'EMTol', 1e-3);
  [make_continuable,debug] = myProcessOptions(options, 'make_continuable',0,'debug',0);

  %Initialize parameters and latent variables
  if(isempty(W))
    W = efa_init_params(params,'all');
  end
  Wz       = W(1:N*(params.K-1));
  Wd       = W(N*(params.K-1)+1:end);
  W        = [];

  %Check if set of latent variables samples and weights were passed in
  %and the make_continuable flag is set. If yes, start from these values. 
  %This is needed to make the algorithm run in sort batches of iterations.
  %Since the current iteration depends on all previous sample and weights
  %and these are not normally output by the algorithm
  if(make_continuable & isfield(params,'Zs'))
    Wda     = params.Wda;
    Zs      = params.Zs;
    ninit   = length(Zs)+1;
    weights = params.weights;
    MaxIter = MaxIter + ninit -1; 
    params  = rmfield(params,{'Zs','weights'});
  else
    ninit = 1;    
    weights  = 1;
  end

  %Run stochastic optimization 
  for n=ninit:MaxIter

    %Unpack parameters
    model = efa_unpack_params(Wd,params,'noZ');
    model.params = params;

    %Sample latent factors given current parameters
    Zsnew  = efa_infer(X, R, Wz(:), model, samp_options);

    %Add to stored latent factors and adjust SA weights
    gamma =  1/(n^0.66);
    Zs((1+(n-1)*NS):n*NS) = Zsnew;
    weights(1:(n-1)*NS) =  (1-gamma)*weights(1:(n-1)*NS);
    weights((1+(n-1)*NS):n*NS) =  gamma/NS;

    %Optimize using weighted set of samples.
    %The flag use_weights must be set to compute
    %a weighted log-likelihood and gradient. It must be
    %subsequently un-set or it will result in correct loglikelihood
    %computations during the subsequent HMC iterations
    ind = 1:n;
    params.weights = weights(ind)/sum(weights(ind));
    params.use_weights = 1;
    [Wd,f(n)] = minFunc(@efa_loglik,Wd(:),opt_options,X,R,Zs(ind),params,'noZ');
    params.use_weights = 0;

     %Store final latent factors from previous inference run
     model.Z = Zs(end).Z; 
     Wz = Zs(end).Z;
     Wz = Wz(:,2:end);

     %Store averaged parameter vector
     if(n>100)
       Wda  = (Wda*(n-101) + Wd)/(n-100);
     else
       Wda  = Wd;
     end 

     %Report current results
     if(mod(n,10)==0)
      model2 = efa_unpack_params(Wda,params,'noZ');
      model2.params = params;
      model2.Z = Zs(end).Z;
      Xhat = efa_predict(X,R,model2,struct('use_old_Z',1));
      err = efa_compute_error(X, Xhat, R);
      fprintf('Iter %d  Obj %f  Err %f\n',n,f(n),err.all)

      if(debug)
        %Plot objective function and re-constructed training data.
	sfigure(999);plot(f);drawnow;
	fs = fields(X);
	for j=1:length(fs)
	  sfigure(1000+j-1);subplot(1,4,1);imagesc(X.(fs{j}));colormap gray;
			subplot(1,4,2); imagesc(Xhat.(fs{j}));colormap gray; 
			subplot(1,4,3); imagesc(model2.Z);colormap gray;
			subplot(1,4,4); imagesc(model2.(fs{j}).beta);colormap gray; 
	end
	drawnow;
      end  
    end

    %Check for convergence
    %Assume converged when relative difference between the mean of the expected complete log 
    %likelihood estimate over iterations (n-10:n) and iterations (n-20:n-11) is less than the 
    %specified tolerance. T  
    if( n>20 & abs(mean(f((n-10):n))-mean(f((n-20):(n-11))))/abs(mean(f((n-20):(n-11))))<Tol)
      break;
    end
  end

  %Converged or out of iterations
  %Store averaged model parameters
  model = efa_unpack_params(Wda,params,'noZ');
  model.Z = Zs(end).Z;
  model.params = params;
  if(make_continuable)
    model.params.Zs = Zs;
    model.params.weights = weights; 
    model.params.Wda = Wda;
  end

end

function [models stats] = efa_sample_all(X, R, W, params, options);

  %HMC parameters
  [debug, numLeaps,numIter,stepSize,sampleLag,burnin,mass] = myProcessOptions(options, ...
    'debug', 0 ,...
    'numLeaps', 10 ,...
    'numIter', 10000 ,...
    'stepSize', 1e-2,...
    'sampleLag', 100, ...
    'burnin', 0.1,...
    'mass',1);

  if(isempty(W))
    W = efa_init_params(params,'all');
    % modify sigma to have value 1
    models_temp = efa_unpack_params(W,params,'all');
    if isfield(models_temp, 'c')
      models_temp.c.sigma = ones(size(models_temp.c.sigma));
      W = efa_pack_params(models_temp,params,'all');
    end
    % use MM method to initialize
    %[opt_options.TolFun, opt_options.TolX, opt_options.MaxIter, opt_options.MaxFunEvals, opt_options.display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-6,'MaxIter',100, 'MaxFunEvals',2000, 'display', 0); % don't run the optimizer too much
    %models = efa_max_all(X,R, W, params, opt_options);
    %W = efa_pack_params(models,params,'all');
  end

  count    = 1;
  N = efa_get_N(X);
  params.N = N;

  %Model parameters
  num_params        = length(W);
  accCount          = 0;

  %Compute initial gradient and energy
  [energy,grad] = efa_loglik(W,X,R,[],params,'all');
  energy = N*energy;
  grad   = N*grad; 

  % ADDED BY EMT
  acceptRate = 0;

  for iter = 1:numIter

      %Sample initial momentum and compute kenetic and potential energies and Hamiltonian
      p         = randn(num_params,1)/mass;     % Initial momentum from N(0,1)
      EkI(iter) = p'*p/2;                 % Initial Kinetic Energy
      EpI(iter) = energy;                 % Initial Potential Energy
      H         =  EkI(iter) + EpI(iter); % Evaluate Hamiltonian
      
      % Do leapfrog steps
      WNew = W; 
      gradNew = grad;
      for t = 1:numLeaps
	  p                   = p - stepSize*gradNew/2;             % half step in p
	  WNew                = WNew + stepSize*p;                  % step in W
	  [energyNew,gradNew] = efa_loglik(WNew,X,R,[],params,'all');% get new energy and gradient 
          energyNew           = N*energyNew;
          gradNew             = N*gradNew;
	  p                   = p - stepSize*gradNew/2;             % half step in p
      end;
    
      %Compute new Hamiltonian
      EkA(iter) = p'*p/2;             % New Kinetic Energy
      EpA(iter) = energyNew;             % New potential energy
      Hnew      = EkA(iter) + EpA(iter); % New hamiltonian
      
      % Do metropolis acceptance step
      dH     = Hnew - H;
      accVal = rand;
      if (dH < 0 | accVal < exp(-dH))
	  accCount = accCount + 1;
	  grad     = gradNew;
	  energy   = energyNew;
	  W        = WNew;
	  accept   = 1;
      else
	  accept = 0;
      end;

      ens(iter) = energy;
      wnorm(iter) = norm(W);

      %Store samples every sampleLag iteration  after burnin  
      if (mod(iter,sampleLag) == 0 & iter>=burnin*numIter)
          [new_model] = efa_unpack_params(W,params,'all');
          new_model.params = params;
          models(count)= new_model;
	  mom(count)   = p'*p/2;
	  en(count)    = energy;
	  dhh(count)   = dH;
	  tt(count)    = toc;
	  count        = count + 1;
      end;
      
      % ADDED by EMT
      acceptRate = (acceptRate*(iter-1) + accept)/iter;
      if (mod(iter,50)==0)

          [new_model] = efa_unpack_params(W,params,'all');
          new_model.params = params;
          Xhat = efa_predict(X,R,new_model,struct('use_old_Z',1));
          err = efa_compute_error(X, Xhat, R);
	  fprintf('Iteration: %u  dH: %.4f  exp(-dh): %g  Energy:  %8.4f Error: %.4f accept %d, %0.2f\n',iter,dH, exp(-dH),energy,err.all, accept, acceptRate);
          if(debug);
	    fs = fields(X);
	    for j=1:length(fs)
	      sfigure(1000+j-1);subplot(1,4,1);imagesc(X.(fs{j}));colormap gray;
			    subplot(1,4,2); imagesc(Xhat.(fs{j}));colormap gray; 
			    subplot(1,4,3); imagesc(new_model.Z);colormap gray;
			    subplot(1,4,4); imagesc(new_model.(fs{j}).beta);colormap gray; 
	    end
	    sfigure(999);subplot(1,2,1);plot(ens);subplot(1,2,2);plot(wnorm);
	    drawnow;
          end;            
      end;

  end;

  stats.momentum = mom;
  stats.energy = en;
  stats.dh = dhh;
  stats.time = tt;
end
