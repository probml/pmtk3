function [model, loglikHist] = binaryFAfit(Y, K,  varargin)
%% Fit factor analysis for binary data (using EM)
%
%
% Inputs
%
% Y     - Y(n,t) in {0,1} or {1,2}  
% K - num latent dims
%
% If you don't request loglikHist, we don't compute
% loglik, which is quite slow (35% of the time!)

% This file is from pmtk3.googlecode.com


EMargs = varargin;
Y = canonizeLabels(Y) - 1; % {0,1}
[N,T] = size(Y);
model.type  = 'binaryFA';
model.K = K;
model.T = T;

[model, loglikHist] = emAlgo(model, Y, @initFn, @estep, @mstep , ...
  'computeLoglik', (nargout >= 2), EMargs{:});
end

function model = initFn(model, Y, restartNum) %#ok ignores Y
K = model.K; % num latent
T = model.T; % num observed
model.W = 0.1*randn(K, T);
model.b = 0.01*randn(T, 1); % bias on observed nodes
model.muPrior = zeros(K,1);
model.SigmaPrior = eye(K,K);

end


function [ess, loglik] = estep(model, data)
computeLoglik = (nargout >= 2);
q = model.K;
Y  = data';
[p,N] = size(Y);
debug = false;
q1 = q+1;
S1 = zeros(q1,p); S2 = zeros(q1,q1,p);
%ess.S1 = zeros(q1,p); ess.S2 = zeros(q1,q1,p);
loglik = 0;
W = model.W; b = model.b;
muPrior = model.muPrior; SigmaPriorInv = inv(model.SigmaPrior);
for n=1:N
    [muPost, SigmaPost, logZ, lambda] = ...
      varInferLogisticGauss(Y(:,n), W, b, muPrior, SigmaPriorInv,  computeLoglik);
  loglik = loglik + logZ;
  
  if debug
    % Check Tipping's formulas agree with Murphy UAI'99
    % Only equivalent if we use the same number of iterations inside
    % varInfer and if we initialize the variational params in the same way
    [muPost, SigmaPost, logZ] = ...
      varInferLogisticGaussCanonical(Y(:,n), W, b, muPrior, SigmaPriorInv, 'maxIter', 3);
    [muPost2, SigmaPost2, lambda2, logZ2] = ...
      varInferLogisticGauss(Y(:,n), W, b, muPrior, SigmaPriorInv);
    assert(approxeq(muPost(:,n), muPost2(:,n)))
    assert(approxeq(SigmaPost, SigmaPost2))
    assert(approxeq(lambda, lambda2))
    assert(approxeq(logZ, logZ2))
  end
  
  % expected sufficient statistics
  EZZ = zeros(q+1, q+1);
  EZZ(1:q,1:q) = SigmaPost + muPost*muPost';
  EZZ(q+1,1:q) = muPost';
  EZZ(1:q,q+1) = muPost;
  EZZ(q+1,q+1) = 1;
  EZ = [muPost; 1];
  %{
  A = -diag(2*lambda);
  bb = -0.5*ones(p,1);
  invA = -diag(1./(2*lambda));
  ytilde = invA*(bb + Y(:,n));
  ess.S1 = ess.S1 + EZ*ytilde*A';
  ess.S2 = ess.S2 + A*EZZ;
  %}
  for i=1:p
    S1(:,i) = S1(:,i) + (Y(i,n) - 0.5) * EZ;
    S2(:,:,i) = S2(:,:,i) - 2*lambda(i)*EZZ;
  end
end
%assert(approxeq(ess.S1, S1))
%assert(approxeq(ess.S2, S2))
ess.S1 = S1; ess.S2 = S2;
end

function model = mstep(model, ess)
S1 = ess.S1; S2 = ess.S2;
p = model.T; q = model.K;
 for i=1:p
    what = S2(:,:,i) \ S1(:,i);
    model.W(:,i) = what(1:q);
    model.b(i) = what(q+1);
  end
end
