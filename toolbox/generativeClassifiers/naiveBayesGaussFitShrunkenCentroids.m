function model = naiveBayesGaussFitShrunkenCentroids(Xtrain, ytrain, lambda, useXbar)
% Fit a naive Bayes classifier with Gaussian features using L1 MAP estimation
% Xtrain(i,j) =  feature j in case i
% ytrain in {1,...C}
% Model is a structure with these fields:
% mu(c,j), sigma(c,j), classPrior(c), offset(c,j), xbar

if nargin < 4,  useXbar = true; end
  
C = length(unique(ytrain));
[N, D] = size(Xtrain);
mu = zeros(C, D);
sigma = zeros(C, D);
offset = zeros(C,D);

xbar = mean(Xtrain);
classIndepStd = std(Xtrain);
s0 = median(classIndepStd);
Nclass = zeros(1,C);
relevant = false(1,D);
for c=1:C
  ndx = (ytrain==c);
  Nclass(c) = length(ndx);
  Lc = 1/sqrt(Nclass(c));
  for j=1:D
    xbar_cj = mean(Xtrain(ndx,j));
    sj = classIndepStd(j);
    dcj = (xbar_cj - xbar(j))/(Lc*(sj+s0));
    offset(c,j) = Lc*(sj+s0)*softThreshold(dcj, lambda);
    mj = xbar(j);
    mu(c,j) = mj + offset(c,j);
    sigma(c,j) = sj;
    relevant(j)  = relevant(j) | offset(c,j)~=0;
  end
end

if ~useXbar
for c=1:C
  for j=1:D
    mj = (xbar(j) - sum(Nclass*offset(c,j)))/N;
    mu(c,j) = mj + offset(c,j);
  end
end
end

model.classPrior = normalize(Nclass);
model.mu = mu;
model.sigma = sigma;
model.offset = offset; % m_cj
model.xbar = xbar; % mu(c,j) = xbar(j) + offset(c,j)
model.relevant = relevant;
end
