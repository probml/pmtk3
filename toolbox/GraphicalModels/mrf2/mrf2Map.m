function map = mrf2Map(model, clamped)
% Compute posterior mode (MAP estimate)
% clamped is an optional 1*D vector, where
% clamped(i) = 0 means node i is not observed
% and clamped(i) = k means node is clamped to state k

% This file is from pmtk3.googlecode.com

if nargin < 2, clamped = []; end
if isempty(clamped)
  map  = feval(model.decodeFun, model.nodePot, model.edgePot, ...
    model.edgeStruct, model.decodeArgs{:});
else
  map = UGM_Decode_Conditional(model.nodePot, model.edgePot, ...
    model.edgeStruct, clamped, model.decodeFun, model.decodeArgs{:});
end
map = map(:)';
end
