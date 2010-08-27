function [model, loglikHist] = mixStudentFitEm(data, K, varargin)
%% Fit a mixture of K student-t distributions using EM.
%
%% Inputs
% 
% data     - [n, d]: data(i, :) is the ith case
% K        - the number of mixture components to use
%
%% Optional named inputs
%
% 'mu0'      - [d k]:   specify an initial value for mu, instead of 
%                       initializing using kmeans.
%
% 'Sigma0'   - [d d K]: specify an intial value for Sigma instead of
%                       initializing using kmeans. 
%
% 'mixweight0' - [1 K]: specify an initial value for mixweight instead of 
%                       initializing using kmeans. 
% 
% 'dof0'       - [1 K]: specify an initial value for dof, otherwise
%                       10*ones(1, K) is used. 
%
% * see emAlgo for additional EM related optional args *
%
%% Outputs
%
% model is a structure containing these fields:
%   mu(:, k) is k'th centroid
%   Sigma(:, :, k)
%   mixweight(k)
%   dof(k)
%   K
%
% loglikHist(t) for plotting
%%
%PMTKauthor Robert Tseng
%PMTKmodified Kevin Murphy, Matt Dunham
%%
[model.mu, model.Sigma, model.dof, model.mixweight, EMargs]...
    = process_options(varargin , ...
    'mu0'        , []          , ...
    'Sigma0'     , []          , ...
    'dof0'       , []          , ...
    'mixweight0' , []          );
%%
model.K = K; 
dofEstimator        = @(model, c)estimateDofNLL(model, data, c); 
mstepFn             = @(model, ess)mstep(model, ess, dofEstimator);
[model, loglikHist] = emAlgo(model, data, @init, @estep, mstepFn, EMargs{:}); 
end

function model = init(model, X, restartNum)%#ok
%% Initialize
K = model.K;
if isempty(model.mu) || isempty(model.Sigma) || isempty(model.mixweight)
    [mu, Sigma, mixweight] = kmeansInitMixGauss(X, K);
end
if isempty(model.mu)        , model.mu        = mu;            end
if isempty(model.Sigma)     , model.Sigma     = Sigma;         end
if isempty(model.mixweight) , model.mixweight = mixweight;     end
if isempty(model.dof)       , model.dof       = 10*ones(1, K); end

model.d = size(X, 2); 
end

function [ess, loglik] = estep(model, X)
%% Compute expected sufficient statistics
mu     = model.mu;
Sigma  = model.Sigma;
dof    = model.dof; 
K      = model.K; 
[N, D] = size(X); 

[z, post, ll] = mixStudentInfer(model, X);
loglik = sum(ll);

R   = sum(post, 1);
Sw  = zeros(1, K);
SX  = zeros(K, D); 
SXX = zeros(D, D, K); 
for c=1:K
    XC           = bsxfun(@minus, X, rowvec(mu(:, c)));
    delta        = sum((XC/Sigma(:, :, c)).*XC, 2);
    w            = (dof(c) + D) ./ (dof(c) + delta); 
    Xw           = msxfun(@times, post(:, c), X, w(:)); 
    Sw(c)        = post(:, c)'* w;
    SX(c, :)     = sum(Xw, 1); 
    SXX(:, :, c) = Xw'*X; 
end
ess = structure(R, Sw, SX, SXX); 
end

function model = mstep(model, ess, dofEstimator)
%% Maximize
K     = model.K;
Sigma = model.Sigma;
SX    = ess.SX;
Sw    = ess.Sw;
SXX   = ess.SXX;
R     = ess.R; 
for c=1:K
    SXc = SX(c, :)';
    Sigma(:, :, c) = (1./R(c))*(SXX(:, :, c) - SXc*SXc'./Sw(c));
end
model.mu        = bsxfun(@rdivide, SX', Sw);
model.Sigma     = Sigma; 
model.mixweight = normalize(ess.R); 
dof             = model.dof; 
for c=1:K
    dof(c) = dofEstimator(model, c); % ECME
end
model.dof = dof; 
end

function dof = estimateDofNLL(model, X, curK)
%% Optimize neg log likelihood of observed data
%% using gradient free optimizer.
nllfn = @(v) NLL(model, X, curK, v);
dofMin = 0.1;
dofMax = 1000; 
dof = fminbnd(nllfn, dofMin, dofMax);
end

function out = NLL(model, X, curK, v)
%% Negative Log Likelihood
model.dof(curK) = v;
out = -sum(mixStudentLogprob(model, X));
end