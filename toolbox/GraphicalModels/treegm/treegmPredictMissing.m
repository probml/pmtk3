function [pX] = treegmPredictMissing(model, X)
% X(n,d) may be Nan
% pX(n,d,v) is predictive distribution for node d in case n

[N,D] = size(X);
[~, X3d] = dummyEncoding(X, model.Nstates*ones(1,model.Nnodes));
% X3d(n,d,v)
for n=1:N
  softev = squeeze(X3d(n,:,:))'; % softev(v,d)
  miss = isnan(X(n,:));
  
  % replace hard evidence with softer form
  %softev(:, miss) = nan;
  %softev(softev==0) = eps;
  %softev(softev==1) = 1-eps;
  
  % If d is not observed, we convert its local evidence to all 1s
  softev(:, miss) = 1;
  localFeatures = [];
  [~, nodeBel] = treegmInferNodes(model, localFeatures, softev);
  pX(n,:,:) = nodeBel';
end

end

