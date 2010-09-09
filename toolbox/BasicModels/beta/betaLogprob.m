function logp = betaLogprob(arg1, arg2, arg3)
% logp(i) = log p( X(i) | a, b)
% logp = betaLogprob(model, X); or logp = betaLogprob(a, b, X);

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    a = model.a;
    b = model.b;
    X = arg2;
else
    a = arg1;
    b = arg2;
    X = arg3;
end


logkerna = (a-1).*log(X);
logkerna(a==1 & X==0) = 0;
logkernb = (b-1).*log(1-X);
logkernb(b==1 & X==1) = 0;
logp = logkerna + logkernb - betaln(a,b);


% logp2 = log(betapdf(X, a, b));
% assert(approxeq(logp, logp2));
end
