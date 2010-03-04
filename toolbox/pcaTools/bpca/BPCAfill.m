function [y,M] = BPCAfill(x999, k, maxepoch)
% y = BPCAfill(x999, [k [,maxepoch]])
%  Bayesian PCA missing value estimator
%   made by Shigeyuki OBA, 2002  May. 5th
%
% usage
% (1)
%  y = BPCAfill( x999 );
%    Returns a matrix whose missing values are 
%    filled by estimated value.
%    x999 is a missing value conterminated matrix.
%    Value '999' in x999 means that they are missing.
%    
%    The size of x999
%        [N, M] = size(999)
%    is arbitrary but N>M is preferable.
%
%    When the size of x999 is too large,
%    computation costs much time.
%
% usage
% (2)
%  y = BPCAfill( x999, k, maxepoch );
%    Default value of k is M-1, maxepoch is 100
%    and when k or maxepoch value
%    is set to be smaller integer value
%    computation time will be also smaller
%    but the estimation error might be larger. 
%
% usage
% (3)
% [y, M] = BPCAfill( x999 );
%    You can get also Bayesian PCA result M.
%    M is a Matlab structure variable which contains 
%    M.mu : estimated mean row vector
%    M.W  : estimated principal axes matrix
%      for example M.W(:,1) is the 1st. principal axis vector.
%    M.tau : estimated precision (inverse variance) of
%            the residual error.
%    and so on.
%
% ----------------------------------------------------------
% * When there are genes whos entire expressions are missing,
%   they are left as they are missing.

[N,d] = size(x999);
if nargin < 3
  maxepoch = 200;
end
if nargin < 2;
  k = d-1;
end

nm = sum(x999>990,2);
id = find(nm~=d);

M = BPCA_initmodel(x999(id,:), k);
tauold = 1000;
for epoch = 1:maxepoch
  M = BPCA_dostep(M, x999(id,:));
  if mod(epoch,10)==0
    tau = M.tau;
    dtau = abs(log10(tau)-log10(tauold));
    disp(sprintf('epoch=%d, dtau=%g', epoch, dtau));
    if dtau<1e-4
      break
    end
    tauold = tau;
  end
end
y = x999;
y(id,:) = M.yest;

end