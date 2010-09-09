function [model, loglikHist] = studentFitEm(X, varargin)
% Fit multivariate student T distribution usign EM or ECME.
%
%% Inputs
% X(i, :) is the ith case
%
%% Optional named inputs
%
% dof     - if known, specify the degrees of freedom, otherwise this is
%           estimated using either EM, (see Liu and Rubin Statisitic
%           Sinica 1995) or ECMC.
%
% mu0     - initial value for mu instead of a random initialization.
%           recommended value: mean(X)'
%
% Sigma0  - initial value for Sigma instead of a random initialization
%           recommended value: cov(X)
%
% dof0    - initial value for dof if we are estimating it, instead of a
%           random initialization.
%           recommended value: 10
%
%           (ECME = expectation conditional maximize of either Q or loglik)
% useECME - [true] if true and dof is empty, we optimize dof wrt the
%           observed data log likelihood, otherwise wrt to Q.
%
% useSpeedup - [true] if true, we use the data augmentation trick of Meng
%              and van Dyk.
%
% *** see EmAlgo for additional EM related options ***
%
%% Output
%
% model      - a struct with fields, mu, Sigma, dof
%
% loglikHist - the log likelihood history
%%

% This file is from pmtk3.googlecode.com

[model.dof, model.mu, model.Sigma, dof0, useECME, useSpeedup, EMargs]...
    = process_options(varargin , ...
    'dof'        , []          , ...
    'mu0'        , []          , ...
    'Sigma0'     , []          , ...
    'dof0'       , []          , ...
    'useECME'    , true        , ...
    'useSpeedup' , true        );
if isvector(X),
    X = X(:);
end
if isempty(model.dof)
    if useECME
        dofEstimator = @(model)estimateDofNLL(model, X);
    else
        dofEstimator = @(model)estimateDofQ(model, X);
    end
else
    dofEstimator = [];
end
initFn  = @(model, data, restartNum)init(model, data, restartNum, dof0); 
estepFn = @(model, X)estep(model, X, useSpeedup);
mstepFn = @(model, ess)mstep(model, ess, dofEstimator);
[model, loglikHist] = emAlgo(model, X, initFn, estepFn, mstepFn, EMargs{:});
end % end of studentFitEm

function model = init(model, X, restartNum, dof0)
%% Initialize

D = size(X, 2);
if isempty(model.mu)
    model.mu = randn(D, 1);
end
if isempty(model.Sigma)
    model.Sigma = diag(rand(D, 1));
end
if isempty(model.dof)
    if isempty(dof0)
        model.dof = ceil(5*rand());
    else
        model.dof = dof0;
    end
end
end

function [ess, loglik] = estep(model, X, useSpeedup)
%% Compute the expected sufficient statistics
loglik   = sum(studentLogprob(model, X));
mu       = model.mu;
Sigma    = model.Sigma;
dof      = model.dof;
[N, D]   = size(X);
%SigmaInv = inv(Sigma);
XC = bsxfun(@minus,X,rowvec(mu));
delta =  sum((XC/Sigma).*XC,2);
w = (dof+D) ./ (dof+delta);      % E[tau(i)]
if useSpeedup % see McLachlan and Krishnan eqn 5.97-5.98
    aopt = 1/(dof+D);
    w = (1./det(Sigma))^aopt * w; % det(SigmaInv) == 1/det(Sigma)
end
Xw = X .* repmat(w(:), 1, D);
ess.Sw  = sum(w);
ess.SX  = sum(Xw, 1)'; % sum_i u(i) xi, column vector
ess.SXX = Xw'*X;       % sum_i u(i) xi xi'
if useSpeedup,
    ess.denom = ess.Sw;
else
    ess.denom = N;
end
end

function model = mstep(model, ess, dofEstimator)
%% Maximize
SX    = ess.SX;
Sw    = ess.Sw;
SXX   = ess.SXX;
denom = ess.denom;
model.mu    = SX / Sw;
model.Sigma = (1/denom)*(SXX - SX*SX'/Sw); % Liu,Rubin eqn 16
if ~isempty(dofEstimator)
    model.dof = dofEstimator(model);
end
end

function dof = estimateDofQ(model, X)
%% Optimize expected neg log likelihood of complete data using constrained
%% gradient optimizer.
mu     = model.mu;
Sigma  = model.Sigma;
dofOld = model.dof;
[N,D]  = size(X);
%% re-do E step to get multicycle ECM algorithm
XC    = bsxfun(@minus,X,rowvec(mu));
delta =  sum((XC/Sigma).*XC,2); 
w     = (dofOld+D) ./ (dofOld+delta); % E[u(i)]
dofMin = 0.1;
dofMax = 1000; 
%% use gradient free optimizatin
Qfn = @(v) -N*gammaln(v/2)+N*v*0.5*log(v/2) + ...
            (N*v/2)*((1/N)*sum(log(w)-w)    + ...
            psi((dofOld+D)/2)-log((dofOld+D)/2));
negQfn = @(v) -Qfn(v);
dof    = fminbnd(negQfn, dofMin, dofMax);

if 0
    %% or use gradient based optimization
    utilde = w;
    stilde = log(utilde) + psi((dofOld+D)/2) - log((dofOld+D)/2);
    gradQfn = @(v) (N/2)*(-psi(v/2)+log(v/2)+1)+...
        0.5*sum(stilde - utilde);
    gradNegQfn = @(v) -gradQfn(v);
    % find zero of the gradient by doing a constrained 1d line search
    fn = @(v) fnjoin(v, negQfn, gradNegQfn);
    options.verbose = 0;
    options.numDiff = 0;
    [dof2] = minConF_TMP(fn,dofOld,dofMin,dofMax,options);
    assert(approxeq(dof, dof2, 1e-1))
end
end % of of estimateDofQ

function dof = estimateDofNLL(model, X)
%% Optimize neg log likelihood of observed data using gradient free optimizer.
% use unconstrained optimization - plug in most recent params to compute
% NLL
mu = model.mu;
Sigma = model.Sigma;
nllfn = @(v) -sum(studentLogprob(studentCreate(mu, Sigma, v), X));
dofMax = 1000; dofMin = 0.1;
dof = fminbnd(nllfn, dofMin, dofMax);

if 0
    %% or use constrained gradient based method
    % eqn 30 from Liu and Rubin 1995 is the gradient of the observed data loglik
    % using the most recent values of mu and Sigma
    % This is not sufficiently much faster to be worth the complexity
    % re-do E step
    SigmaInv = inv(Sigma); %#ok
    XC = bsxfun(@minus,X,rowvec(mu));
    delta =  sum(XC*SigmaInv.*XC,2); % mahalanobis distance
    wfn = @(v) (v+D)./(v+delta);
    gradfn = @(v) -N*(-psi(v/2)+log(v/2)+sum(log(wfn(v))-wfn(v))/N + 1 + ...
        psi((dofOld+D)/2)-log((dofOld+D)/2));
    % find zero of the gradient by doing a 1d line search
    fn = @(v) fnjoin(v, nllfn, gradfn);
    options.verbose = 0;
    dof2 = minConF_TMP(fn,dofOld,dofMin,dofMax,options);
    assert(approxeq(dof, dof2))
end
end
