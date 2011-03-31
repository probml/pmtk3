function [Z,Vb,Vm,Vc,sigma] = unpack_mixed_mf_params(W,params);

  N  = params.N;
  Mb = params.Mb;
  Mm = params.Mm;
  Mc = params.Mc;
  K  = params.K;

  %Extract data factors  
  tmp = W(1:N*(K-1));
  Z   = [ones(N,1),reshape(tmp,[N,K-1])];
  W   = W(N*(K-1)+1:end);

  if Mb>0
    %Extract binary factors
    tmp = W(1:Mb*K);
    Vb  = reshape(tmp,[K,Mb]);
    W   = W(Mb*K+1:end); 
  else
    Vb = [];
  end

  if Mm >0
    %Extract mutinomial factors
    tmp = W(1:Mm*K);
    Vm  = reshape(tmp,[K,Mm]);
    W   = W(Mm*K+1:end); 
  else
    Vm = [];
  end

  %Extract continuous factors
  if Mc >0
    tmp = W(1:Mc*K);
    Vc  = reshape(tmp,[K,Mc]);
    W   = W(Mc*K+1:end); 
  else
    Vc = [];
  end
 
  %Extract continuous std
  sigma = W(1:Mc)';
   
return
  
