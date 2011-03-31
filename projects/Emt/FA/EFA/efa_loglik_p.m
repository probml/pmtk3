function [f,gZ,gd] = efa_likgrad_p(X,R,Z,theta,params,type)

alpha = 1;
beta  = 1;
f     = 0;
gd    = [];
gZ    = [];

logXhat = Z*theta.beta;
Xhat    =  exp(logXhat);  
Res     = R.*(X - Xhat);
f       = f + sum(X(R).*logXhat(R) - Xhat(R) - factorial(X(R)));
f       = f -0.5*params.lambdaBeta*(theta.beta(:)'*theta.beta(:));

if(nargout>1)
  if(strcmp(type,'all') | strcmp(type,'noZ'))
    gd.beta  = Z'*Res - params.lambdaBeta*theta.beta;
  end
  if(strcmp(type,'all') | strcmp(type,'Z'))
    gZ  = Res*theta.beta';  
  end
end