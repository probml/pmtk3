function [loglik, path] = viterbi_path(prior, transmat, obslik)
% VITERBI Find the most-probable (Viterbi) path through the HMM state trellis.
% path = viterbi(prior, transmat, obslik)
%
% Inputs:
% prior(i) = Pr(Q(1) = i)
% transmat(i,j) = Pr(Q(t+1)=j | Q(t)=i)
% obslik(i,t) = Pr(y(t) | Q(t)=i)
%
% Outputs:
% loglik
% path(t) = q(t), where q1 ... qT is the argmax of the above expression.

%PMTKauthor Kevin Murphy, Dan Ellis

% delta(j,t) = prob. of the best sequence of length t-1 and then going to state j, and O(1:t)
% psi(j,t) = the best predecessor state, given that we ended up in state j at t

% author: Long Le
T = size(obslik, 2);
prior = prior(:);
Q = length(prior);

% Go to log space
obslik = log(obslik);
transmat = log(transmat);
prior = log(prior);

delta = zeros(Q, T);
psi = zeros(Q, T); % backtrace
path = zeros(1, T);

delta(:,1) = prior + obslik(:,1);
for l = 2:T
    for k = 1:Q
        [delta(k,l), psi(k,l)] = max(delta(:, l-1) + transmat(:, k) + obslik(k, l));
    end
end
% Roll back state sequence
[loglik, path(T)] = max(delta(:,T));
for l = T:-1:2
    path(l-1) = psi(path(l), l);
end
    
end
