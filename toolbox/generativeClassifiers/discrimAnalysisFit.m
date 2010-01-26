function params = discrimAnalysisFit(X, y, type)
% Input:
% X is an n x d matrix
% y is an n-vector specifying the class label (in range 1..C)
% type is 'linear' (tied Sigma) or 'quadratic' (class-specific Sigma)
%
% Output:
% params.type
% params.classPrior(c)
% params.mu(d,c) for feature d, class c
% params.Sigma(:,:,c) covariance for class c if quadratic
% params.SigmaPooled(:,:) if linear

[n d] = size(X);
Nclasses = length(unique(y));
for c=1:Nclasses
  ndx = find(y == c);
  dat = X(ndx, :);
  params.mu(:,c) = mean(dat);
  params.Sigma(:,:,c) = covmat(dat);
  params.classPrior(c) = length(ndx)/n;
end
params.SigmaPooled = cov(X);
params.type = type;
