
function model = rdaFit(model, X, y, lambda, R, V)
% author Hannes Bretschneider
if isempty(R)
    [U S V] = svd(X, 'econ');
    R = U*S;
end
Nclasses = nunique(y);
D = size(X, 2); 
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
