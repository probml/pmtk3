function path = hmmViterbi(pi, A, B)
% Find the most-probable (Viterbi) path through the HMM state trellis. 
% pi(j) = initial state distribution
% A(i,j) = transition matrix
% B(k,t) = local evidence

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