function [model, loglikHist] = mixGaussBayesFit(X, K, varargin)
% Variational Bayes for fitting mixture of K gaussians
% data(i,:) is i'th case
% See Bishop sec 10.2 for details
%
%PMTKauthor Emtiyaz Khan, Cody Severinski, Kevin Murphy

% This file is from pmtk3.googlecode.com

[maxIter, thresh, plotFn, verbose, alpha0] = process_options(...
    varargin, 'maxIter', 200, 'thresh', 1e-5, 'plotFn', [], ...
    'verbose', false, 'alpha0', 0.001);


[N,D] = size(X);

%% define a vague prior
alpha = alpha0*ones(1,K);
m = zeros(K,D);
beta = 1*ones(1,K); % low precision for mean
%Sigma = diag(var(X));
%W = (K^(1/D))*repmat(inv(Sigma), [1,1,K]); % Fraley and Raftery heuristic
W = 200*repmat(eye(D),[1 1 K]);
%v = 5*(D+2)*ones(1,K); % smallest valid dof
v = 20*ones(1,K);
model.priorParams = mixGaussBayesStructure(alpha, beta, m, v, W, []);
model.K = K;



%% Initialization
if 0
  setSeed(1);
  [mu, Sigma, mixweight, Nk] = kmeansInitMixGauss(X, K); %#ok
  xbar = mu';
  S = Sigma;
else
  % Emt's method - uses netlab
  ncentres = K;
  setSeed(1);
  mix = gmm(D, ncentres, 'full');
  options = foptions;
  options(14) = 10;
  mix = gmminit(mix, X, options);
  options(3) = 0.1; options(14) = 30;
  [mix, options, errlog] =  gmmem(mix, X, options);
  Nk = N*mix.priors;
  xbar = mix.centres;
  S = mix.covars;
end
model.postParams = Mstep(Nk, xbar, S, model.priorParams);


%% Main loop
iter = 1;
done = false;
while ~done
  % E step 
  [z, rnk, ll, logrnk] = mixGaussBayesInfer(model, X); %#ok
  [Nk, xbar, S] = computeEss(X, rnk);
  loglikHist(iter) = lowerBound(model,  Nk, xbar, S, rnk, logrnk, iter); %#ok
   
  % M step
  model.postParams = Mstep(Nk, xbar, S, model.priorParams);

  
  p = model.postParams;
  if ~isempty(plotFn)
    plotFn(X, p.alpha, p.m, p.W, p.v, loglikHist(iter), iter);
  end
  
  % Converged?
  if iter == 1
     converged = false;
  else
     converged =  convergenceTest(loglikHist(iter), loglikHist(iter-1), thresh);
  end
  done = converged || (iter > maxIter);
  if verbose, fprintf(1, 'iteration %d, loglik = %f\n', iter, loglikHist(iter)); end
  iter = iter + 1;
end 


end

function [Nk, SSxbar, SSXX] = computeEss(X, weights)
% weights(n,k)
 K = size(weights,2);
  d = size(X,2);
  Nk = sum(weights,1); % 10.51
  Nk = Nk + 1e-10;
  SSxbar = zeros(K,d); SSXX = zeros(d,d,K);
  for k=1:K
    SSxbar(k,:) = sum(bsxfun(@times, X, weights(:,k))) / Nk(k); % 10.52
    XC = bsxfun(@minus,X,SSxbar(k,:));
    SSXX(:,:,k) = bsxfun(@times, XC, weights(:,k))'*XC / Nk(k); % 10.53
  end
end


function postParams = Mstep(Nk, xbar, S, priorParams)

[alpha0, beta0, entropy0, invW0, logDirConst0, logLambdaTilde0, ...
    logPiTilde0, logWishartConst0, m0, v0] = ...
  structvals(priorParams, 'alpha', 'beta', 'entropy','invW', ...
  'logDirConst', 'logLambdaTilde', 'logPiTilde', 'logWishartConst', 'm', ...
  'v'); 

