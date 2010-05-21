function  [nodeLabels] = UGM_Decode_MaxOfMarginals(nodePot, edgePot, edgeStruct, inferFunc,varargin)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)

nodeBel = inferFunc(nodePot,edgePot,edgeStruct,varargin{:});
[junk nodeLabels] = max(nodeBel,[],2);
