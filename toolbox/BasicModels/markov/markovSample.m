function S = markovSample(model, len, nsamples)
% Sample from a markov distribution
% model has fields pi, A as returned by markovFit
%
% S is of size nsamples-by-len
%

% This file is from pmtk3.googlecode.com

if nargin < 3, nsamples = 1; end
pi = model.pi;
A = model.A;
S = zeros(nsamples, len);
for i=1:nsamples
    S(i, 1) = sampleDiscrete(pi);
    for t=2:len
        S(i, t) = sampleDiscrete(A(S(i, t-1), :));
    end
end
end