K = numel(alpha0);
d = size(xbar,2);
alpha = alpha0 + Nk; % Bishop 10.58
beta = beta0 + Nk;  % Bishop 10.60
m = zeros(K,d); v = zeros(1,K);
invW = zeros(d,d,K); 
for k=1:K
  if Nk(k) < 0.001 % extinguished
    m(k,:) = m0(k,:); invW(:,:,k) = invW0(:,:,k); v(k) = v0(k);
  else
    m(k,:) = ( beta0(k)*m0(k,:) + Nk(k)*xbar(k,:) ) / beta(k); % 10.61
    invW(:,:,k) = invW0(:,:,k) + Nk(k)*S(:,:,k) + ...
      (beta0(k)*Nk(k) / (beta0(k) + Nk(k)) ) * (xbar(k,:) - m0(k,:))'*(xbar(k,:) - m0(k,:)); % 10.62
    %W(:,:,k) = inv(invW(:,:,k));
    if any(any(isnan(invW(:,:,k)))), keyboard; end
    v(k) = v0(k) + Nk(k); % 10.63
  end
end
postParams = mixGaussBayesStructure(alpha, beta, m, v, [], invW);
end


function L = lowerBound(model,  Nk, xbar, S, rnk, logrnk, iter)
% Bishop sec 10.2.2

[alpha, beta, entropy, invW, logDirConst, logLambdaTilde, logPiTilde, logWishartConst, m, v, W] = ...
  structvals(model.postParams, ...
  'alpha', 'beta', 'entropy', 'invW', 'logDirConst', 'logLambdaTilde',...
  'logPiTilde', 'logWishartConst', 'm', 'v', 'W'); 
[alpha0, beta0, entropy0, invW0, logDirConst0, logLambdaTilde0, logPiTilde0, logWishartConst0, m0, v0, W0] = ...
  structvals(model.priorParams,  'alpha', 'beta', 'entropy', 'invW', 'logDirConst', 'logLambdaTilde',...
  'logPiTilde', 'logWishartConst', 'm', 'v', 'W'); %#ok

[D,D2,K] = size(W); %#ok

%10.71
ElogpX = zeros(1,K); 
for k=1:K
  xbarc = xbar(k,:) - m(k,:);
  ElogpX(k) = 0.5*Nk(k)*(logLambdaTilde(k) - D/beta(k) - trace(v(k)*S(:,:,k)*W(:,:,k)) ...
    - v(k)*sum((xbarc*W(:,:,k)).*xbarc,2) - D*log(2*pi)); % 10.71
end
ElogpX = sum(ElogpX);

%10.72
ElogpZ = sum(Nk.*logPiTilde); 

% 10.73
Elogppi = logDirConst0 + sum((alpha0-1).*logPiTilde); 

%10.74
ElogpmuSigma = zeros(1,K);
for k=1:K
  mc = m(k,:) - m0(k,:);
  %logB0(k) = (v0(k)/2)*logdet(invW0(:,:,k)) - (v0(k)*D/2)*log(2) ...
  %        - (D*(D-1)/4)*log(pi) - sum(gammaln(0.5*(v0(k)+1 -[1:D])));       
  ElogpmuSigma(k) = 0.5*(D*log(beta0(k)/(2*pi)) + logLambdaTilde(k) - D*beta0(k)/beta(k) ...
    - beta0(k)*v(k)*sum((mc*W(:,:,k)).*mc,2)) + logWishartConst0(k) ...
    + 0.5*(v0(k) - D - 1)*logLambdaTilde(k) ...
    - 0.5*v(k)*trace(invW0(:,:,k)*W(:,:,k)); 
end
ElogpmuSigma = sum(ElogpmuSigma);

% Entropy terms
%10.75
%ElogqZ = sum(sum(rnk.*log(rnk)));
ElogqZ = sum(sum(rnk.*logrnk));

