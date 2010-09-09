function logp = gammaLogprob(arg1, arg2, arg3)
% logp(i) = log p(X(i) | a, b) 
% logp = gammaLogprob(model, X); OR logp = gammaLogprob(a, b, X); 
% a is the shape,
% b is the rate, i.e. 1/scale

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    X = arg2; 
    a = model.a; 
    b = model.b; 
else
    a = arg1; 
    b = arg2; 
    X = arg3; 
end

logZ = gammaln(a) - a.*log(b);
logp = (a-1).*log(X) - b.*X - logZ;
logp = logp(:); 



end
