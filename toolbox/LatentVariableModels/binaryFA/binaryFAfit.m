function [model, loglikHist] = binaryFAfit(Y, K,  varargin)
%% Fit factor analysis for binary data (using EM)
%
%
%% Inputs
%
% Y     - Y(n,t) in {0,1} or {1,2}  
% K - num latent dims


% This file is from pmtk3.googlecode.com


EMargs = varargin;
Y = canonizeLabels(Y) - 1; % {0,1}
[N,T] = size(Y);
model.type  = 'binaryFA';
model.K = K;
model.T = T;

[model, loglikHist] = emAlgo(model, Y, @initFn, @estep, @mstep , EMargs{:});
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
q = model.K;
Y  = data';
[p,N] = size(Y);
debug = false;
q1 = q+1;
S2 = zeros(q1,q1,p);
S1 = zeros(q1,p);
loglik = 0;
W = model.W; b = model.b;
muPrior = model.muPrior; SigmaPriorInv = inv(model.SigmaPrior);
for n=1:N
 
  [muPost, SigmaPost, logZ, lambda] = ...
    varInferLogisticGauss(Y(:,n), W, b, muPrior, SigmaPriorInv);
  loglik = loglik + logZ;
  
  if debug
    % Check Tipping's formulas agree with Murphy UAI'99
    % Only equivalent if we use the same number of iterations inside
    % varInfer and if we initialize the var params in the same way
    [muPost, SigmaPost, logZ] = ...
      varInferLogisticGaussCanonical(Y(:,n), W, b, muPrior, SigmaPriorInv, 'maxIter', 3);
    [muPost2, SigmaPost2, lambda2, logZ2] = ...
      varInferLogisticGauss(Y(:,n), W, b, muPrior, SigmaPriorInv, 'maxIter', 3);
    assert(approxeq(muPost(:,n), muPost2(:,n)))
    assert(approxeq(SigmaPost, SigmaPost2))
    assert(approxeq(lambda, lambda2))
    assert(approxeq(logZ, logZ2))
  end
  
  for i=1:p % can we vectorize this?
    Sn = SigmaPost + muPost*muPost';
    Mn = zeros(q1, q1);
    Mn(1:q,1:q) = Sn;
    Mn(q+1,1:q) = muPost';
    Mn(1:q,q+1) = muPost;
    Mn(q+1,q+1) = 1;
    S2(:,:,i) = S2(:,:,i) + 2*lambda(i)*Mn;
    S1(:,i) = S1(:,i) + (Y(i,n) - 0.5) * [muPost; 1];
  end
  
end
ess.S1 = S1; ess.S2 = S2;
end

function model = mstep(model, ess)
S1 = ess.S1; S2 = ess.S2;
p = model.T; q = model.K;
 for i=1:p
    what = -S2(:,:,i) \ S1(:,i);
    model.W(:,i) = what(1:q);
    model.b(i) = what(q+1);
  end
end
