function Zs = efa_infer(X, R, W, model, options)

  [method] = myProcessOptions(options,'method','M');

  %Select and run learning method
  switch(method)
    case 'M' %Maximize-Maximize method
      Zs = efa_max_Z(X, R, W, model, options);
    case 'S' %Sample-Sample method
      Zs = efa_sample_Z(X, R, W,model, options);
    case 'E' %Expected value
      Zs = efa_expected_Z(X, R, W,model, options);
  end

end

function infer = efa_max_Z(X, R, W, model, options);

  %Set optimizer parameters  
  [options.TolFun, options.TolX, options.MaxIter, options.MaxFunEvals, options.display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-10,'MaxIter',1000, 'MaxFunEvals',1000, 'display', 0);
  options.Method    = 'lbfgs';
  options.DerivativeCheck = 'off';

  %Get number of data cases
  N = efa_get_N(X);
  model.params.N = N;
  K = model.params.K;
  if(isempty(W))
    W = randn(N*(K-1),1)/100;
  end

   %Run optimizer
   W = minFunc(@efa_loglik,W,options,X,R,model,model.params,'Z');
   infer.Z=[ones(N,1),reshape(W,[N,model.params.K-1])];
end

function infer = efa_sample_Z(X, R, W, model, options);

  tic
  %Optimization parameters
  [options.TolFun, options.TolX, options.MaxIter, options.MaxFunEvals, options.display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-10,'MaxIter',100, 'MaxFunEvals',100, 'display', 0);
  options.Method    = 'lbfgs';
  options.DerivativeCheck = 'off';

  % ADDED BY EMT
  dists = sort(fields(X));
  %Initialize prediction for each distribution
  for d=1:length(dists)
    Xhat.(dists{d}) = zeros(size(X.(dists{d})));
  end  


  %HMC parameters
  [debug, numLeaps,numIter,stepSize,sampleLag,burnin,mass] = myProcessOptions(options, ...
    'debug', 0 ,...
    'numLeaps', 5 ,...
    'numIter', 200 ,...
    'stepSize', 1e-2,...
    'sampleLag', 1, ...
    'burnin', 0.1,...
    'mass',1);

  %Model parameters
  N                 = efa_get_N(X);
  model.params.N    = N;
  K                 = model.params.K;
  num_params        = N*(K-1);
  count             = 1;
  accCount          = 0;

  if(isempty(W))
    W = randn(N*(K-1),1)/100;
    %W = minFunc(@efa_loglik,W,options,X,R,model,model.params,'Z');
  end

  %Compute initial gradient and energy
  [energy,grad] = efa_loglik(W,X,R,model,model.params,'Z');
  energy = N*energy;
  grad   = N*grad; 

  for iter = 1:numIter

      %Sample initial momentum and compute kenetic and potential energies
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
	  [energyNew,gradNew] = efa_loglik(WNew,X,R, model,model.params,'Z');% get new gradient 
          energyNew           = N*energyNew;
          gradNew             = N*gradNew;
	  p                   = p - stepSize*gradNew/2;             % half step in p
      end;
    
      %Compute new energies and Hamiltonian
      EkA(iter) = p'*p/2;             % New Kinetic Energy
      EpA(iter) = energyNew;             % New potential energy
      Hnew      = EkA(iter) + EpA(iter); % New hamiltonian
      
      % Do metropolis acceptance step
      dH = Hnew - H; 
      accVal = rand;
      if (dH < 0 | accVal < exp(-dH))
	  accept = 1;
	  accCount = accCount + 1;
	  grad     = gradNew;
	  energy   = energyNew;
	  W        = WNew;
      else
	  accept = 0;
      end;

      %Store samples every sampleLag iteration    
      if (mod(iter,sampleLag) == 0 & iter>=burnin*numIter)
          infer(count).Z=[ones(N,1),reshape(W,[N,K-1])];
	  mom(count)   = p'*p/2;
	  en(count)    = energy;
          wnorm(count) = norm(W);
	  dhh(count)   = dH;
	  tt(count)    = toc;
	  count        = count + 1;
      end;

      % ADDED BY EMT
      if(debug);
        if (mod(iter,50)==0)
          Z = infer(end).Z;
          for d=1:length(dists)
            predict = str2func(sprintf('efa_predict_%s',dists{d}));
            Xhat.(dists{d}) = Xhat.(dists{d}) + predict(Z,model.(dists{d}),model.params);
          end  

          err = efa_compute_error(X, Xhat, R);
	  fprintf('Iteration: %u  dH: %.4f  exp(-dh): %g  Energy:  %8.4f Error: %.4f\n',iter,dH, exp(-dH),energy,err.all);
	    fs = fields(X);
	    for j=1:length(fs)
	      sfigure(1000+j-1);subplot(1,2,1);imagesc(X.(fs{j}));colormap gray;
			    subplot(1,2,2); imagesc(Xhat.(fs{j}));colormap gray; 
	    end
	    sfigure(999);subplot(1,2,1);plot(en);subplot(1,2,2);plot(wnorm);
	    drawnow;
          end;            
      end;
      
      %if debug
      %	  fprintf('Iteration: %u  exp(-dh): %g  Energy:  %8.4f\n',iter,exp(-dH),energy);
           %     sfigure(1);plot(EpA);drawnow; hold on;
           % end;

  end;

  stats.momentum = mom;
  stats.energy = en;
  stats.dh = dhh;
  stats.time = tt;
end

function infer = efa_expected_Z(X, R, W, model, options);

  %Get number of data cases
  N = efa_get_N(X);
  K = model.params.K-1;

  %Check that we only have Gaussian data 
  f = fields(X);
  if(length(f)>1 | ~strcmp(f{1},'c'))
    error('efa_infer: Inference for exact posterior mean is only supported for Gaussian observations');
  end

  %Get Gaussian model parameters
  mu    = model.c.beta(1,:);
  beta  = model.c.beta(2:end,:);
  sigma = exp(model.c.sigma);
  
  %Compute posterior mean of Z for each data case 
  infer.Z = zeros(N,K+1);
  for n=1:N
    r = R.c(n,:);
    InvSigmaObs      = diag(1./sigma(r));
    SigmaPost        = beta(:,r)*InvSigmaObs*beta(:,r)' + eye(K);
    infer.Z(n,2:end) = inv(SigmaPost)*(beta(:,r)*InvSigmaObs*(X.c(n,r)-mu(r))');
    infer.Z(n,1)     = 1; 
  end
end