%10.76
Elogqpi = sum((alpha - 1).*logPiTilde) + logDirConst;

%10.77
ElogqmuSigma = sum(1/2*logLambdaTilde + D/2*log(beta./(2*pi)) - D/2 - entropy);

% Overall sum
% 10.70
L = ElogpX + ElogpZ + Elogppi + ElogpmuSigma - ElogqZ - Elogqpi - ElogqmuSigma;

if isnan(L)
  [ElogpX  ElogpZ  Elogppi  ElogpmuSigma  ElogqZ  Elogqpi  ElogqmuSigma]
  keyboard
end

end


function params = mixGaussBayesStructure(alpha, beta, m, v, W, invW)
if isempty(invW)
  [D, D2, K] = size(W); %#ok
else
  [D,D2,K] = size(invW);
end
% store the params
params.alpha = alpha;
params.beta = beta;
params.m = m;
params.v = v; 
params.W = zeros(D,D,K);
params.invW = zeros(D,D,K);
for k=1:K
  if isempty(invW)
    params.W(:,:,k) = W(:,:,k);
    params.invW(:,:,k) = inv(W(:,:,k));
  end
  if isempty(W)
    params.invW(:,:,k) = invW(:,:,k);
    params.W(:,:,k) = inv(invW(:,:,k));
  end
end

% precompute various functions of the distribution for speed
params.logPiTilde = digamma(alpha) - digamma(sum(alpha)); % E[ln(pi(k))] 10.66 
logdetW = zeros(1,K); 
params.logLambdaTilde = zeros(1,K);% E[ln(Lambda(:,:,k))] 
params.entropy = zeros(1,K);
params.logDirConst = gammaln(sum(alpha)) - sum(gammaln(alpha)); % B.23
for k=1:K
  logdetW(k) = logdet(params.W(:,:,k));
  params.logLambdaTilde(k) = sum(digamma(1/2*(v(k) + 1 - [1:D]))) + D*log(2)  + logdetW(k);  % B.81 
  logB(k) = -(v(k)/2)*logdetW(k) - (v(k)*D/2)*log(2) ...
          - (D*(D-1)/4)*log(pi) - sum(gammaln(0.5*(v(k)+1 -[1:D])));
  params.logWishartConst(k) = -(v(k)/2)*logdetW(k) -(v(k)*D/2)*log(2) - mvtGammaln(D,v(k)/2); % B.79
  assert(approxeq(logB(k), params.logWishartConst(k)))
  params.entropy(k) = -params.logWishartConst(k) - (v(k)-D-1)/2*params.logLambdaTilde(k) + v(k)*D/2; % B.82
  
  %params.logLambdaTilde(k) = wishartExpectedLogDet(params.W(:,:,k), v(k), logdetW(k));
  %params.entropy(k) = wishartEntropy(params.W(:,:,k), v(k), logdetW(k));
  %params.logWishartConst(k) = wishartLogConst(params.W(:,:,k), v(k), logdetW(k));
end

end


function [lnZ] = wishartLogConst(W, v, logdetW) % Bishop B.79
  d = size(W,1);
  if nargin < 3, logdetW = logdet(W); end
  lnZ = -(v/2)*logdetW -(v*d/2)*log(2) - mvtGammaln(d,v/2);
end

function [h] = wishartEntropy(W, v, logdetW) % bishop  B.82
  d = size(W,1);
  if nargin < 3, logdetW = logdet(W); end
  h = -wishartLogConst(W, v, logdetW) - ...
    (v-d-1)/2*wishartExpectedLogDet(W, v, logdetW) + v*d/2;
end

function logLambdaTilde = wishartExpectedLogDet(W, v, logdetW) % bishop B.81
d = size(W,1);
if nargin < 3, logdetW = logdet(W); end
logLambdaTilde = sum(digamma(1/2*(v + 1 - [1:d]))) + d*log(2)  + logdetW;
end
  




