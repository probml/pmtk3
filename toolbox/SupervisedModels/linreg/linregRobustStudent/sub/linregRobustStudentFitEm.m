function [model, loglikHist] = linregRobustStudentFitEm(X, y, dof, varargin)
%% Fit linear regression with Student noise model by EM
%
%PMTKauthor Hannes Bretschneider
%PMTKmodified Kevin Murphy, Matt Dunham
%%

% This file is from pmtk3.googlecode.com

SetDefaultValue(3, 'dof', []);
if dof==0
    dof = []; 
end
model.dof = dof;
[y, ybar] = centerCols(y);
dofEstimator = @(model, dof)negloglikFn(model, dof, X, y);
mstepFn = @(model, ess)mstep(model, ess, dofEstimator);
[model, loglikHist] = emAlgo(model, [X, y], @init, @estep, mstepFn, varargin{:});
model.w0  = ybar - mean(X)*model.w;
end

function model = init(model, data, restartNum) %#ok
%% Initialize
X = data(:, 1:end-1);
y = data(:, end);
model.w = X\y;
model.estimateDof = isempty(model.dof);
if model.estimateDof
    model.dof = 10; % initial guess
end
model.sigma2 = mean((y - X*model.w).^2);
end

function [ess, loglik] = estep(model, data)
%% Compute the expected sufficient statistics
X      = data(:, 1:end-1);
y      = data(:, end);
model.likelihood = 'student';
loglik = sum(linregLogprob(model, X, y));
sigma2 = model.sigma2; 
w      = model.w;
dof    = model.dof;
delta  = (1/sigma2)*(y - X*w).^2;
s      = (dof+1)./(dof+delta);
S      = diag(sqrt(s));
sigma2 = mean(s.*(y - X*w).^2);
x_weighted = S*X;
y_weighted = S*y;
ess        = structure(x_weighted, y_weighted, sigma2);
end

function model = mstep(model, ess, dofEstimator)
%% Maximize
model.w      = ess.x_weighted\ess.y_weighted;
model.sigma2 = ess.sigma2; 
dofMax = 100;
dofMin = 0.1;
if model.estimateDof
    % optimize neg log likelihood of observed data (ECME) using gradient
    % free optimizer.
    nllfn = @(v)dofEstimator(model, v);
    model.dof = fminbnd(nllfn, dofMin, dofMax);
end
end

function nll = negloglikFn(model, dof, X, y)
model.dof = dof;
model.likelihood = 'student'; 
nll = -sum(linregLogprob(model, X, y));
end
