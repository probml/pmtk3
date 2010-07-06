function cpd = tabularCpdCreate(T, varargin)
%% Conditional probability density function p(y|x) for use in a DGM
% T(a,b,...z) is distribution of z given parent values a,b,...
% (handles local evidence)

[clamped, B, prior] = process_options(varargin , ...
    'clamped' , 0                              , ...
    'localev' , []                             , ...
    'prior'   , 'none'                         );

sizes = sizePMTK(T);
nstates = sizes(end);
switch lower(prior)
    case 'bdeu'
        q = prod(sizes(1:end-1));
        prior = onesPMTK(sizes)*1/(q*nstates);
    case 'laplace'
        prior = 1*onesPMTK(sizes);
    case 'none'
        prior = 0*onesPMTK(sizes);
end
cpd = structure(T, clamped, B, prior, sizes, nstates);
cpd.cpdType = 'tabular';
end