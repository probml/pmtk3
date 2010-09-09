function [model, loglikHist] = emAlgoAdaptiveOverRelaxed(model, data, init, estep, mstep, mstepOR, varargin)
% Adaptive over-related EM algorithm
% Reference: "Adaptive Overrelaxed Bound Optimization Methods",
% Ruslan Salakhutdinov and Sam Roweis, ICML 2003
%
% mstepOR shoud be a funciton of the form
%  [model, valid] = mstepOR(model, modelBO, stepSize);
% where modelBO contains the new parameters after a regular M step

% This file is from pmtk3.googlecode.com


%PMTKauthor Krishna Nand Keshava Murthy, Kevin Murphy


args = varargin;
[maxIter, convTol, plotfn, verbose, overRelaxFactor, restartNum] = process_options(...
    args, 'maxIter', 100, 'convTol', 1e-3, 'plotfn', [], 'verbose', false, ...
    'overRelaxFactor', 2, 'restartNum', 1);

model = init(model, data, restartNum);
iter = 1;
done = false;
eta = 1;
[ess, ll] = estep(model, data);
loglikHist(iter) = ll;
iter = 2;
while ~done
    modelBO = mstep(model, ess);
    [model, valid] = mstepOR(model, modelBO, eta);
    if valid
        [ess, ll] = estep(model, data);
        valid = (ll > loglikHist(iter-1));
    end
    if valid
        % increase step size
        eta = eta * overRelaxFactor;
    else
        % just took a downhill step...
        eta = 1;
        model = modelBO; % regular EM update
        [ess, ll] = estep(model, data);
    end
    loglikHist(iter) = ll;
    if verbose, fprintf('%d\t loglik: %g\n', iter, ll ); end
    if ~isempty(plotfn), plotfn(model, data, ess, ll, iter); end
    done = (iter > maxIter) || ( (iter>1) && convergenceTest(loglikHist(iter), loglikHist(iter-1), convTol));
    iter = iter + 1;
end

end
