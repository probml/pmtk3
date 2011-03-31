function [f,g] = mixed_mf_obj(W,Xb,Xm,Xc,params)

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
 gZ      = 0;
 gVb     = [];
 gVm     = [];
 gVc     = [];
 gsigma  = []; 

 Rb = ~isnan(Xb); Xb(~Rb)=0;
 Rm = ~isnan(Xm); Xm(~Rm)=0;
 Rc = ~isnan(Xc); Xc(~Rc)=0;

 params.N = N;
 [Z,Vb,Vm,Vc,sigma] = unpack_mixed_mf_params(W,params);
 % Added by Emt
 lambda = params.lambdaV;

 if(isfield(params,'debug') & params.debug);keyboard;end;

 if(any(sigma<0)); fprintf('*');  f=inf; g=0; return;  end;

 if(Dm>0)
   Amhat   =  exp(Z*Vm);
   for m=1:max(mMap)
     ind = find(mMap==m);
     Xmhat(:,ind) = bsxfun(@times,Amhat(:,ind),1./sum(Amhat(:,ind),2));
   end
   Resm    = Rm.*(Xm - Xmhat);
   f = f + (Xm(:).*Rm(:))'*log(Xmhat(:));
   f = f - 0.5*lambda*(Vm(:)'*Vm(:));
   if(nargout>1)
     gVm    = Z'*Resm - lambda*Vm; 
     gZ     = gZ + Resm*Vm';
   end
 end

 if(Db>0)
   Xbhat      =  logistic(Z*Vb);
   %ZVb        = Z*Vb;
   %logXbhat   = -reshape(logsumexp([zeros(N*Db,1),-ZVb(:)],2),[N,Db]);
   %log1mXbhat = -ZVb + logXbhat;  
   Resb       = Rb.*(Xb - Xbhat);
   f         = f + (Xb(:).*Rb(:))'*log(Xbhat(:)+eps) + ((1-Xb(:)).*Rb(:))'*log(1-Xbhat(:)+eps);
   %f          = f + (Xb(:).*Rb(:))'*logXbhat(:) + ((1-Xb(:)).*Rb(:))'*log1mXbhat(:);
   f          = f - 0.5*lambda*(Vb(:)'*Vb(:));
   if(nargout>1)
     gVb = Z'*Resb - lambda*Vb; 
     gZ  = gZ +  Resb*Vb';
   end
 end

 if(Dc>0)
    Xchat   =  Z*Vc;  
    Resc    = Rc.*(Xc - Xchat);
    f       = f -0.5*sum(sum(Rc,1).*(log(sigma.^2))) - 0.5*sum(sum(bsxfun(@times,Resc.^2,1./sigma.^2)));
    f       = f -0.5*lambda*(Vc(:)'*Vc(:));
    f       = f - sum((alpha+1)*log(sigma.^2) + beta./(sigma.^2));
    if(nargout>1)
     gVc = Z'*bsxfun(@times,Resc,1./sigma.^2) - lambda*Vc;
     gZ  = gZ + bsxfun(@times,Resc,1./sigma.^2)*Vc';  
     gsigma = -(sum(Rc,1)+2*(alpha+1))./(sigma) + (2*beta + sum(Resc.^2,1))./sigma.^3;
    end
 end


 Znew = Z(:,2:end);
 f = f - 0.5*params.lambdaZ*Znew(:)'*Znew(:);
 if(nargout>1)
   gZ = (gZ - params.lambdaZ*Z);
 end


 f = -f/N;
 if(nargout>1)
  g =  pack_mixed_mf_params(gZ,gVb,gVm,gVc,gsigma);
  g = -g/N;
 end

 if(isnan(f)); keyboard;end;

return

function y = logistic(x);

 y = 1./(1+exp(-x));
