function model = crf2Create(adj, nStates, varargin)
% Make a Conditional random field with pairwise potentials
% This is identical to mrf2Create
% except that we cannot create node and edge potentials
% until we have seen some data
% (We could manually specify their loglinear parameters, but we do not
% currently support this option)

model = mrf2Create(adj, nStates, varargin{:});
model.nodePot = [];
model.edgePot = [];

end
