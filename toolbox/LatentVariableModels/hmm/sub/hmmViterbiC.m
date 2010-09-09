function [path, j1, j2] = hmmViterbiC(logpi, logA, logB)
% Find the most-probable (Viterbi) path through the HMM state trellis. 
% logpi(j) = log of initial state distribution
% logA(i,j) = log of transition matrix
% logB(k,t) = log of soft evidence
% * we use log of inputs for compatability with .mex version *
% * called hmmViterbiC since Matlab has an hmmViterbi function already *
%%

% This file is from pmtk3.googlecode.com


pi = exp(logpi);
A = exp(logA);
B = exp(logB); 

[K T] = size(B);
delta = zeros(K,T);
psi = zeros(K,T);
path = zeros(1,T);
t=1;
delta(:,t) = normalize(pi(:) .* B(:,t));
psi(:,t) = 0; % arbitrary value, since there is no predecessor to t=1
for t=2:T
    for j=1:K
        [delta(j,t), psi(j,t)] = max(delta(:,t-1) .* A(:,j));
        delta(j,t) = delta(j,t) * B(j,t);
    end
    delta(:,t) = normalize(delta(:,t));
end

% Traceback
[p, path(T)] = max(delta(:,T));
for t=T-1:-1:1
    path(t) = psi(path(t+1),t+1);
end

j1 = []; % for .mex compatability 
j2 = [];
end
