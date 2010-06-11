function model = discrimAnalysisFit(X, y, type, lambda, R, V)
%% Fit a Discriminant Analysis model
% Input:
% X is an n x d matrix
% y is an n-vector specifying the class label (in range 1..C)
% type is 'linear' (tied Sigma) or 'quadratic' (class-specific Sigma)
% or 'RDA' (regularized linear).
% If using RDA, you must specify 0 < lambda < 1.
%
% Output:
% model.type
% model.classPrior(c)
% model.Nclasses
% model.lambda
% model.mu(d,c) for feature d, class c
% if type==QDA model.Sigma(:,:,c) 
% if type==LDA, model.SigmaPooled(:,:)
% if type==RDA, model.beta(:,c)

%PMTKauthor Hannes Bretschneider, Kevin Murphy

if nargin < 4, lambda = []; end
if nargin < 5, R = []; end
if nargin < 6, V = []; end

model.lambda = lambda;
model.type = type;
Nclasses = length(unique(y));
model.Nclasses = Nclasses;
[N,D] = size(X);
model.mu = zeros(D, Nclasses);
for k=1:model.Nclasses
  ndx =(y==k);
  model.classPrior(k) = sum(ndx)/N;
  model.mu(:,k) =  mean(X(ndx,:))';
end

switch lower(type)
  case 'rda',
    %model = RDAfit(X, y, lambda);
    if isempty(R)
      [U S V] = svd(X, 'econ');
      R = U*S;
    end
    Rcov = cov(R);
    Sreg = (lambda*Rcov+(1-lambda)*diag(diag(Rcov)));
    Sinv = inv(Sreg);
    model.beta = zeros(D, Nclasses);
    for k=1:Nclasses
      ndx =(y==k);
      model.mu(:,k) =  mean(X(ndx,:))';
      muRed = mean(R(ndx,:))';
      model.beta(:,k) =  V*Sinv*muRed;
    end
  case 'qda'
    model.Sigma = zeros(D, D, Nclasses);
    for c=1:Nclasses
      ndx = (y == c);
      dat = X(ndx, :);
      model.Sigma(:,:,c) = cov(dat, 1);
    end
  case 'lda'
    SigmaPooled = zeros(D,D);
    for c=1:Nclasses
      ndx = (y == c);
      nc = sum(ndx);
      dat = X(ndx, :);
      Sigma = cov(dat, 1);
      SigmaPooled = SigmaPooled + nc*Sigma;
    end
    model.SigmaPooled = SigmaPooled/N;
end

end