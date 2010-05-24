function [model, loglikHist] = gaussMissingFitEm(data, varargin)
% Find MLE of MVN when X has missing values, using EM algorithm
% data is an n*d design matrix with NaN values
% See emAlgo() for EM related optional args
%PMTKauthor Cody Severinski
%PMTKmodified Kevin Murphy
%%
[n, d]      = size(data);
ismissing   = isnan(data);
missingRows = find(any(ismissing, 2));
X = data'; % it will be easier to work with column vectors
expVals = zeros(d, n);
expProd = zeros(d, d, n);
%% If there is no missing data, then just plug-in -- E step not needed
notMissing = setdiffPMTK(1:n, missingRows); 
for row = 1:numel(notMissing)
    i = notMissing(row); 
    expVals(:, i) = X(:, i);
    expProd(:, :, i) = X(:, i)*X(:, i)';
end
%%
ess = structure(expVals, expProd, ismissing, missingRows, n);
estepFn = @(model, data)estep(model, data, ess);
initFn = @(model, data, restartNum)init(model, data, restartNum, ismissing); 
[model, loglikHist] = emAlgo([], X, initFn, estepFn, @mstep, varargin{:});
end

function model = init(model, X, restartNum, ismissing)
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
expVals     = ess.expVals;
expProd     = ess.expProd;
ismissing   = ess.ismissing;
missingRows = ess.missingRows;
mu = model.mu;
Sigma = model.Sigma; 
for row = 1:numel(missingRows)
    i = missingRows(row); 
    u = ismissing(i, :); % unobserved entries
    o = ~u; % observed entries
    Si = Sigma(u, u) - Sigma(u, o) * (Sigma(o, o)\Sigma(o, u));
    expVals(u, i) = mu(u) + Sigma(u, o)*(Sigma(o, o)\(X(o, i)-mu(o)));
    expVals(o, i) = X(o, i);
    expProd(u, u, i) = expVals(u, i) * expVals(u, i)' + Si;
    expProd(o, o, i) = expVals(o, i) * expVals(o, i)';
    expProd(o, u, i) = expVals(o, i) * expVals(u, i)';
    expProd(u, o, i) = expVals(u, i) * expVals(o, i)';
end
ess.expVals = expVals;
ess.expProd = expProd; 
loglik = sum(gaussLogprobMissingData(model, X'));
end

function model = mstep(model, ess)
% Maximize
n = ess.n;
mu = sum(ess.expVals, 2)/n;
Sigma = sum(ess.expProd, 3)/n - mu*mu';
model = structure(mu, Sigma);
end
