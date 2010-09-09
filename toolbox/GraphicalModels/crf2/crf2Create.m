function model = crf2Create(adj, nStates, varargin)
% Make a Conditional random field with pairwise potentials
% This is identical to mrf2Create
% except that we cannot create node and edge potentials
% until we have seen some data
% However, we let the user manually specify
% the edge weights w and the node weights v,
% or specify dummy Xnode and Xedge values to create random parameters

% This file is from pmtk3.googlecode.com

[w, v, Xnode, Xedge, other] = process_options(varargin, ...
  'w', [], 'v', [], 'Xnode', [], 'Xedge', []);

model = mrf2Create(adj, nStates, other{:});
model.nodePot = [];
model.edgePot = [];

if ~isempty(Xnode)
  % Make random params
  edgeStruct = model.edgeStruct;
  infoStruct = UGM_makeCRFInfoStruct(Xnode, Xedge, edgeStruct,...
    model.ising, model.tied);
  [w,v] = UGM_initWeights(infoStruct, @randn);
end

if ~isempty(w)
  model.w = w; 
  model.v = v;
end


end
