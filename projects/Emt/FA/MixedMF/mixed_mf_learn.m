function model = mixed_mf_learn(data,K,lambdaZ,lambdaV);

  [Xb,Xm,Xc,params] = mixed_mf_prepare_data(data);
  params.K          = K;
  params.lambdaV    = lambdaV;
  params.lambdaZ    = lambdaZ;
  params.alpha      = 1;
  params.beta       = 1;
  Winit             = mixed_mf_init_params(Xb,Xm,Xc,params);

  options.Method    = 'lbfgs';
  options.TolFun    = 1e-6;
  options.TolX      = 1e-10;
  options.MaxIter   = 2000;
  options.MaxFunEvals = 2000;
  options.DerivativeCheck = 'on';
  options.corr = 50;
  options.display = 0;

  [f,g]   = mixed_mf_obj_emt(Winit,Xb,Xm,Xc,params);
  W       = minFunc(@mixed_mf_obj_emt,Winit,options,Xb,Xm,Xc,params);

  [model.Z,model.Vb,model.Vm,model.Vc,model.sigma] = unpack_mixed_mf_params(W,params);
  %[Z,params.Vb,params.Vm,params.Vc] = unpack_mixed_mf_params(W,params);
  model = params;

return

