function [f,g] = mixed_mf_infer_obj(W,Xb,Xm,Xc,params)

 [Nb,Db]  = size(Xb);
 [Nm,Dm]  = size(Xm);
 [Nc,Dc]  = size(Xc);
 N        = max([Nb Nm Nc]);
 
 K       = params.K;
 mMap    = params.mMap; 
 f       = 0; 
 gZ      = 0;
 Z       = [ones(N,1),reshape(W,[N,K-1])];
 sigma   = params.sigma;
 Vb      = params.Vb;
 Vm      = params.Vm;
 Vc      = params.Vc;

 Rb = ~isnan(Xb); Xb(~Rb)=0;
 Rm = ~isnan(Xm); Xm(~Rm)=0;
 Rc = ~isnan(Xc); Xc(~Rc)=0;

 if(Dm>0)
   Amhat   =  exp(Z*Vm);
   for m=1:max(mMap)
     ind = find(mMap==m);
     Xmhat(:,ind) = bsxfun(@times,Amhat(:,ind),1./sum(Amhat(:,ind),2));
   end
   Resm    = Rm.*(Xm - Xmhat);
   f = f + (Xm(:).*Rm(:))'*log(Xmhat(:));
   if(nargout>1)
     gZ     = gZ + Resm*Vm';
   end
 end

 if(Db>0)
    Xbhat   =  logistic(Z*Vb);
    Resb    = Rb.*(Xb - Xbhat);
    f       = f + (Xb(:).*Rb(:))'*log(Xbhat(:)) + ((1-Xb(:)).*Rb(:))'*log(1-Xbhat(:));
    if(nargout>1)
      gZ  = gZ +  Resb*Vb';
    end
 end

 if(Dc>0)
    Xchat   =  Z*Vc;  
    Resc    = Rc.*(Xc - Xchat);
    f       = f -0.5*sum(sum(Rc,1).*(log(2*pi*sigma.^2))) - 0.5*sum(sum(bsxfun(@times,Resc.^2,1./sigma.^2)));
    if(nargout>1)
     gZ  = gZ + bsxfun(@times,Resc,1./sigma.^2)*Vc';  
    end
 end

 Znew = Z(:,2:end);
 f = f - 0.5*params.lambdaZ*Znew(:)'*Znew(:);
 if(nargout>1)
   gZ = (gZ - params.lambdaZ*Z);
 end

 %modified by Emt
 f = -f/N;
 g = gZ(:,2:end); 
 g = -g(:)/N;

return

function y = logistic(x);

 y = 1./(1+exp(-x));
