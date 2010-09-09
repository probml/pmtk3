function [w, loglikHist] = probitRegFitEm(X, y, lambdaVec, EMargs)
%% Find MAP estimate (under L2 prior) for binary probit regression using EM
% y(i) is +1,-1

% This file is from pmtk3.googlecode.com


% PMTKauthor  Francois Caron
% PMTKmodified Kevin Murphy, Matt Dunham

if nargin < 4, EMargs = {}; end

model.w = [];
lambdaScalar = lambdaVec(end); % we assume it has the form [0, lam, lam...]
objfn   = @(w)-ProbitLoss(w, X, y) + sum(lambdaVec.*(w.^2));
estepFn = @(model, data)estep(model, data, objfn); 
mstepFn = @(model, ess)linregFit(X, ess.Z , ...
    'lambda'  , lambdaScalar, ...      
    'preproc' , struct('standardizeX', false, 'addOnes', false) );
[model, loglikHist] = emAlgo(model, [X, y], @init, estepFn, mstepFn, EMargs{:});  
w = model.w;
end

function model = init(model, data, restartNum) %#ok
%% Initialize
X       = data(:, 1:end-1);
y       = data(:, end);
model.w = (X + rand(size(X))) \ y; 
end

function [ess, loglik] = estep(model, data, objfn)
%% Compute the expected sufficient statisticsa
X      = data(:, 1:end-1);
y      = data(:, end);
u      = X*model.w;
ess.Z  = u + gaussProb(u, 0, 1)./((y==1) - gausscdf(-u));
loglik = objfn(model.w);
end
