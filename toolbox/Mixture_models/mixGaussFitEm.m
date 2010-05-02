function [model, loglikHist] = mixGaussFitEm(data, K, varargin)
% EM for fitting mixture of K gaussians
% data(i,:) is i'th case
% To perform MAP estimation using a vague conjugate prior, use
%  model = mixGaussFitEm(data, K, 'doMAP', 1) [default]
% See emAlgo() for other optional arguments.
%
% Return arguments:
% model is a structure containing these fields:
%   mu(:,) is k'th centroid
%   Sigma(:,:,k)
%   mixweight(k)


[maxIter, convTol, plotfn, verbose, mu, Sigma, mixweight, doMAP, overRelaxFactor] = process_options(...
    varargin, 'maxIter', 100, 'convTol', 1e-4, 'plotfn', [], ...
    'verbose', false, 'mu', [], 'Sigma', [], 'mixweight', [], 'doMAP', 1, ...
    'overRelaxFactor', []);

[N,D] = size(data); %#ok

% Create data-dependent prior
if doMAP
    % set hyper-parameters
    prior.m0 = zeros(D,1);
    prior.kappa0 = 0;
    prior.nu0 = D+2;
    prior.S0 = (1/K^(1/D))*var(data(:))*eye(D);
else
  prior = [];
end

% Initialize params
if isempty(mu)
    [mu, Sigma, mixweight] = kmeansInitMixGauss(data, K);
end

% Fit
model = structure(mu, Sigma, mixweight, prior);
[model, loglikHist]  = emAlgo(model, data, @estep,  @mstep, @mstepOR, ...
  'maxIter', maxIter, 'convTol', convTol, 'verbose', verbose, 'plotfn', plotfn, ...
    'overRelaxFactor', overRelaxFactor);


end

function model = mstep(model, ess)
[D, D2, K] = size(ess.Sk); %#ok
mixweight = normalize(ess.w);
% Set any zero weights to one before dividing
% This is valid because w(c)=0 => WY(:,c)=0, and 0/0=0
w = ess.w + (ess.w==0);
Sigma = zeros(D,D,K);
mu = zeros(D,K);
prior = model.prior;
if ~isempty(prior)
  kappa0 = prior.kappa0; m0 = prior.m0;
  nu0 = prior.nu0; S0 = prior.S0;
  for c=1:K
    mu(:,c) = (w(c)*ess.ybark(:,c)+kappa0*m0)./(w(c)+kappa0);
    a = (kappa0*w(c))./(kappa0 + w(c));
    b = nu0 + w(c) + D + 2;
    Sprior = (ess.ybark(:,c)-m0)*(ess.ybark(:,c)-m0)';
    Sigma(:,:,c) = (S0 + ess.Sk(:,:,c) + a*Sprior)./b;
  end
else
  for c=1:K
    mu(:,c) = ess.ybark(:,c);
    Sigma(:,:,c) = ess.Sk(:,:,c)/w(c);
  end
end
model = structure(mu, Sigma, mixweight, prior);
end
 

function [model, valid] = mstepOR(model, modelBO, eta)
% For over-relaxed EM
[D, D2, K] = size(modelBO.Sigma); %#ok 
% Since weights are constrained to sum to one,
% we do update in softmax parameterization
mixweight = model.mixweight.*(modelBO.mixweight./ model.mixweight).^eta;
mixweight = normalize(mixweight);       
Sigma = zeros(D,D,K);
mu = zeros(D,K);
valid = true;
for c=1:K
  % Regular update
  mu(:,c) = model.mu(:,c) + eta*(modelBO.mu(:,c) - model.mu(:,c));
  %Since Sigma is constrained to positive definite matrices,
  %the updation of Sigma is done in the Log-Euclidean space.
  %(ref: "Fast and Simple Calculus on Tensors in the Log-Euclidean
  %Framework", Vincent Arsigny, Pierre Fillard, Xavier Pennec,
  %and Nicholas Ayache)
  try
    matLogSigma = logm(model.Sigma(:,:,c));
    matLogSigma_BO = logm(modelBO.Sigma(:,:,c));
    matLogSigma = matLogSigma + eta*(matLogSigma_BO - matLogSigma);
    Sigma(:,:,c) = expm(matLogSigma);
  catch %#ok
    valid  = false; return;
  end
  if ~isposdef(Sigma(:,:,c))
    valid = false; return;
  end
end
prior = model.prior;
model = structure(mu, Sigma, mixweight, prior);
end
 

  
function [ess, loglik] = estep(model, data)
[N,D] = size(data);
K = numel(model.mixweight);
Y = data'; % Y(:,i) is i'th case
[z, post, ll] = mixGaussInfer(model, data); %#ok
% post(i,c) = responsibility for cluster c, point i

% Evaluate objective funciton
loglik = sum(ll)/N;
prior = model.prior;
if ~isempty(prior)
  % add log prior
  kappa0 = prior.kappa0; m0 = prior.m0;
  nu0 = prior.nu0; S0 = prior.S0;
  logprior = zeros(1,K);
  for c=1:K
    Sinv = inv(model.Sigma(:,:,c));
    logprior(c) = logdet(Sinv)*(nu0 + D + 2)/2 - 0.5*trace(Sinv*S0) ...
      -kappa0/2*(model.mu(:,c)-m0)'*Sinv*(model.mu(:,c)-m0);
    % does not include log(Z) term, which is constant
    %mod2 = struct('mu', m0, 'Sigma', S0, 'dof', nu0, 'k', kappa0);
    %logp = gaussInvWishartLogprob(mod2, model.mu(:,c), model.Sigma(:,:,c));
    %assert(approxeq(logp, logprior(c)))
  end
  loglik = loglik + sum(logprior)/N;
end

% compute expected sufficient statistics
w = sum(post,1);  % w(c) = sum_i post(c,i)
Sk = zeros(D,D,K);
ybark = zeros(D,K);
for c=1:K
  weights = repmat(post(:,c), 1, D)'; % weights(:,i) = post(i,c)
  Yk = Y .* weights; % Yk(:,i) = post(c,i) * Y(:,i)
  ybark(:,c) = sum(Yk/w(c),2);
  Ykmean = Y - repmat(ybark(:,c),1,N);
  Sk(:,:,c) = weights.*Ykmean*Ykmean';
end

ess = structure(Sk, ybark, w, post);
end

