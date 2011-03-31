function Z = mixed_mf_infer(Xb,Xm,Xc,params)
% specify N in params.N

  options.Method    = 'lbfgs';
  options.TolFun    = 1e-4;
  options.TolX      = 1e-4;
  options.maxIter   = 100;
  options.DerivativeCheck = 'off';
  options.display = 0;

  [Nb,Db]  = size(Xb);
  [Nm,Dm]  = size(Xm);
  [Nc,Dc]  = size(Xc);
  N        = max([Nb Nm Nc]); 
  Z = rand(N*(params.K-1),1)/100;

  %params.lambda = 1;
  %[f,g]   = mixed_mf_infer_obj_emt(Z,Xb,Xm,Xc,params);
  Z       = minFunc(@mixed_mf_infer_obj_emt,Z,options,Xb,Xm,Xc,params);
  Z       = [ones(N,1),reshape(Z,[N,params.K-1])];

return
