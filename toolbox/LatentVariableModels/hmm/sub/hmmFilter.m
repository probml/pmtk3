function [loglik, alpha] = hmmFilter(initDist, transmat, softev)
% Calculate p(S(t)=i| y(1:t))
% INPUT:
% initDist(i) = p(S(1) = i)
% transmat(i,j) = p(S(t) = j | S(t-1)=i)
% softev(i,t) = p(y(t)| S(t)=i)
%
% OUTPUT
% loglik = log p(y(1:T))
% alpha(i,t)  = p(S(t)=i| y(1:t))

% This file is from pmtk3.googlecode.com



[K T] = size(softev);
scale = zeros(T,1);
AT = transmat';
if nargout >= 2
    alpha = zeros(K,T);
    [alpha(:,1), scale(1)] = normalize(initDist(:) .* softev(:,1));
    for t=2:T
        [alpha(:,t), scale(t)] = normalize((AT * alpha(:,t-1)) .* softev(:,t));
    end
else
    % save some memory
    [alpha, scale(1)] = normalize(initDist(:) .* softev(:,1));
    for t=2:T
        [alpha, scale(t)] = normalize((AT * alpha) .* softev(:,t));
    end
end
loglik = sum(log(scale+eps));

end
