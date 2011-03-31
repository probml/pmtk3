function [params, testErrAll] = learnMixedMF(data, params, options)

  [Dz,nClass,cv,valsZ,valsV] = myProcessOptions(options, 'Dz',2,'nClass',[], 'cv', 1, 'valsZ', 10.^[-2:1:2],'valsV',10.^[-3:.5:3]);
  [lambdaV, lambdaZ,alpha,beta,Winit] = myProcessOptions(params, 'lambdaV',0.01,'lambdaZ',0.01,'alpha',1,'beta',1,'Winit',[]);

  [TolFun, TolX, MaxIter, MaxFunEvals, display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-10,'MaxIter',2000, 'MaxFunEvals',2000, 'display', 0);
  options.Method    = 'lbfgs';
  options.TolFun    = TolFun;
  options.TolX      = TolX;
  options.MaxIter   = MaxIter;
  options.MaxFunEvals = MaxFunEvals;
  options.DerivativeCheck = 'off';
  options.corr = 50;
  options.display = display;

  if cv
    [lambdaZ, lambdaV, testErrAll] = cvImpute('mixedMF', data, valsZ, valsV, struct('Dz',Dz,'nClass',nClass), struct('discrete',1));
  else
    testErrAll = 0;
  end

  [Xb,Xm,Xc,params] = mixed_mf_prepare_data_emt(data, nClass);
  params.K = Dz;
  params.lambdaV = lambdaV;
  params.lambdaZ = lambdaZ;

  if(isempty(Winit))
    Winit = mixed_mf_init_params(Xb,Xm,Xc,params);
  end

  params = mixed_mf_learn_emt(Xb, Xm, Xc, Winit, params, options);
  params.nClass = nClass;

