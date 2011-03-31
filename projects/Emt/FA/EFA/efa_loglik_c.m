function [f,gZ,gd] = efa_loglik_c(X,R,Z,theta,params,type)

    alpha = 1;
    beta  = 1;
    f     = 0;
    gd    = [];
    gZ    = [];

    Xhat    =  Z*theta.beta;  
    Resc    = R.*(X - Xhat);
    sigma   = theta.sigma;

    if any(sigma<=0)
      f = -inf; 
      gd = [];
      gZ = [];
      return;
    else
      f = f -0.5*sum(sum(R,1).*(log(sigma.^2))) - 0.5*sum(sum(bsxfun(@times,Resc.^2,1./sigma.^2)));
      f = f -0.5*params.lambdaBeta*(theta.beta(:)'*theta.beta(:));
      f = f - sum((alpha+1)*log(sigma.^2) + beta./(sigma.^2));
    end
    if(nargout>1)
     if(strcmp(type,'all') | strcmp(type,'noZ'))
       gd.beta  = Z'*bsxfun(@times,Resc,1./sigma.^2) - params.lambdaBeta*theta.beta;
       gd.sigma = (-(sum(R,1)+2*(alpha+1))./(sigma) + (2*beta + sum(Resc.^2,1))./(sigma.^3));
     end
     if(strcmp(type,'all') | strcmp(type,'Z'))
       gZ  = bsxfun(@times,Resc,1./sigma.^2)*theta.beta';  
     end
    end
