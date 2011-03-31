function CPD = condDiscreteProdCpdCreate(T, varargin)
%% Create a conditional discrete product distribution
% This differs from a tabularCPD in that it supports vector valued discrete
% observations, (it also supports scalar value observations). 
% These are assumed to be conditionally independent.
%
% T is of size nstates-by-nObsStates-nChildren
% so T(k,j,i) = p(i'th child = j | parent = k)
%
%% Optional inputs
% 'prior' - a struct with the the field 'alpha', which must be
% either a scalar or a matrix the same size as T. 
%%

% This file is from pmtk3.googlecode.com

prior = process_options(varargin, 'prior', []);
if isempty(prior)
   prior.alpha = 1.1; % add 0.1 as pseudo counts (implicitly replicated) 
end
[nstates, nObsStates, d] = size(T); 
CPD            = structure(T, nstates, nObsStates, d, prior);
CPD.cpdType    = 'condDiscreteProd';
CPD.fitFn      = @condDiscreteProdCpdFit;
CPD.fitFnEss   = @condDiscreteProdCpdFitEss;
CPD.essFn      = @condDiscreteProdCpdComputeEss;
CPD.logPriorFn = @(m)sum(log(m.T(:) + eps).*(m.prior.alpha-1));
CPD.rndInitFn  = @rndInit;
end

function CPD = rndInit(CPD)
%% Randomly initialize
CPD.T = normalize(rand(size(CPT.T), 2)); 
end

function CPD = condDiscreteProdCpdFit(CPD, Z, Y)
%% Fit  given fully observed data
% (MAP estimate with Dirichlet prior)
% Z(i) is the state of the parent Z in case i.
% Y(i, :) is the ith 1-by-d observation of the children
%%
nstates = CPD.nstates;
nObsStates = CPD.nObsStates; 
T = CPD.T;
if isempty(CPD.prior)
    alpha = 1;
else
    alpha = CPD.prior.alpha;
end
for k = 1:nstates
   T(k, :, :) = normalize(histc(Y(Z==k, :) + alpha - 1, 1:nObsStates), 2); 
end
end

function ess = condDiscreteProdCpdComputeEss(cpd, data, weights, B)
%% Compute the expected sufficient statistics for a condDiscreteProd CPD
% data     -  nobs-by-d
% weights  -  nobs-by-nstates; the marginal probability of the parent    
% B        -  ignored, but required by the interface, 
%             (since mixture emissions, e.g. condMixGaussTied, use it). 
%%
[nstates, nObsStates, d] = size(cpd.T);
counts  = zeros(nstates, nObsStates, d);% counts(k, c, d) = p(x_d = c | Z = k)
if d < nObsStates*nstates
    for j = 1:d
        counts(:, :, j) = weights'*bsxfun(@eq, data(:, j), 1:nObsStates);
    end
else
    for c = 1:nObsStates
        for k = 1:nstates
            counts(k, c, :) = sum(bsxfun(@times, (data==c), weights(:, k)));
        end
    end
end
ess.counts = counts;
ess.wsum   = sum(weights, 1);
end

function cpd = condDiscreteProdCpdFitEss(cpd, ess)
%% Fit a condDiscreteProdCpd given the expected sufficient statistics
prior = cpd.prior;
if isempty(prior)
    alpha = 1;
else
    alpha = prior.alpha;
end
cpd.T = normalize(ess.counts + alpha-1, 2); 
end
