function fg = cliqueGraphCreate(Tfac, nstates, G)
%% Construct a clique graph
%
% Tfac is a cell array of tabular factors
% nstates(j) is the number of states for node j
% G is the graph structure, (automatically inferred if not specified)
% 
%%
if nargin < 3
    G  = constructGraphFromFactors(Tfac);
end
fg = structure(Tfac, nstates, G); 
end