function CPD = condStudentCpdCreate(mu, Sigma, dof, varargin)
%% Create a conditional student distribution for use in a graphical model
%
% Adapted from code written by Robert Tseng
%%
[prior, dofEstimator] = process_options(varargin, ...
    'prior'       , [], ...          % prior not currently used
    'dofEstimator', @(varargin)dof); % by default don't update dof
                                     % see mixModelFitEm for an example
                                     % estimator.

d = size(Sigma, 1);
if isvector(Sigma)
    Sigma = permute(rowvec(Sigma), [1 3 2]);
end
nstates = size(Sigma, 3);
if size(mu, 2) ~= nstates && size(mu, 1) == nstates
    mu = mu';
end
dof = rowvec(dof); 
CPD = structure(mu, Sigma, nstates, dof, d, prior);
CPD.cpdType    = 'condStudent';
CPD.fitFn      = @condStudentCpdFit;
CPD.fitFnEss   = @(cpd, ess)condStudentCpdFitEss(cpd, ess, dofEstimator);
CPD.essFn      = @condStudentCpdComputeEss;
CPD.logPriorFn = @(varargin)0; % does not currently support a prior
CPD.rndInitFn  = @rndInit;
end

function cpd = rndInit(cpd)
%% randomly initialize
d           = cpd.d;
nstates     = cpd.nstates;
cpd.mu      = randn(d, nstates);
regularizer = 2;
cpd.Sigma   = stackedRandpd(d, nstates, regularizer);
cpd.dof     = 10*ones(1, nstates);
end

function cpd = condStudentCpdFit(cpd, Z, Y)
%% Fit a conditional Gaussian CPD
% Z(i) is the state of the parent Z in observation i.
% Y(i, :) is the ith 1-by-d observation of the child corresponding to Z(i)
%%
d = cpd.d;
Z = colvec(Z);
nstates = cpd.nstates;
mu    = zeros(d, nstates);
Sigma = zeros(d, d, nstates);
dof   = zeros(1, nstates);
for s = 1:nstates
    m              = studentFit(Y(Z == s, :));
    mu(:, s)       = m.mu(:);
    Sigma(:, :, s) = m.Sigma;
    dof(s)         = m.dof;
end
cpd.mu = mu;
cpd.Sigma = Sigma;
cpd.dof   = dof;
end

function ess = condStudentCpdComputeEss(cpd, data, weights, B) %#ok that B is unused
%% Compute the expected sufficient statistics for a condStudentCpd
% data is nobs-by-d
% weights is nobs-by-nstates; the marginal probability of the discrete
% parent for each observation.
% B is ignored, but required by the interface, (since mixture emissions use
% it).
%%
[n, d] = size(data); 
nstates = cpd.nstates;
mu      = cpd.mu;
Sigma   = cpd.Sigma;
dof     = cpd.dof; 
wsum    = sum(weights, 1);
Sw      = zeros(1, nstates);
SX      = zeros(nstates, d);
SXX     = zeros(d, d, nstates);
for c = 1:nstates
    XC           = bsxfun(@minus, data, mu(:, c)');
    delta        = sum((XC/Sigma(:, :, c)).*XC, 2);
    w            = (dof(c) + d) ./ (dof(c) + delta);
    Xw           = msxfun(@times, weights(:, c), data, w(:));
    Sw(c)        = weights(:, c)'* w;
    SX(c, :)     = sum(Xw, 1);
    SXX(:, :, c) = Xw'*data;
end
ess = structure(wsum, Sw, SX, SXX);
end

function cpd = condStudentCpdFitEss(cpd, ess, dofEstimator)
%% Fit a condStudentCpd given expected sufficient statistics
nstates = cpd.nstates;
Sigma   = cpd.Sigma;
SX      = ess.SX;
Sw      = ess.Sw;
SXX     = ess.SXX;
wsum    = ess.wsum;
for c = 1:nstates
    SXc = SX(c, :)';
    Sigma(:, :, c) = (1./wsum(c))*(SXX(:, :, c) - SXc*SXc'./Sw(c));
end
cpd.mu    = bsxfun(@rdivide, SX', Sw);
cpd.Sigma = Sigma;
cpd.dof   = dofEstimator(cpd, ess); 
end