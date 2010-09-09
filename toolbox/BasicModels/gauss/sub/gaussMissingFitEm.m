function [model, loglikHist] = gaussMissingFitEm(data, varargin)
% Find MLE of MVN when X has missing values, using EM algorithm
% data is an n*d design matrix with NaN values
% See emAlgo() for EM related optional args
%PMTKauthor Cody Severinski
%PMTKmodified Kevin Murphy

% This file is from pmtk3.googlecode.com


%%
[n, d]      = size(data);
ismissing   = isnan(data);
missingRows = find(any(ismissing, 2));
X = data'; % it will be easier to work with column vectors
EXsum = zeros(d, 1);
EXXsum = zeros(d, d);
%% Precompute ESS for cases where there is no missing data (E step not needed)
notMissing = setdiffPMTK(1:n, missingRows); 
for row = 1:numel(notMissing)
    i = notMissing(row); 
    EXsum = EXsum + X(:, i);
    EXXsum = EXXsum + X(:, i)*X(:, i)';
end
%%
ess = structure(EXsum, EXXsum, ismissing, missingRows, n);
estepFn = @(model, data)estep(model, data, ess);
initFn = @(model, data, restartNum)init(model, data, restartNum, ismissing);
model.modelType = 'gauss';
[model, loglikHist] = emAlgo(model, X, initFn, estepFn, @mstep, varargin{:});
end

function model = init(model, X, restartNum, ismissing) %#ok
% Initialize
data = X';
nmissing = sum(ismissing(:)); 
data(ismissing) = randn(nmissing, 1); 
model.mu = colvec(mean(data)); 
model.Sigma = cov(data); 
if ~isposdef(model.Sigma)
    model.Sigma = diag(diag(model.Sigma));
end
end

function [ess, loglik] = estep(model, X, ess)
% Compute the expected sufficient statistics
ismissing   = ess.ismissing;
missingRows = ess.missingRows;
mu = model.mu;
Sigma = model.Sigma;
d = numel(mu);
EX = zeros(d,1); EXX = zeros(d, d);
for row = 1:numel(missingRows)
    i = missingRows(row); 
    u = ismissing(i, :); % unobserved entries
    o = ~u; % observed entries
    Vi = Sigma(u, u) - Sigma(u, o) * (Sigma(o, o)\Sigma(o, u));
    mi = mu(u) + Sigma(u, o)*(Sigma(o, o)\(X(o, i)-mu(o)));
    EX(u) = mi;
    EX(o) = X(o, i);
    EXX(u, u) = EX(u) * EX(u)' + Vi;
    EXX(o, o) = EX(o) * EX(o)';
    EXX(o, u) = EX(o) * EX(u)';
    EXX(u, o) = EX(u) * EX(o)';
    ess.EXsum = ess.EXsum + EX;
    ess.EXXsum = ess.EXXsum + EXX;
end
loglik = sum(gaussLogprobMissingData(model, X'));
end

function model = mstep(model, ess)
% Maximize
n = ess.n;
model.mu = ess.EXsum/n;
model.Sigma = ess.EXXsum/n - model.mu*model.mu';
end
