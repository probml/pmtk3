function [sigma, shrinkage]=shrink2para(x,shrink)
% Shrink towards a 2 parameter matrix
% function sigma=cov2para(x)
% x (t*n): t iid observations on n random variables
% sigma (n*n): invertible covariance matrix estimator
%
% Shrinks towards two-parameter matrix:
%    all variances are the same
%    all covariances are the same
% if shrink is specified, then this constant is used for shrinkage

% This file is from pmtk3.googlecode.com


% de-mean returns
[t,n]=size(x);
meanx=mean(x);
x=x-meanx(ones(t,1),:);

% compute sample covariance matrix
sample=(1/t).*(x'*x);

% compute prior
meanvar=mean(diag(sample));
meancov=sum(sum(sample(~eye(n))))/(n*(n-1));
prior=meanvar*eye(n)+meancov*(~eye(n));

if (nargin < 2 | shrink == -1) % compute shrinkage parameters
  
  % what we call p 
  y=x.^2;
  phiMat=y'*y/t-2*(x'*x).*sample/t+sample.^2;
  phi=sum(sum(phiMat));  
  
  % what we call r
  diagTerm=0;
  offTerm=0;
  for k=1:t
    cross=x(k,:)'*x(k,:);
    diagTerm=diagTerm+(mean(diag(cross))-meanvar)^2/t;
    cross(logical(eye(n)))=zeros(n,1);
    offTerm=offTerm+(sum(sum(cross))/(n*(n-1))-meancov)^2/t;
  end
  rho=n*diagTerm+(n*(n-1))*offTerm;
  
  % what we call c
  gamma=norm(sample-prior,'fro')^2;

  % compute shrinkage constant
  kappa=(phi-rho)/gamma;
  shrinkage=max(0,min(1,kappa/t));
    
else % use specified constant
  shrinkage=shrink;
end

% compute shrinkage estimator
sigma=shrinkage*prior+(1-shrinkage)*sample;







