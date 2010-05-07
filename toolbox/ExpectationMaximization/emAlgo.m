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
% nRandomRestarts: [1] 
% overRelaxFactor: if > 1, use adaptive  over-relaxed EM [1]
%   In this case, mstepOR must be a valid function handle
%%
%
%% Random Restart 
[nRandomRestarts, verbose, args] = process_options(varargin, ...
    'nrandomRestarts', 1, 'verbose', false); 
if nRandomRestarts > 1
   models  = cell(1, nRandomRestarts);
   llhists = cell(1, nRandomRestarts); 
   bestLL  = zeros(1, nRandomRestarts); 
   for i=1:nRandomRestarts
       if verbose
           fprintf('\n********** Random Restart %d **********\n', i);
       end
       [models{i}, llhists{i}] = emAlgo(data, init, estep,...
           mstep, mstepOR, 'verbose', verbose, args{:});
       bestLL(i) = llhists{i}(end); 
   end
   bestndx = maxidx(bestLL); 
   model = models{bestndx};
   loglikHist = llhists{bestndx};
   return 
end
%%

[maxIter, convTol, plotfn, overRelaxFactor] = ...
    process_options(args     , ...
    'maxIter'        , 100   , ...
    'convTol'        , 1e-4  , ...
    'plotfn'         , []    , ...
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
        convergenceTest(loglikHist(iter), loglikHist(iter-1), convTol, true));
    iter = iter + 1;
end
loglikHist = loglikHist(1:iter-1); 
end