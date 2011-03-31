function [model] = learnbefaSML(data, params, options)

  debug = 0;

  %Extract parameters and options
  [lambdaV, lambdaZ,alpha,beta,Winit] = myProcessOptions(params, 'lambdaV',0.01,'lambdaZ',0.01,'alpha',1,'beta',1,'Winit',[]);
  [Dz,nClass,cv,valsZ,valsV] = myProcessOptions(options, 'Dz',2,'nClass',[], 'cv', 1, 'valsZ', 10.^[-2:1:2],'valsV',10.^[-3:.5:3]);
  [TolFun, TolX, MaxIter, MaxFunEvals, display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-10,'MaxIter',10, 'MaxFunEvals',10, 'display', 0);

  %Prepare data for learning
  [Xb,Xm,Xc,params] = mixed_mf_prepare_data_emt(data, nClass);
  params.K = Dz;
  params.lambdaV = lambdaV;
  params.lambdaZ = lambdaZ;
  params.nClass  = nClass;

  %Set options for optimizing FA parameters
  Wd_options.Method    = 'lbfgs';
  Wd_options.TolFun    = TolFun;
  Wd_options.TolX      = TolX;
  Wd_options.MaxIter   = 10;
  Wd_options.MaxFunEvals = 10;
  Wd_options.DerivativeCheck = 'off';
  Wd_options.corr = 50;
  Wd_options.display = display;

  %Set options for sampling FA latent variables
  Wz_options.numLeaps  = 5;
  Wz_options.numIter  = 1;
  Wz_options.sampleLag = 1;
  Wz_options.burnin    = 0.01;

  %Initialize parameters from MAP/MAP 
  model    = params;
  N        = params.N;
  params.N = 0;
  if(~isempty(Winit))
    W = Winit;
  else
    W = mixed_mf_init_params(Xb,Xm,Xc,params);
  end
  Wz       = W(1:N*(params.K-1));
  Wd       = W(N*(params.K-1)+1:end);
  W        = [];
  gold     = 0;

  %Run stochastic optimization 
  for n=1:MaxIter

    %Unpack parameters
    [model.Vb,model.Vm,model.Vc,model.sigma] = unpack_mixed_mf_params_noZ(Wd,params);

    %Sample latent factors given current parameters
    Zs  = befa_inference_hmc(Xb, Xm, Xc, Wz(:), model, Wz_options);
    I = length(Zs);

    %Optimize parameters given sampled latent factors
    [Wd,f] = minFunc(@befa_sml_obj_emt,Wd(:),Wd_options,Zs, Xb,Xm,Xc,params);

    if(debug)
      fprintf('Iter %d  Obj %f\n',n,f);
      Xbhat = 1./(1+exp(-Zs(end).Z*model.Vb));
      figure(2);imagesc(Xbhat);colormap gray; colorbar;drawnow;
    end
  end

  model.Z = Zs(end).Z;