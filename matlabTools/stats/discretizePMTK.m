function [XQ, params] = discretizePMTK(X, K, params)
% Quantize scalar continuous variables
% This is similat to quantizePMTK, except we always
% use uniform quantization. Also, we store the values
% used at 'training' time, and use the same values at 'test' time
% So a typical usage is
%
% [XQtrain, params] = discretizePMTK(Xtrain, 5)
% [XQtest] = discretizePMTK(Xtest, [], params)
%
% where Xtrain(i,j) is a real scalar and
% XQtrain(i,j) is in {1,..,K}
%



% This file is from pmtk3.googlecode.com

if nargin < 3, params = []; end

[N D] = size(X);
XQ = zeros(N,D);
if isempty(params)
  for j=1:D
    params.min(j) = min(X(:,j));
    params.max(j) = max(X(:,j));
    range = (params.max(j) - params.min(j)) / (K);
    params.bins{j} = params.min(j) + range*[1:(K-1)];
    assert(numel(params.bins{j})==K-1)
  end
  params.K = K;
else
  K  = params.K;
end
for j=1:D
  %{
  m0 = params.min(j);
  q = (params.max(j) - m0) / (K-1);
  tmp = ceil((X(:,j) - m0) / q);
  XQ(:, j) = tmp + 1; % 1...K
  %}
  bins = params.bins{j};
  for b=1:numel(bins)
    if b==1
      ndx = X(:,j) <= bins(b);
    else
      ndx = (X(:,j) > bins(b-1)) & (X(:,j) <= bins(b));
    end
    XQ(ndx,j) = b;
  end
  ndx = X(:,j)  > bins(end);
  XQ(ndx, j) = K;
end


end
