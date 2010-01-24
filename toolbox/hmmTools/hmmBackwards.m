function [beta] = hmmBackwards(transmat, obslik)
[K T] = size(obslik);
beta = zeros(K,T);
beta(:,T) = ones(K,1);
for t=T-1:-1:1
 beta(:,t) = normalize(transmat * (beta(:,t+1) .* obslik(:,t+1)));
end