% posterior over model dimensionality 
% See also ppcaVBdemo

setSeed(0);

n = 300;
d = 10;

%sigma = [5,4,3,2,1*ones(1,6)]; % ICANN'99 
sigma = [1,1,1,0.5*ones(1,7)]; % book p584
Sigma = diag(sigma);
mu = zeros(1,d);
k = 4;
W = zeros(d,d);
for i=1:k
   modeli = struct('mu', mu, 'Sigma', Sigma(i)*eye(d));
   W(:,i) = gaussSample(modeli);
end
Z = randn(d,n);
X = W*Z + randn(d,n);
X = X';

[k,p] = laplace_pca(X);
post = exp(normalizeLogspace(p));
figure; bar(post)
printPmtkFigure('ppcaEvidenceDemo')



