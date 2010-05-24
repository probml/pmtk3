function p = logregPredictive(X, wMAP, C)
% Compute p(i) = p(y=1|X(i,:)) \approx int sigma(y w^T X(i,:)) * gauss(w | wMAP, C) dw
% Bishop'06 p219

mu = X*wMAP(:);
[N D] = size(X);
%sigma2 = diag(X * C * X');
sigma2 = zeros(1,N);
for i=1:N
  sigma2(i) = X(i,:)*C*X(i,:)';
end
kappa = 1./sqrt(1 + pi.*sigma2./8);
p = sigmoid(kappa .* mu');
