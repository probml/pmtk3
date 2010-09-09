function dgm = mkRndTreeDgm(K, depth, nstates, varargin)
%% Create a random K-ary tree structured dgm
% (note the structure itself is deterministic - only the parameters are random). 
% A depth of 1, means only the root
%
% nstates is either a scalar, or of length ((K.^depth)-1)/(K-1) - the order
% is breadth first search, left to right. 
%
% Any additional args are passed directly to dgmCreate
%%

% This file is from pmtk3.googlecode.com


G      = mkTreeDag(K, depth); 
nnodes = size(G, 1); 
CPDs   = cell(nnodes, 1); 
if isscalar(nstates)
    nstates = repmat(nstates, 1, nnodes); 
end
nstates = rowvec(nstates); 
for i=1:nnodes
   dom     = [parents(G, i), i]; 
   sz      = [nstates(dom), 1]; 
   T       = rand(sz);
   T       = mkStochastic(T); 
   CPDs{i} = tabularCpdCreate(T); 
end
dgm = dgmCreate(G, CPDs, varargin{:}); 
end
