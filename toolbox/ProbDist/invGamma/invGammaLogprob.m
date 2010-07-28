function logp = invGammaLogprob(arg1, arg2, arg3)
% logp(i) = log p(X(i) | a, b)
% logp = invGammaLogprob(model, X); OR logp = invGammaLogprob(a, b, X); 
% a is the shape, 
% b is the scale.
% PMTKsimpleModel invGamma
%%

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
logp = -(a+1).*log(X) - b./X - logZ; 




end


