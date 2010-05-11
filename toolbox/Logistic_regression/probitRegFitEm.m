function [model, loglikHist] = probitRegFitEm(X, y, lambda, varargin)
%% Find MAP estimate (under L2 prior) for binary probit regression using EM
%
%% Inputs
% X(i, :) is i'th case
% y(i) is in {-1, +1}
% lambda is the value of the L2 regularizer
% 
%% Optional named inputs
%
% 'winit'   - an initial value for the weights - randomly initialized if not
%             specified. 
%
% 'preproc' - a preprocessor struct
%
% * See emAlgo for additional EM related optional args *
%% Outputs
%
% model is a struct with fields, w, lambda
% loglikHist is the history of the log likelihood
%
%%
% Based on code by Francois Caron, modified by Kevin Murphy & Matt Dunham
%%
SetDefaultValue(3, 'lambda', 0); 
[model.w, model.preproc, EMargs] =  process_options(varargin , ...
    'winit'   , []                                           , ...
    'preproc' , struct('standardizeX', true)); 
     % important to standardize to avoid numerical error
[model.preproc, X] = preprocessorApplyToTrain(model.preproc, X); 
%%
objfn   = @(w)-ProbitLoss(w, X, y) + lambda*sum(w.^2);
estepFn = @(model, data)estep(model, data, objfn); 
mstepFn = @(model, ess)linregFit(X, ess.Z     , ...
    'lambda'  , lambda                        , ...
    'preproc' , struct('standardizeX', false) );
[m, loglikHist] = emAlgo(model, [X, y], @init, estepFn, mstepFn, EMargs{:}); 
model.w = m.w;
model.lambda = lambda; 
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
ess.Z  = u + gausspdf(u, 0, 1)./((y==1) - probit(-u));
loglik = objfn(model.w);
end