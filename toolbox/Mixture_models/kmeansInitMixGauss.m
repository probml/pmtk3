function [mu, Sigma, mixweight, counts] = kmeansInitMixGauss(data, K)
% Initialize params of GMM with Kmeans
D = size(data,2);
[mu, assign] = kmeansFit(data, K);
Sigma = zeros(D,D,K);
counts = zeros(1,K);
for c=1:K
  ndx = find(assign==c);
  counts(c) = length(ndx);
  C = shrinkcov(data(ndx,:)); % cov(data(ndx,:));
  Sigma(:,:,c) = C;
end
mixweight = normalize(counts);
for c=1:K
   if any(isnan(Sigma(:, :, c)))
       Sigma(:, :, c) = randpd(D);
   end
end

end