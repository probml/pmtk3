function logp = gaussLogprobMissingData(arg1, arg2, arg3)
% Same as gaussLogprob, but supports missing data, represented as NaN
% X is N*D
% L = gaussLogprobMissingData(mu, Sigma, X)
% L = gaussLogprobMissingData(model, X)

% Test example
%{
N = 5; D = 3;
X = randn(N,D);
M = rand(N,D)>0.5;
X(M) = NaN;
mu = zeros(D,1); Sigma = eye(D);
model = gaussCreate(mu, Sigma);
logp = gaussLogprobMissingData(model, X);
logp2 = gaussLogprobMissingData(mu, Sigma, X);
assert(approxeq(logp, logp2))
%}

% This file is from pmtk3.googlecode.com

switch nargin
  case 3,  mu = arg1; Sigma = arg2; X = arg3;
  case 2, model = arg1; mu = model.mu; Sigma = model.Sigma; X = arg2;
  otherwise
    error('bad num args')
end

missRows = any(isnan(X),2);
nMiss = sum(missRows);
mu = rowvec(mu); 
[n,d] = size(X);
logp = NaN(n,1);
logp(~missRows) = gaussLogprob(mu, Sigma, X(~missRows,:));

XmissCell = mat2cell(X(missRows,:), ones(1,nMiss), d);
% XmissCell{i} is a 1xd vector with some NaNs
logp(missRows) = cellfun(@(y)lognormpdfNaN(mu, Sigma, y), XmissCell);
 
end

function l = lognormpdfNaN(mu, Sigma, x)
% log pdf of a single data vector (row) with NaNs
vis = find(~isnan(x));
if isempty(vis)
  l = 0;
else
  l = gaussLogprob(mu(vis), Sigma(vis,vis), x(vis));
end
end

