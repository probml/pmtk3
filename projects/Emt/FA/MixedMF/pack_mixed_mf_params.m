function W = pack_mixed_mf_params(Z,Vb,Vm,Vc,sigma);

  tmp = Z(:,2:end);
  W  = [tmp(:);Vb(:);Vm(:);Vc(:);sigma(:)];

return