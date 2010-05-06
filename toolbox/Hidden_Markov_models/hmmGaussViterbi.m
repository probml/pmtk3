function path = hmmGaussViterbi(model, X)
% Find the most-probable (Viterbi) path through the HMM state trellis. 
% X is a real-valued observation sequence. 
%% Inputs:
% model - a struct as returned by e.g. hmmGaussFitEm, which must contain
% at least the fields, pi and A for the starting state distribution
% and transition matrix respectively.
%
% X    - T-by-D observation
%
pi = model.pi;
A  = model.A;
B  = hmmGaussMkLocalEvidence(model, X);
[path, j1, j2] = hmmViterbiC(log(pi+eps), log(A+eps), log(B+eps)); %#ok<NASGU>


end