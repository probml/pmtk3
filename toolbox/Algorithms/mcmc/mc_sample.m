function S = mc_sample(prior, trans, len, numex)
% Generate random sequences from a Markov chain
% STATE = SAMPLE_MC(PRIOR, TRANS, LEN) generates a sequence of length LEN.
%
% STATE = SAMPLE_MC(PRIOR, TRANS, LEN, N) generates N rows each of length LEN.

% This file is from pmtk3.googlecode.com


if nargin==3
  numex = 1;
end

S = zeros(numex,len);
for i=1:numex
  S(i, 1) = sampleDiscrete(prior);
  for t=2:len
    S(i, t) = sampleDiscrete(trans(S(i,t-1),:));
  end
end

end
