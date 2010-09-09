function Kc = kernelCentering(K, Ktest)
% Center a kernel matrix
% Kc = kernelCentering(K) returns size n*n
% Kc = kernelCentering(Ktrain, Ktest) returns size ntest * ntrain

% This file is from pmtk3.googlecode.com


%PMTKurl http://www.kernel-methods.net/matlab/algorithms/centering.m
%PMTKauthor John Shawe-Taylor 
%PMTKmodified Kevin Murphy

% See also http://kernel.anu.edu.au/code/kpca_toy.m

if nargin < 2
  n = size(K,1);
  unit = ones(n,n)/n;
  Kc = K - unit*K - K*unit + unit*K*unit;
  H = eye(n) - unit;
  Kc2 = H*K*H;
  assert(approxeq(Kc,Kc2))
else
  n = size(K,1);
  unit = ones(n,n)/n;
  ntest = size(Ktest,1);
  unit_test = ones(ntest,n)/n;
  Kc = Ktest - unit_test*K - Ktest*unit + unit_test*K*unit;
end
