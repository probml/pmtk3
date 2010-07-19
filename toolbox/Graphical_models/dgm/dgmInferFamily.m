function bels = dgmInferFamily(dgm, varargin)
%% bels{i} = p(Xi, X(parents(i)) | localev)
%
% Optional args are the same as for dgmInferQuery
%%
nnodes = dgm.nnodes; 
G = dgm.G; 
queries = cell(nnodes, 1); 
for i=1:nnodes
    queries{i} = [parents(G, i), i]; 
end
bels = dgmInferQuery(dgm, queries, varargin{:}); 
end