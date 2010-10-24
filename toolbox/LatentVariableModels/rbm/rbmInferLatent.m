function ph = rbmInferLatent(model, X, y)
% pz(i,j) = p(hj=1|X(i,:))
% If supervised, then  pz(i,j) = p(hj=1|X(i,:), y(i))
% where y(i) in 1..C

% This file is from pmtk3.googlecode.com


N = size(X,1);
if nargin < 3
  ph = sigmoid(X*model.W + repmat(model.b,N,1));
else
  u = unique(y);
  nclasses = numel(u);
  targets = dummyEncoding(y, nclasses);
  ph = sigmoid(X*model.W + targets*model.Wc + repmat(model.b,N,1));
end


end
