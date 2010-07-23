function cpd = tabularCpdCreate(T, varargin)
%% Conditional probability density function p(y|x) for use in a DGM
% T(a,b,...z) is distribution of z given parent values a, b,...
prior = process_options(varargin , 'prior', 'none');
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
cpd.fitFnEss   = @(cpd, counts) update(cpd, reshape(counts, size(cpd.T))); 
cpd.rndInitFn  = @(cpd)         update(cpd, rand(size(cpd.T)));
cpd.logPriorFn = @(cpd)         log(cpd.T(:) + eps)'*(cpd.prior(:)-1);

end

