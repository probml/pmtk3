function cpd = tabularCpdCreate(T, varargin)
%% Conditional probability density function p(y|x) for use in a DGM
% T(a,b,...z) is distribution of z given parent values a, b,...

% This file is from pmtk3.googlecode.com

prior = process_options(varargin , 'prior', 'none');
if isvector(T)
    T = T(:);
end
sizes = sizePMTK(T);
nstates = sizes(end);
if ischar(prior)
    switch lower(prior)
        case 'bdeu'
            q = prod(sizes(1:end-1));
            prior = 1 + onesPMTK(sizes)*1/(q*nstates);
        case 'laplace'
            prior = 2*onesPMTK(sizes);
        case 'none'
            prior = onesPMTK(sizes);
    end
end
cpd = structure(T, prior, sizes, nstates);
cpd.d = 1; 
cpd.cpdType = 'tabular';
update = @(cpd, x)tabularCpdCreate(mkStochastic(x + cpd.prior-1), 'prior', cpd.prior); 
%% 'methods'
cpd.fitFn      = @(cpd, data)   update(cpd, computeCounts(data, cpd.sizes)); 
cpd.fitFnEss   = @(cpd, ess)    update(cpd, reshape(ess.counts, size(cpd.T))); 
cpd.rndInitFn  = @(cpd)         update(cpd, rand(size(cpd.T)));
cpd.logPriorFn = @(cpd)         log(cpd.T(:) + eps)'*(cpd.prior(:)-1);
cpd.essFn      = @tabularEssFn;  
end

function ess = tabularEssFn(cpd, data, weights, B)
%% Compute the excpected suff stats for a tabular CPD
% (note, this is only used if a tabularCPD is used as a localCPD) B is
% ignored, but required by the interface, (for e.g. condMixGaussTiedCpd)
% A better choice for a localCPD given discrete observations is
% condDiscreteProdCpd, which supports scalar and vector valued discrete
% observations - see condDiscreteProdCpdCreate
%%
nstates = cpd.nstates; 
nstatesParent = size(weights, 2); 
counts = zeros(nstatesParent, nstates); 
for c=1:nstates
    for p=1:nstatesParent
        counts(p, c) = sum(bsxfun(@times, (data(:)==c), weights(:, p)));
    end
end
ess.counts = counts(:); 
end
