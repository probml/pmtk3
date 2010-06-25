function logp = paretoLogprob(model, X)
% logp(i) = log p(X(i) | model.m, model.K); 

m = model.m;
K = model.K; 

% p = K*m^K ./ (X.^(K+1));
% p(X < m) = 0;
X = colvec(X); 
logp = log(K + eps) + K.*log(m +eps) - (K+1).*log(X + eps);
logp(X < m) = log(eps); 



end