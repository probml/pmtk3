function [L, LL] = mixDiscreteLogprob(model, X)

T = model.T; 
nmix = model.nmix; 
K = model.nstates;

[n, d] = size(X);
LL = zeros(n, nmix);
mixweight = model.mixweight;
tmpModel.K = K; tmpModel.d = d;
for k=1:nmix
    tmpModel.T = T(:, :, k);
    LL(:, k) = log(mixweight(k)+eps) + discreteLogprob(tmpModel, X);
end
LL = bsxfun(@minus, LL, logsumexp(LL, 2));
L = sum(LL, 2); 

end