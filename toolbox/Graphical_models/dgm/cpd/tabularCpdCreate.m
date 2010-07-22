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
            prior = onesPMTK(sizes)*1/(q*nstates);
        case 'laplace'
            prior = 1*onesPMTK(sizes);
        case 'none'
            prior = 0*onesPMTK(sizes);
    end
end
cpd = structure(T, prior, sizes, nstates);
cpd.cpdType = 'tabular';
%% 
cpd.fitFn      = @(cpd, data)tabularCpdCreate(...
    mkStochastic(computeCounts(data, cpd.sizes) + cpd.prior), 'prior', cpd.prior);

cpd.fitFnEss   = @(cpd, counts)tabularCpdCreate(mkStochastic(...
    reshape(counts, size(cpd.T)) + cpd.prior), 'prior', cpd.prior);   

cpd.logPriorFn = @(cpd)log(cpd.T(:) + eps)'*(cpd.prior(:)-1);
end