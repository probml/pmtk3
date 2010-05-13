function path = hmmEstState(model, X)
% Find the most-probable (Viterbi) path through the HMM state trellis. 
% X is a discrete observation sequence. 
%% Inputs:
% model - a struct as returned by e.g. hmmFitEm, which must contain
% at least the fields, pi and A for the starting state distribution
% and transition matrix respectively, as well as type, a string in {'gauss',
% 'discrete'}.
%
% X    - 1-by-T vector of integers in 1:C
%
pi = model.pi;
A  = model.A;
B  = hmmMkLocalEvidence(model, X);
[path, j1, j2] = hmmViterbiC(log(pi+eps), log(A+eps), log(B+eps)); %#ok<NASGU>
end