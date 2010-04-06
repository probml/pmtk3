function [logp, alpha, beta, gamma, B] = gaussHmmInfer(model, X)
% logp        = log p(X | model)
% alpha(i, t) = p(S(t)=i | X(1:t, :)    (filtered)
% beta(i,t) propto p(X(t+1:T, :) | S(t=i))
% gamma(i,t)  = p(S(t)=i | X(1:T, :))   (smoothed)
% B - local evidence
%*** X must be a single sequence ***
%
pi       = model.pi;
A        = model.A;
emission = model.emission;
nstates  = model.nstates;
seqLength = size(X, 1);
B = zeros(nstates, seqLength);
for j=1:nstates
    B(j, :) = exp(gaussLogprob(emission{j}, X));
end
if nargout < 3
    [logp, alpha] = hmmFwd(pi, A, B);
else
    [gamma, alpha, beta, logp] = hmmFwdBack(pi, A, B);
end

end