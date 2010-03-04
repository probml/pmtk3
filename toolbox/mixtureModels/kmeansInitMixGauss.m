function [mu, Sigma, mixweight] = kmeansInitMixGauss(data, K)
% initialize params of GMM with Kmeans
D = size(data,2);
[mu, assign] = kmeansFit(data, K);
Sigma = zeros(D,D,K);
counts = zeros(1,K);
for c=1:K
  ndx = find(assign==c);
  counts(c) = length(ndx);
  Sigma(:,:,c) = cov(data(ndx,:));
end
mixweight = normalize(counts);

end