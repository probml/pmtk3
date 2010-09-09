function samples = mrf2Sample(model, N, clamped)
% Sample N row vectors from from markov random field
% clamped is an optional 1*D vector, where
% clamped(i) = 0 means node i is not observed
% and clamped(i) = k means node is clamped to state k

% This file is from pmtk3.googlecode.com

if nargin < 3, clamped = []; end

if isempty(model.sampleFun)
  fprintf('method %s does not support sampling\n', model.methodName);
  return;
end

% override num samples specified when mrf was created
edgeStruct = model.edgeStruct;
edgeStruct.maxIter = N;

if isempty(clamped)
  samples = feval(model.sampleFun, model.nodePot, model.edgePot, ...
    edgeStruct, model.sampleArgs{:});
else
  samples = UGM_Sample_Conditional(model.nodePot, model.edgePot, ...
    edgeStruct, clamped, model.sampleFun, model.sampleArgs{:});
end
samples = samples';
end
