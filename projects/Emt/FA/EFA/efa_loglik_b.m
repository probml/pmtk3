function [f,gZ,gd] = efa_likgrad_b(X,R,Z,theta,params,type)

   f= 0;
   gd    = [];
   gZ    = [];

   Xhat       =  logistic(Z*theta.beta);
   Resb       = R.*(X - Xhat);
   f          = f + X(R)'*log(Xhat(R)+eps) + (1-X(R))'*log(1-Xhat(R)+eps);
   f          = f - 0.5*params.lambdaBeta*(theta.beta(:)'*theta.beta(:));
   if(nargout>1)
     if(strcmp(type,'all') | strcmp(type,'noZ'))
       gd.beta = Z'*Resb - params.lambdaBeta*theta.beta; 
     end
     if(strcmp(type,'all') | strcmp(type,'Z'))
       gZ  = Resb*theta.beta';
     end
   end
end

function y = logistic(x)
  y = 1./(1+exp(-x));
end
