function [Xbhat,Xmhat,Xchat,Z] = mixed_mf_predict(Xb,Xm,Xc,model)

 [Nb,Db]  = size(Xb);
 [Nm,Dm]  = size(Xm);
 [Nc,Dc]  = size(Xc);
 N        = max([Nb Nm Nc]); 

 Xbhat   = [];
 Xmhat   = [];
 Xchat   = [];

if(isfield(model,'Z') & size(model.Z,1)==N)
  Z = model.Z;
else
  Z = mixed_mf_infer(Xb,Xm,Xc,model);
end

 Vb      = model.Vb;
 Vm      = model.Vm;
 Vc      = model.Vc;
 K       = model.K;
 mMap    = model.mMap; 

 if(Dm>0)
   Amhat   =  exp(Z*Vm);
   for m=1:max(mMap)
     ind = find(mMap==m);
     Xmhat(:,ind) = bsxfun(@times,Amhat(:,ind),1./sum(Amhat(:,ind),2));
     % modified by emt (not to include the last column of prediction (as it is
     % just the sum of the probs
     %ind1 = ind(1:end-1);
     %Xmhat = [Xmhat bsxfun(@times,Amhat(:,ind1),1./sum(Amhat(:,ind),2))];
   end
 end

 if(Db>0)
    Xbhat   =  logistic(Z*Vb);
 end

 if(Dc>0)
    Xchat   =  Z*Vc;  
    %Xchat(Xchat>4) = 4;
    %Xchat(Xchat<-4) = -4;
 end

return

function y = logistic(x);

 y = 1./(1+exp(-x));
