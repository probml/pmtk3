function model = mixed_mf_learn_emt(Xb, Xm, Xc, Winit, params, options)

  [Nb,Db]  = size(Xb);
  [Nm,Dm]  = size(Xm);
  [Nc,Dc]  = size(Xc);
  N        = max([Nb Nm Nc]); 
  params.N = N;

  [f,g]   = mixed_mf_obj_emt(Winit,Xb,Xm,Xc,params);
  W       = minFunc(@mixed_mf_obj_emt,Winit,options,Xb,Xm,Xc,params);

%  [Z,model.Vb,model.Vm,model.Vc,model.sigma] = unpack_mixed_mf_params(W,params);
  [params.Z,params.Vb,params.Vm,params.Vc,params.sigma] = unpack_mixed_mf_params(W,params);
  model = params;

return

