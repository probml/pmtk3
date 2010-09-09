function logp = binomialLogprob(arg1, arg2, arg3)
% logp(i) = log p( X(i) | mu, N)
% logp = binomialLogprob(arg1, arg2, arg3); 

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1; 
    mu = model.mu; 
    N = model.N;
    X = arg2;
else
    mu = arg1;
    N = arg2; 
    X = arg3; 
end


n = size(X, 1);
X = X(:);
if isscalar(mu)
    M = repmat(mu, n, 1);
    N = repmat(N, n, 1);
else
    M = mu(:);
    N = repmat(N(1), n, 1);
end
logp = nchoosekln(N, X) + X.*log(M) + (N - X).*log1p(-M);



%logp2 = log(binopdf(X, N, M));
%assert(approxeq(logp, logp2)); 



end
