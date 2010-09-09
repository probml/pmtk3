function y = tabularCpdSample(CPD, pvals)
%  Draw a random sample from P(Xi | x(pi_i), theta_i)  (discrete)
% pvals(i) is the value of the ith parent
% Currently all parents must be specified

% This file is from pmtk3.googlecode.com

if nargin < 2, pvals = []; end
assert(numel(pvals) == numel(CPD.sizes) - 1); 
ndx = num2cell(pvals); 
y =  sampleDiscrete(squeeze(CPD.T(ndx{:}, :))); 

end
