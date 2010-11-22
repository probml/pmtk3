function [BF01, probH0] = bayesTtestTwoSample(x,y,xbar,ybar,Nx,Ny,sx,sy)
% BF01 = p(data|H0)/p(data|H1), where H0 says delta=0, H1 says delta is unconstrained
% probH0 = p(model=H0|data)
%
% Usage:
% [BF01, probH0] = bayesTtestTwoSample(x,y)
% or
% [BF01, probH0] = bayesTtestTwoSample([],[],xbar,ybar,Nx,Ny,sx,sy)
%
% References:
% "The Bayesian two-sample t-Test", 2005
% M. Gonen and P. Westfall and W. Johnson and Y. Lu
% "Bayesian t tests for accepting and rejecting the null hypothesis", 2009
% J. Rouder and P. Speckman and D. Sun and R. Morey

% This file is from pmtk3.googlecode.com


if ~isempty(x)
  % compute sufficient statistics
  xbar         = mean(x);
  ybar         = mean(y);
  Nx           = length(x);
  Ny           = length(y);
  sx           = std(x);
  sy           = std(y);
end

sp           = sqrt( ( (Nx-1)*sx^2 + (Ny-1)*sy^2 )/(Nx+Ny-2));
Ndelta       = 1/(1/Nx + 1/Ny);
t            = (xbar-ybar)/(sp / sqrt(Ndelta));
dof          = Nx+Ny-2;
sigmaD       = 1; %1/3; % sd of effect size

model0.mu    = 0; 
model0.Sigma = 1; 
model0.dof   = dof; 

model1      = model0;  % we assume lambda (mean of effect size) is 0
model1.Sigma =  1+sigmaD^2*Ndelta; 
BF01          = exp(studentLogprob(model0, t) - studentLogprob(model1, t));
probH0       = 1/(1 + 1/BF01);

end
