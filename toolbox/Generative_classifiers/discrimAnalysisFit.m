function model = discrimAnalysisFit(X, y, type, lambda, R, V)
%% Fit a Discriminant Analysis model
% Input:
% X is an n x d matrix
% y is an n-vector specifying the class label (in range 1..C)
% type is one of the following
%  'linear' (tied Sigma) 
%  'quadratic' (class-specific Sigma)
%  'RDA' (regularized LDA)
%  'diag' (diagonal QDA - naive Bayes assumption)
% 'shrunkenCentroids' (diagonal LDA with L1 shrinkage on offsets)
%
% If using RDA or shrunkenCentroids, you must specify lambda.
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
% if type==diag, model.SigmaDiag(:,c)
% if type==shrunkenCentroids, model.SigmaPooledDiag(c) 
%    and (for plotting purposes) model.shrunkenCentroids(:,c)

%PMTKauthor Hannes Bretschneider, Robert Tseng, Kevin Murphy

if nargin < 4, lambda = []; end
if nargin < 5, R = []; end
if nargin < 6, V = []; end

model.lambda = lambda;
model.type = type;
Nclasses = length(unique(y));
model.Nclasses = Nclasses;
[N,D] = size(X);
model.mu = zeros(D, Nclasses);
xbar = mean(X); % class independent mean
Nclass = zeros(1, Nclasses);
for k=1:model.Nclasses
  ndx =(y==k);
  Nclass(k) = sum(ndx);
  model.classPrior(k) = Nclass(k)/N;
  if Nclass(k)==0
    % if there may be no examples of any given class, use generic mean
    model.mu(:,k) = xbar;
  else
    model.mu(:,k) =  mean(X(ndx,:))';
  end
end

switch lower(type)
  case 'shrunkencentroids'
    model = shrunkenCentroidsFit(model, X, y, lambda);
  case 'rda',
    model = rdaFit(model, X, y, lambda, R, V);
  case 'qda'
    model.Sigma = zeros(D, D, Nclasses);
    for c=1:Nclasses
      ndx = (y == c);
      dat = X(ndx, :);
      model.Sigma(:,:,c) = cov(dat, 1);
    end
  case 'diag'
    model.SigmaDiag = zeros(D, Nclasses);
    for c=1:Nclasses
      ndx = (y == c);
      dat = X(ndx, :);
      model.SigmaDiag(:,c) = var(dat,1)';
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

function model = rdaFit(model, X, y, lambda, R, V)
%PMTKauthor Hannes Bretschneider
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
  muRed = mean(R(ndx,:))';
  model.beta(:,k) =  V*Sinv*muRed;
end
end

function model = shrunkenCentroidsFit(model, Xtrain, ytrain, lambda)
%PMTKauthor Robert Tseng

C = length(unique(ytrain));
[N, D] = size(Xtrain);
Nclass = zeros(1,C);

% compute pooled standard deviation
xbar = mean(Xtrain);
sse= zeros(1,D);
for c=1:C
  ndx = find(ytrain==c); 
  Nclass(c) = length(ndx);
  % if there may be no examples of any given class, use generic mean
  if Nclass(c)==0
    centroid = xbar;
  else
    centroid = mean(Xtrain(ndx,:));
  end
  sse = sse + sum( (Xtrain(ndx,:) - repmat(centroid, [Nclass(c) 1])).^2);
end
sigma = sqrt(sse ./ (N-C));
s0 = median(sigma);

mu = model.mu;
m = zeros(1,C);
offset = zeros(C,D);
for c=1:C
  if Nclass(c)==0
    m(c) = 0;
  else
    % Hastie below eqn 18.4
    m(c) = sqrt(1/(Nclass(c) - 1/N));
  end
  % Hastie eqn 18.4
 offset(c,:) = (mu(:,c)' - xbar) ./ (m(c) * (sigma+s0));
 % Hastie eqn 18.5
 offset(c,:) = softThreshold(offset(c,:), lambda);
  % Hastie eqn 18.7
  mu(:,c) = (xbar + m(c)* (sigma+s0) .* offset(c,:))';
end


model.mu = mu;
model.SigmaPooledDiag = sigma(:).^2;

% for visualization purposes, we keep this:
model.shrunkenCentroids = offset; % m_cj
end