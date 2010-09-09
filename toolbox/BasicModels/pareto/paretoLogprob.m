function logp = paretoLogprob(arg1, arg2, arg3)
% logp(i) = log p(X(i) | m, K); 
% logp = paretoLogprob(model, X); or logp = paretoLogprob(m, K, X); 
%%

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1;
    m = model.m;
    K = model.K; 
    X = arg2; 
else
    m = arg1; 
    K = arg2; 
    X = arg3;
end

% p = K*m^K ./ (X.^(K+1));
% p(X < m) = 0;
X = colvec(X); 
logp = log(K + eps) + K.*log(m +eps) - (K+1).*log(X + eps);
logp(X < m) = log(eps); 



end
