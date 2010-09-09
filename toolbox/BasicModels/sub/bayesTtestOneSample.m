function [BF01, probH0] = bayesTtestOneSample(x)
% BF01 = p(data|H0)/p(data|H1), where H0 says mu=0, H1 says mu is unconstrained
% Reference: "The Bayesian two-sample t-Test", 2005
% M. Gonen and P. Westfall and W. Johnson and Y. Lu

% This file is from pmtk3.googlecode.com


N            = length(x);
t            = mean(x)./(std(x)/sqrt(N));
dof          = N-1;
sigmaD       = 1;

model0.mu    = 0; 
model0.Sigma = 1; 
model0.dof   = dof; 

model1       = model0;
model1.Sigma = 1+sigmaD^2*N; 

BF01           = exp(studentLogprob(model0, t) - studentLogprob(model1, t));

probH0       = 1/(1 + 1/BF01);

end
