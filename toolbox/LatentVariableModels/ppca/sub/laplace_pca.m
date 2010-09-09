function [k,p] = laplace_pca(data, e, d, n)
% Estimate latent dimensionality by Laplace approximation.
%
% k = LAPLACE_PCA([],e,d,n) returns an estimate of the latent dimensionality
% of a dataset with eigenvalues e, original dimensionality d, and size n.
% LAPLACE_PCA(data) computes (e,d,n) from the matrix data 
% (data points are rows)
% [k,p] = LAPLACE_PCA(...) also returns the log-probability of each 
% dimensionality, starting at 1.  k is the argmax of p.

% This file is from pmtk3.googlecode.com


%PMTKauthor Tom Minka
%PMTKurl http://research.microsoft.com/en-us/um/people/minka/papers/pca/

if ~isempty(data)
  [n,d] = size(data);
  m = mean(data);
  data0 = data - repmat(m, n, 1);
  e = svd(data0,0).^2;
end
e = e(:);
% break off the eigenvalues which are identically zero
i = find(e < eps);
e(i) = [];

% logediff(i) = sum_{j>i} log(e(i) - e(j))
logediff = zeros(1,length(e));
for i = 1:(length(e)-1)
  j = (i+1):length(e);
  logediff(i) = sum(log(e(i) - e(j))) + (d-length(e))*log(e(i));
end
cumsum_logediff = cumsum(logediff);

inve = 1./e;
% invediff(i,j) = log(inve(i) - inve(j))  (if i > j)
%               = 0                       (if i <= j)
invediff = repmat(inve,1,length(e)) - repmat(inve',length(e),1);
invediff(invediff <= 0) = 1;
invediff = log(invediff);
% cumsum_invediff(i,j) = sum_{t=(j+1):i} log(inve(t) - inve(j))
cumsum_invediff = cumsum(invediff,1);
% row_invediff(i) = sum_{j=1:(i-1)} sum_{t=(j+1):i} log(inve(t) - inve(j))
row_invediff = row_sum(cumsum_invediff);
% row_invediff(k) = sum_{i=1:(k-1)} sum_{j=(i+1):k} log(inve(j) - inve(i))

loge = log(e);
cumsum_loge = cumsum(loge);

cumsum_e = cumsum(e);

dn = length(e);
kmax = length(e)-1;
%dn = d;
%kmax = min([kmax 15]);
ks = 1:kmax;
% the normalizing constant for the prior (from James)
% sum(z(1:k)) is -log(p(U))
z = log(2) + (d-ks+1)/2*log(pi) - gammaln((d-ks+1)/2);
cumsum_z = cumsum(z);
for i = 1:length(ks)
  k = ks(i);
  %e1 = e(1:k);
  %e2 = e((k+1):length(e));
  %v = sum(e2)/(d-k);
  v = (cumsum_e(end) - cumsum_e(k))/(d-k);
  p(i) = -cumsum_loge(k) - (d-k)*log(v);
  p(i) = p(i)*n/2 - cumsum_z(k) - k/2*log(n);
  % compute h = logdet(A_Z)
  h = row_invediff(k) + cumsum_logediff(k);
  % lambda_hat(i)=1/v for i>k
  h = h + (d-k)*sum(log(1/v - inve(1:k)));
  m = d*k-k*(k+1)/2;
  h = h + m*log(n);
  p(i) = p(i) + (m+k)/2*log(2*pi) - h/2;
end
[pmax,i] = max(p);
k = ks(i);
  
%p(3)
%figure(1)
%plot(p)
end
