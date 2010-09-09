function [xopt, fval, samples, energies, acceptanceRate, temp] = simAnneal(target, x0, opts)
% Simulated annealing algorithm to find the global *minimum* of a function
%
% INPUTS (similar to fminunc)
% target is the energy function (*negative* unnormalized log posterior)
%   called as 'E = target(x)'
% x0 is a 1xd vector specifying the initial state
% opts is a structure of optional arguments [defaults listed below in brackets]
%  temp(T,iter)  - a fn that gives the new temperature given current temp T and iter [0.995*T]
%  proposal(x) - a fn that generates a new row vector [Gauss(zeros(1,d), 0.1*eye(d))]
%  initTemp [1]
%  maxIter [1000]
%  minIter [100]
%  convWindow [10] - stop if function does not change during this window
%  convThresh [1e-3] - degree of change required to stop
%  verbose [0] - if 1, print output at each step
%
% OUTPUTS
% xopt = optimal set of parameters
% fval = function value at xopt
% samples(s,:) is the parameter value at step s
% energies(s) is the function value at step s
% acceptanceRate = fraction of  accepted moves

% This file is from pmtk3.googlecode.com


% Not sure where I got this code from...

def = struct(...
    'temp', @(T,iter) (.8*T),...
    'proposal', @(x) (x+gaussSample(struct('mu', length(x), 'Sigma', 0.1*eye(length(x))))), ...
    'initTemp', 1, ...
    'maxIter', 1000, ...
    'minIter', 100, ...
    'convThresh', 1e-3, ...
    'convWindow', 10, ...
    'verbose', 0);

fields = fieldnames(def);
for i=1:length(fields)
    if ~isfield(opts, fields{i})
        opts.(fields{i}) = def.(fields{i});
    end
end
proposal = opts.proposal;

d = length(x0);
samples = zeros(opts.maxIter, d);
energies = zeros(1, opts.maxIter);
x = x0(:)'; % ensure it's a row vector
naccept = 0;
energyOld = feval(target, x);
T = opts.initTemp;
temp(1) = T;
converged = 0;
iter = 1;
while ~converged
    if opts.verbose, fprintf('iter %d, temp %6.4f, energy =%6.4f\n', iter, T, energyOld); end
    xprime = feval(proposal, x);
    energyNew = feval(target, xprime);
    
    % convergence check
    if iter > opts.minIter && iter > 2*opts.convWindow
        vals = energies(iter-opts.convWindow:iter-1);
        if std(vals) < opts.convThresh % hasn't changed much during the window
            converged = 1;
            if opts.verbose, fprintf('converged in %d iter\n', iter); end
            break
        end
    end
    
    alpha = exp((energyOld - energyNew)/T);
    r = min(1, alpha);
    u = rand(1,1);
    if u < r
        x = xprime;
        naccept = naccept + 1;
        energyOld = energyNew;
    end
    samples(iter,:) = x;
    energies(iter) = energyOld;
    iter = iter + 1;
    if iter > opts.maxIter, converged = 1;  end
    T = feval(opts.temp, T, iter);
    temp(iter) = T;
end

niter =  iter - 1;
acceptanceRate = naccept / niter;
samples = samples(1:niter, :);
energies = energies(1:niter);
xopt = x;
fval = energyOld;


end
