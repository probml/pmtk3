function path = hmmDiscreteViterbi(model, X)
% Find the most-probable (Viterbi) path through the HMM state trellis. 
% X is a discrete observation sequence. 
%% Inputs:
% model - a struct as returned by e.g. hmmGaussFitEm, which must contain
% at least the fields, pi and A for the starting state distribution
% and transition matrix respectively.
%
% X    - 1-by-T vector of integers in 1:C
%
% Matlab Version by Kevin Murphy - C version by Guillaume Alain
%PMTKauthor Guillaume Alain
%PMTKurl http://www.cs.ubc.ca/~gyomalin/

pi = model.pi;
A  = model.A;
B  = hmmDiscreteMkLocalEvidence(model, X);

if exist('hmmViterbiC', 'file') == 3
    [path, j1, j2] = hmmViterbiC(log(pi+eps), log(A+eps), log(B+eps)); %#ok<NASGU>
    return;
end
%%
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
        delta(j,t) = delta(j,t) * obslik(j,t);
    end
    delta(:,t) = normalize(delta(:,t));
end

% Traceback
[p, path(T)] = max(delta(:,T));
for t=T-1:-1:1
    path(t) = psi(path(t+1),t+1);
end

end