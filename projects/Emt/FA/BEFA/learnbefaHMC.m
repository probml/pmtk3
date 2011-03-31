function [models] = learnbefa(data, params, options)

  [Dz,nClass,cv,valsZ,valsV] = myProcessOptions(options, 'Dz',2,'nClass',[], 'cv', 1, 'valsZ', 10.^[-2:1:2],'valsV',10.^[-3:.5:3]);
  [lambdaV, lambdaZ,alpha,beta] = myProcessOptions(params, 'lambdaV',0.01,'lambdaZ',0.01,'alpha',1,'beta',1);

  [TolFun, TolX, MaxIter, MaxFunEvals, display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-10,'MaxIter',50, 'MaxFunEvals',50, 'display', 0);

  [Xb,Xm,Xc,params] = mixed_mf_prepare_data_emt(data, nClass);
  params.K = Dz;
  params.lambdaV = lambdaV;
  params.lambdaZ = lambdaZ;
  params.nClass  = nClass;

  options.Method    = 'lbfgs';
  options.TolFun    = TolFun;
  options.TolX      = TolX;
  options.MaxIter   = MaxIter;
  options.MaxFunEvals = MaxFunEvals;
  options.DerivativeCheck = 'off';
  options.corr = 50;
  options.display = display;

  W = mixed_mf_init_params(Xb,Xm,Xc,params);
  %W = minFunc(@mixed_mf_obj_emt,W,options,Xb,Xm,Xc,params);

  [models stats] = befa_hmc(Xb, Xm, Xc, W, params, options);
