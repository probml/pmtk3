function [model, loglikHist, llHists] = emAlgo(model, data, init, estep, mstep, varargin)
% Generic EM algorithm
%
% You must provide the following functions as input
%   model = init(model, data, restartNum) % initialize params
%   [ess, loglik] = estep(model, data) % compute expected suff. stats
%   model = mstep(model, ess) % compute params
%
%
% Outputs:
% model is a struct returned by the mstep function.
% loglikHist is the history of log-likelihood (plus log-prior) vs
% iteration.  The length of this gives the number of iterations.
% llHists{i} is the history for the i'th random restart;
% loglikHist is the history of the best run
%
% Optional arguments [default]
% maxIter: [100]
% convTol: convergence tolerance [1e-3]
% verbose: [false]
% plotFn: function of form plotfn(model, data, ess, ll, iter), default []
% nRandomRestarts: [1]

% This file is from pmtk3.googlecode.com


%% Random Restart
[nRandomRestarts, verbose,  args] = process_options(varargin, ...
    'nrandomRestarts', 1, 'verbose', false);
if nRandomRestarts > 1
    models  = cell(1, nRandomRestarts);
    llhists = cell(1, nRandomRestarts);
    bestLL  = zeros(1, nRandomRestarts);
    for i=1:nRandomRestarts
        if verbose
            fprintf('\n********** Random Restart %d **********\n', i);
        end
        [models{i}, llhists{i}] = emAlgo(model, data, init, estep,...
            mstep, 'verbose', verbose, 'restartNum', i, args{:});
        bestLL(i) = llhists{i}(end);
    end
    bestndx = maxidx(bestLL);
    model = models{bestndx};
    loglikHist = llhists{bestndx};
    return
end
%% Perform EM
[maxIter, convTol, plotfn, restartNum, computeLoglik] = process_options(args ,...
    'maxIter'    , 50   , ...
    'convTol'    , 1e-4  , ...
    'plotfn'     , []    , ...
    'restartNum' , 1, ....
    'computeLoglik', true);

  if verbose, fprintf('initializing model for EM\n'); end
model = init(model, data, restartNum);
iter = 1;
done = false;
loglikHist = zeros(maxIter + 1, 1);
while ~done
  if computeLoglik
    [ess, ll] = estep(model, data);
  else
    [ess] = estep(model, data);
    ll = 0;
  end
    if verbose
        fprintf('%d\t loglik: %g\n', iter, ll );
    end
    if ~isempty(plotfn)
        plotfn(model, data, ess, ll, iter);
    end
    loglikHist(iter) = ll;
    model = mstep(model, ess);
    if iter > maxIter
      done = true;
    elseif iter > 1
      if computeLoglik
        showWarning = true;
        done = convergenceTest(loglikHist(iter), loglikHist(iter-1), convTol, showWarning);
      end
      % could add convergence test based on params not changing
    end
    %done  = (iter > maxIter) || ( (iter > 1) && ...
    %    convergenceTest(loglikHist(iter), loglikHist(iter-1), convTol, true));
    iter = iter + 1;
end
loglikHist = loglikHist(1:iter-1);
llHists{1} = loglikHist;
end
