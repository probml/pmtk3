function [infer stats] = befa_inference_hmc(Xb, Xm, Xc, W, params, options);

  %HMC parameters
  [debug, numLeaps,numIter,stepSize,sampleLag,burnin] = myProcessOptions(options, ...
    'debug', 0 ,...
    'numLeaps', 5 ,...
    'numIter', 100 ,...
    'stepSize', 1e-1,...
    'sampleLag', 1, ...
    'burnin', 0.01);

  %Model parameters
  num_params        = length(W);
  [Nb,Db]           = size(Xb);
  [Nm,Dm]           = size(Xm);
  [Nc,Dc]           = size(Xc);
  N                 = max([Nb Nm Nc]);
  K                 = params.K;

  %HMC counters
  accCount = 0;
  count    = 1;

  %Compute initial gradient and energy
  [energy,grad] = mixed_mf_infer_obj_emt(W,Xb,Xm,Xc,params);

  for iter = 1:numIter

      %Sample initial momentum and compute kenetic and potential energies
      p         = randn(num_params,1)/sqrt(N);     % Initial momentum from N(0,1)
      EkI(iter) = p'*p/2;                 % Initial Kinetic Energy
      EpI(iter) = energy;                 % Initial Potential Energy
      H         =  EkI(iter) + EpI(iter); % Evaluate Hamiltonian
      
      % Do leapfrog steps
      WNew = W; 
      gradNew = grad;
      for t = 1:numLeaps
	  p                   = p - stepSize*gradNew/2;             % half step in p
	  WNew                = WNew + stepSize*p;                  % step in W
	  [energyNew,gradNew] = mixed_mf_infer_obj_emt(WNew,Xb,Xm,Xc,params);% get new gradient 
	  p                   = p - stepSize*gradNew/2;             % half step in p
      end;
    
      %Compute new energies and Hamiltonian
      EkA(iter) = p'*p/2;             % New Kinetic Energy
      EpA(iter) = energyNew;             % New potential energy
      Hnew      = EkA(iter) + EpA(iter); % New hamiltonian
      
      % Do metropolis acceptance step
      dH = Hnew - H; 
      accVal = rand;
      if (dH < 0)
	  accept = 1;
      elseif (accVal < exp(-dH))
	  accept = 1;
      else
	  accept = 0;
      end;

      %If accept update parameters and gradients
      if accept
	  accCount = accCount + 1;
	  grad     = gradNew;
	  energy   = energyNew;
	  W        = WNew;
      end;

      %Store samples every sampleLag iteration    
      if (mod(iter,sampleLag) == 0 & iter>=burnin*numIter)
          infer(count).Z=[ones(N,1),reshape(W,[N,K-1])];
	  mom(count)   = p'*p/2;
	  en(count)    = energy;
	  dhh(count)   = dH;
	  tt(count)    = toc;
	  count        = count + 1;
      end;
      
      if debug
	  fprintf('Iteration: %u  exp(-dh): %g  Energy:  %8.4f\n',iter,exp(-dH),energy);
          figure(1);plot(EpA);drawnow; hold on;
      end;

  end;

  stats.momentum = mom;
  stats.energy = en;
  stats.dh = dhh;
  stats.time = tt;
