function [models] = learnbefa(data, params, options)

  [Dz,nClass,cv,valsZ,valsV] = myProcessOptions(options, 'Dz',2,'nClass',[], 'cv', 1, 'valsZ', 10.^[-2:1:2],'valsV',10.^[-3:.5:3]);
  [lambdaV, lambdaZ,alpha,beta] = myProcessOptions(params, 'lambdaV',0.01,'lambdaZ',0.01,'alpha',1,'beta',1);

  [TolFun, TolX, MaxIter, MaxFunEvals, display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-10,'MaxIter',50, 'MaxFunEvals',50, 'display', 0);

  [Xb,Xm,Xc,params] = mixed_mf_prepare_data_emt(data, nClass);
  params.K = Dz;
  params.lambdaV = lambdaV;
  params.lambdaZ = lambdaZ;
  params.nClass  = nClass;

  [Nb,Db]  = size(Xb);
  [Nm,Dm]  = size(Xm);
  [Nc,Dc]  = size(Xc);
  N        = max([Nb Nm Nc]); 

  options.numLeaps  = 5;
  options.numIter   = 10000;
  options.sampleLag = 100;
  options.burnin    = 0.1;
  options.stepSize  = 1e-2;
  options.mass      = 1;

  init_options.Method    = 'lbfgs';
  init_options.TolFun    = 1e-6;
  init_options.TolX      = 1e-10;
  init_options.MaxIter   = 100;
  init_options.MaxFunEvals = 100;
  init_options.DerivativeCheck = 'on';
  init_options.corr = 50;
  init_options.display = 0;

  W = mixed_mf_init_params(Xb,Xm,Xc,params);
  %W = minFunc(@mixed_mf_obj_emt,W,init_options,Xb,Xm,Xc,params);


  [models stats] = befa_hmc(Xb, Xm, Xc, W, params, options);
