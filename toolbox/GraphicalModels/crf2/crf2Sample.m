function samples = crf2Sample(model, Xnode, Xedge, Nsamples)
% Sample from a CRF
% samples = crf2Samples(model, Xn, Xe, Nsamples)
% Input should be a single datacase:
% Xn is NnodeFeatures*Nnodes
% Xe is NedgeFeatures*Nedges
% samples is Nsamples*Nnodes
%

% This file is from pmtk3.googlecode.com

if isempty(model.sampleFun)
  fprintf('method %s does not support sampling\n', model.methodName);
  return;
end

if ndims(Xnode)>2
  error('can only handle 1 case at a time')
end

Xnode = reshape(Xnode, [1 size(Xnode)]);
Xedge = reshape(Xedge, [1 size(Xedge)]);
[Ncases, NnodeFeatures, Nnodes] = size(Xnode); %#ok
infoStruct = UGM_makeCRFInfoStruct(Xnode, Xedge, ...
    model.edgeStruct, model.ising, model.tied);
nodePot = UGM_makeCRFNodePotentials(Xnode, model.w, model.edgeStruct, infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge, model.v, model.edgeStruct, infoStruct);
edgeStruct = model.edgeStruct;
edgeStruct.maxIter  = Nsamples;
samples  = feval(model.sampleFun, nodePot, edgePot, ...
    edgeStruct, model.sampleArgs{:});
end
