function [f,g] = befa_sml_obj(W,Zs,Xb,Xm,Xc,params)

 [Nb,Db]  = size(Xb);
 [Nm,Dm]  = size(Xm);
 [Nc,Dc]  = size(Xc);
 N        = max([Nb Nm Nc]); 

 K       = params.K;
 alpha   = 1;
 beta    = 1;
 if Dm>0
  mMap    = params.mMap; 
 end
 f       = 0; 
 gVb     = zeros(K,Db);
 gVm     = zeros(K,Dm);
 gVc     = zeros(K,Dc);
 gsigma  = zeros(1,Dc);

 Rb = ~isnan(Xb); Xb(~Rb)=0;
 Rm = ~isnan(Xm); Xm(~Rm)=0;
 Rc = ~isnan(Xc); Xc(~Rc)=0;

 params.N = 0; 
 [Vb,Vm,Vc,sigma] = unpack_mixed_mf_params_noZ(W,params);
 % Added by Emt
 lambda = params.lambdaV;

 if(any(sigma<0)); f=inf; g=0; return;  end;

 nZ = length(Zs);

 for n=1:nZ
   Z = Zs(n).Z;

  if(Dm>0)
    Amhat   =  exp(Z*Vm);
    for m=1:max(mMap)
      ind = find(mMap==m);
      Xmhat(:,ind) = bsxfun(@times,Amhat(:,ind),1./sum(Amhat(:,ind),2));
    end
    Resm    = Rm.*(Xm - Xmhat);
    f = f + (Xm(:).*Rm(:))'*log(Xmhat(:));
    if(nargout>1)
      gVm    = gVm + Z'*Resm; 
    end
  end

  if(Db>0)
    Xbhat   =  logistic(Z*Vb);
    Resb    = Rb.*(Xb - Xbhat);
    f       = f + (Xb(:).*Rb(:))'*log(Xbhat(:)) + ((1-Xb(:)).*Rb(:))'*log(1-Xbhat(:));
    if(nargout>1)
      gVb = gVb + Z'*Resb; 
    end
  end

  if(Dc>0)
      Xchat   =  Z*Vc;  
      Resc    = Rc.*(Xc - Xchat);
      f       = f -0.5*sum(sum(Rc,1).*(log(sigma.^2))) - 0.5*sum(sum(bsxfun(@times,Resc.^2,1./sigma.^2)));
      if(nargout>1)
      gVc = gVc + Z'*bsxfun(@times,Resc,1./sigma.^2);
      gsigma = gsigma -(sum(Rc,1))./(sigma) + (sum(Resc.^2,1))./sigma.^3;
      end
  end
 
  Znew = Z(:,2:end);
  f = f - 0.5*params.lambdaZ*Znew(:)'*Znew(:);
end

%Compute average objective function over samples Z
f = f/nZ;

if(Dm>0)
  f = f - 0.5*lambda*(Vm(:)'*Vm(:));
  if(nargout>1)
    gVm = gVm/nZ  - lambda*Vm; 
  end
end

if(Db>0)
  f = f - 0.5*lambda*(Vb(:)'*Vb(:));
  if(nargout>1)
    gVb = gVb/nZ - lambda*Vb; 
  end
end

if(Dc>0)
    f  = f -0.5*lambda*(Vc(:)'*Vc(:));
    f  = f - sum((alpha+1)*log(sigma.^2) + beta./(sigma.^2));
    if(nargout>1)
      gVc = gVc/nZ + Z'*bsxfun(@times,Resc,1./sigma.^2) - lambda*Vc;
      gsigma = gsigma/nZ -(2*(alpha+1))./(sigma) + (2*beta)./sigma.^3;
    end
end



f = -f/N;
if(nargout>1)
  g =  pack_mixed_mf_params([],gVb,gVm,gVc,gsigma);
  g = -g/N;
end


return

function y = logistic(x);

 y = 1./(1+exp(-x));
