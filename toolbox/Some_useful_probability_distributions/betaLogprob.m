function logp = betaLogprob(model, X)
% logp(i) = log p( X(i) | model.a, model.b)

a = model.a;
b = model.b;
logkerna = (a-1).*log(X);
logkerna(a==1 & X==0) = 0;
logkernb = (b-1).*log(1-X);
logkernb(b==1 & X==1) = 0;
logp = logkerna + logkernb - betaln(a,b);


% logp2 = log(betapdf(X, a, b));
% assert(approxeq(logp, logp2));
end