function bels = dgmInferFamily(dgm, varargin)
%% bels{i} = p(Xi, X(parents(i)) | localev)
%
% Optional args are the same as for dgmInferQuery
%%
bels = dgmInferQuery(dgm, allFamilies(dgm.G), varargin{:}); 
end