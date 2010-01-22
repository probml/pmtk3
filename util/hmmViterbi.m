function [path,junk1,junk2] = hmmViterbi(logPrior, logTransmat, logObslik)
% Find the most-probable (Viterbi) path through the HMM state trellis.
% INPUTS:
% prior(i) = Pr(Q(1) = i)
% transmat(i,j) = Pr(Q(t+1)=j | Q(t)=i)
% obslik(i,t) = Pr(y(t) | Q(t)=i)
% OUTPUT:
% path(t) = q(t), where q1 ... qT is the argmax of the above expression.

% delta(j,t) = prob. of the best seq of length t-1 and then going to state j, and O(1:t)
% psi(j,t) = the best predecessor state, given that we ended up in state j at t
%#PMTKmex
% Matlab Version by Kevin Murphy - C version by Guillaume Alain
%#author Guillaume Alain 
%#url http://www.cs.ubc.ca/~gyomalin/

%%
% For compatability with the C version, which should be used when possible. 
junk1 = []; junk2 = [];
prior    = exp(logPrior);
transmat = exp(logTransmat);
obslik   = exp(logObslik);
%%


[K T] = size(obslik);
delta = zeros(K,T);
psi = zeros(K,T);
path = zeros(1,T);

t=1;
delta(:,t) = normalize(prior(:) .* obslik(:,t));
psi(:,t) = 0; % arbitrary value, since there is no predecessor to t=1
for t=2:T
  for j=1:K
    [delta(j,t), psi(j,t)] = max(delta(:,t-1) .* transmat(:,j));
    delta(j,t) = delta(j,t) * obslik(j,t);
  end
  delta(:,t) = normalize(delta(:,t));
end

% Traceback
[p, path(T)] = max(delta(:,T));
for t=T-1:-1:1
  path(t) = psi(path(t+1),t+1);
end
