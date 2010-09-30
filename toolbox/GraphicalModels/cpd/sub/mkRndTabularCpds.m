function CPDs = mkRndTabularCpds(G, nstates, varargin)
%% Create a cell array of tabular CPDs with random parameters
%
% G is a dag: an adjacency matrix
% nstates(j) is the number of discrete states that node j can take on
%
% See also mkRndDag and mkRndDgm
%%

% This file is from pmtk3.googlecode.com

nnodes = size(G, 1);
assert(nnodes == numel(nstates));
nstates = rowvec(nstates);
CPDs = cell(nnodes, 1);
for i=1:nnodes
    dom = [parents(G, i), i];
    sz = [nstates(dom), 1];
    T = rand(sz);
    CPDs{i} = tabularCpdCreate(mkStochastic(T), varargin{:});
end

end
