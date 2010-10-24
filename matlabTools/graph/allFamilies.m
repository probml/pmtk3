function fam = allFamilies(G)
%% Return a cell array of the families of every node in the dag G. 
% i.e. fam{i} = [parents(G, i), i]

% This file is from pmtk3.googlecode.com

nnodes = size(G, 1); 
fam = cell(nnodes, 1); 
for i=1:nnodes
   fam{i} = [parents(G, i), i];  
end
end
