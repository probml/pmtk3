function map = crf2Map(model, Xnode, Xedge)
% Compute posterior mode (MAP estimate) for a CRF
% map = crf2Map(model, Xn, Xe)
% Input can be
% Xn is NnodeFeatures*Nnodes
% Xe is NedgeFeatures*Nedges
% or
% Xn is NcNnodeFeatures*Nnodes
% Xe is Ncases*NedgeFeatures*Nedges
%
% map is Ncases*Nnodes
%%

% This file is from pmtk3.googlecode.com

if isempty(model.decodeFun)
  fprintf('method %s does not support MAP estimation\n', model.methodName);
  return;
end

if ndims(Xnode)==2
  Xnode = reshape(Xnode, [1 size(Xnode)]);
  Xedge = reshape(Xedge, [1 size(Xedge)]);
end
[Ncases, NnodeFeatures, Nnodes] = size(Xnode); %#ok
map = zeros(Ncases, Nnodes);
infoStruct = UGM_makeCRFInfoStruct(Xnode, Xedge, ...
    model.edgeStruct, model.ising, model.tied);
nodePot = UGM_makeCRFNodePotentials(Xnode, model.w, model.edgeStruct, infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge, model.v, model.edgeStruct, infoStruct);
for i=1:Ncases
  map(i,:)  = feval(model.decodeFun, nodePot(:,:,i), edgePot(:,:,:,i), ...
    model.edgeStruct, model.decodeArgs{:});
end
end
