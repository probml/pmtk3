function [models stats] = befa_hmc(Xb, Xm, Xc, W, params, options);

  %HMC parameters
  [debug, numLeaps,numIter,stepSize,sampleLag,burnin] = myProcessOptions(options, ...
    'debug', 1 ,...
    'numLeaps', 10 ,...
    'numIter', 1000 ,...
    'stepSize', 1e-1,...
    'sampleLag', 20, ...
    'burnin', 0.1);

  count             = 1;
  [Nb,Db]  = size(Xb);
  [Nm,Dm]  = size(Xm);
  [Nc,Dc]  = size(Xc);
  N        = max([Nb Nm Nc]);

  %Model parameters
  num_params        = length(W);
  accCount          = 0;

  %Compute initial gradient and energy
  [energy,grad] = mixed_mf_obj_emt(W,Xb,Xm,Xc,params);
  %energy = -energy;
  %grad   = -grad;

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
	  [energyNew,gradNew] = mixed_mf_obj_emt(WNew,Xb,Xm,Xc,params);% get new gradient 
          %energyNew           = -energyNew;
          %gradNew             = -gradNew;
	  p                   = p - stepSize*gradNew/2;             % half step in p
      end;
    
      %Compute new energies and Hamiltonian
      EkA(iter) = p'*p/2;             % New Kinetic Energy
      EpA(iter) = energyNew;             % New potential energy
      Hnew      = EkA(iter) + EpA(iter); % New hamiltonian
      
      % Do metropolis acceptance step
      dH = Hnew - H;

      if(isnan(dH));keyboard;end

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

      ens(iter) = energy;

      %Store samples every sampleLag iteration    
      if (mod(iter,sampleLag) == 0 & iter>=burnin*numIter)
          newModel = params;
          [newModel.Z,newModel.Vb,newModel.Vm,newModel.Vc,newModel.sigma] = unpack_mixed_mf_params(W,params);
          models(count)=newModel;
	  mom(count)   = p'*p/2;
	  en(count)    = energy;
	  dhh(count)   = dH;
	  tt(count)    = toc;
	  count        = count + 1;
      end;
      
      if (debug & mod(iter,50)==0)
	  fprintf('Iteration: %u  dH: %.4f  exp(-dh): %g  Energy:  %8.4f\n',iter,dH, exp(-dH),energy);
          %[newModel.Z,newModel.Vb,newModel.Vm,newModel.Vc,newModel.sigma] = unpack_mixed_mf_params(W,params);          
          %figure(1);plot(ens);drawnow;
          %Xbhat = 1./(1+exp(-newModel.Z*newModel.Vb));
          %figure(2);imagesc(Xbhat);colormap gray; colorbar;drawnow;
      end;

  end;

  stats.momentum = mom;
  stats.energy = en;
  stats.dh = dhh;
  stats.time = tt;
