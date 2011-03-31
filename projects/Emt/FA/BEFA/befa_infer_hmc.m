function [models stats] = befa_hmc(Xb, Xm, Xc, W, params,options);

  %HMC parameters
  debug             = 0;
  numLeaps          = 10; 
  numIter           = 1000; 
  stepSize          = 1e-1; 
  sampleLag         = 20; 
  count             = 1;

  %Model parameters
  num_params        = length(W);
  accCount          = 0;

  %Compute initial gradient and energy
  [energy,grad] = mixed_mf_obj_emt(W,Xb,Xm,Xc,params);
  %energy = -energy;
  %grad   = -grad;

  for iter = 1:numIter

      %Sample initial momentum and compute kenetic and potential energies
      p         = 0.1*randn(num_params,1);     % Initial momentum from N(0,1)
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
      if (mod(iter,sampleLag) == 0 & iter>=0.1*numIter)
          newModel = params;
          [Z,newModel.Vb,newModel.Vm,newModel.Vc,newModel.sigma] = unpack_mixed_mf_params(W,params);
          models(count)=newModel;
	  mom(count)   = p'*p/2;
	  en(count)    = energy;
	  dhh(count)   = dH;
	  tt(count)    = toc;
	  count        = count + 1;
      end;
      
      if debug
	  fprintf('Iteration: %u  exp(-dh): %g  Energy:  %8.4f\n',iter,exp(-dH),energy);
          plot(EpA);drawnow;
      end;

  end;

  stats.momentum = mom;
  stats.energy = en;
  stats.dh = dhh;
  stats.time = tt;
