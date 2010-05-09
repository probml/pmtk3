function [model, loglikHist] = probitRegFitEm(X, y, lambda, varargin)
% Find MAP estimate (under L2 prior) for binary probit regression using EM
% X(i, :) is i'th case
% y(i) is in {-1, +1}
% See emAlgo for additional EM related optional args.
%%
% Based on code by Francois Caron, modified by Kevin Murphy
%%
[model.w, EMargs] = process_options(varargin, 'winit', []);
linreg = @(X, y)linregFit(X, y, ...
    'lambda'  , lambda        , ...
    'regType' , 'L2'          , ...
    'preproc' , struct('standardizeX', false));
%%
objfn   = @(w)-ProbitLoss(w, X, y) + lambda*sum(w.^2);
initFn  = @(X)init(model, X, linreg);
estepFn = @(model, data)estep(model, data, objfn); 
mstepFn = @(model, ess)mstep(model, ess, linreg); 
[model, loglikHist] = emAlgo([X, y], initFn, estepFn, mstepFn, [], EMargs{:}); 
end

function model = init(model, data, linreg)
%% Initialize
X       = data(:, 1:end-1);
y       = data(:, end);
model   = linreg(X + rand(size(X)), y + rand(size(y)));
end

function [ess, loglik] = estep(model, data, objfn)
%% Compute the expected sufficient statisticsa
X      = data(:, 1:end-1);
y      = data(:, end);
y01    = (y+1)/2;
Xw     = X*model.w;
p      = gausspdf(Xw, 0, 1);
c      = gausscdf(-Xw, 0, 1);
ess.Z  = Xw + sign(y).*p./(y01-sign(y).*c);
ess.X  = X; 
loglik = objfn(model.w);
end

function model = mstep(model, ess, linreg)
%% Maximize
    model = linreg(ess.X, ess.Z); 
end