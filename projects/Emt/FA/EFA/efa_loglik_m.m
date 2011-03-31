function [f,gZ,gd] = efa_likgrad_m(X,R,Z,theta,params,type)

   f= 0;
   gd    = [];
   gZ    = [];

   mMap    = params.mMap;
   %MODIFIED BY EMT
   val = Z*theta.beta;

   Amhat   =  exp(Z*theta.beta);
   for m=1:max(mMap)
     ind = find(mMap==m);
     %Xhat1(:,ind) = bsxfun(@times,Amhat(:,ind),1./sum(Amhat(:,ind),2));
     logXhat(:,ind) = bsxfun(@minus,val(:,ind),logsumexp(val(:,ind),2));
   end
   Xhat = exp(logXhat);

   Resm    = R.*(X - Xhat);
   f = f + (X(:).*R(:))'*logXhat(:);
   f = f - 0.5*params.lambdaBeta*(theta.beta(:)'*theta.beta(:));
   if(nargout>1)
     if(strcmp(type,'all') | strcmp(type,'noZ'))
       gd.beta = Z'*Resm - params.lambdaBeta*theta.beta; 
     end
     if(strcmp(type,'all') | strcmp(type,'Z'))
       gZ     = Resm*theta.beta';
     end
   end

