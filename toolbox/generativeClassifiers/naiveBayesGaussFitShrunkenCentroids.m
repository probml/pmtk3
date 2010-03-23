function model = naiveBayesGaussFitShrunkenCentroids(Xtrain, ytrain, lambda)
% Fit a naive Bayes classifier with Gaussian features using L1 MAP estimation
% Xtrain(i,j) =  feature j in case i
% ytrain in {1,...C}
% Model is a structure with these fields:
% mu(c,j), sigma(c,j), classPrior(c), offset(c,j), xbar
%PMTKauthor Robert Tseng

  
C = length(unique(ytrain)); % see nunique()
[N, D] = size(Xtrain);
xbar = mean(Xtrain);
Nclass = zeros(1,C);
sse = zeros(1,D);
centroid = zeros(C,D); % see partitionedMean for a vectorized solution
for c=1:C
  ndx = find(ytrain==c);
  Nclass(c) = length(ndx);
  centroid(c,:) = mean(Xtrain(ndx,:));
  % pooled standard deviation
  sse = sse + sum( (Xtrain(ndx,:) - repmat(centroid(c,:), [length(ndx) 1])).^2);
end
sigma = sqrt(sse ./ (N-C));
s0 = median(sigma);

L = zeros(1,C);
offset = zeros(C,D);
relevant = false(1,D);
for c=1:C
 L(c) = sqrt(1/Nclass(c) - 1/N);
 offset(c,:) = (centroid(c,:) - xbar) ./ (L(c) * (sigma+s0));
 offset(c,:) = softThreshold(offset(c,:), lambda);
 relevant = relevant | offset(c,:) ~= 0;
end

mu = zeros(C, D);
for c=1:C
  mu(c,:) = xbar + L(c)* (sigma+s0) .* offset(c,:);
end

model.classPrior = normalize(Nclass);
model.mu = mu;
model.sigma = repmat(sigma, C, 1);
model.offset = offset; % m_cj
model.xbar = xbar; % mu(c,j) = xbar(j) + offset(c,j)
model.relevant = relevant;
end
