function logp = gammaLogprob(model, X)
% logp(i) = log p(X(i) | model.a, model.b) 
% model.a is the shape,
% model.b is the rate, (not scale).
a = model.a;
b = model.b;


logZ = gammaln(a) - a.*log(b);
logp = (a-1).*log(X) - b.*X - logZ;
logp = logp(:); 



end
