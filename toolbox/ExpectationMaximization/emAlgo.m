function [model, loglikHist] = emAlgo(data, init, estep, mstep, mstepOR, varargin)
% Generic EM algorithm
% loglikHist is the history of log-likelihood (plus log-prior) vs
% iteration.  The length of this gives the number of iterations.
%
% Optional arguments [default]
% maxIter: [100]
% convTol: converhence tolerance [1e-3]
% verbose: [false]
% plotFn: function of form plotfn(model, data, ess, ll, iter), default []
% overRelaxFactor: if > 1, use adaptive  over-relaxed EM [1]
%   In this case, mstepOR must be a valid function handle
%%
[maxIter, convTol, plotfn, verbose, overRelaxFactor] = ...
    process_options(varargin , ...
    'maxIter'        , 100   , ...
    'convTol'        , 1e-4  , ...
    'plotfn'         , []    , ...
    'verbose'        , false , ...
    'overRelaxFactor', []    );

if ~isempty(overRelaxFactor)
    [model, loglikHist] = emAlgoAdaptiveOverRelaxed...
        (data, init, estep, mstep, mstepOR, varargin{:});
    return;
end
model = init(data); 
iter = 1;
done = false;
loglikHist = zeros(maxIter + 1, 1); 
while ~done
    [ess, ll] = estep(model, data);
    if verbose, fprintf('%d\t loglik: %g\n', iter, ll ); end
    if ~isempty(plotfn), plotfn(model, data, ess, ll, iter); end
    loglikHist(iter) = ll; 
    model = mstep(model, ess);
    done = (iter > maxIter) || ( (iter > 1) && ...
        convergenceTest(loglikHist(iter), loglikHist(iter-1), convTol));
    iter = iter + 1;
end
loglikHist = loglikHist(1:iter-1); 
end