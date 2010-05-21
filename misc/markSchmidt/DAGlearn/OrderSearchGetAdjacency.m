function [adj] = LassoOrderGetAdjacency(order,parents,threshold)

if nargin < 3
    threshold = 0;
end

p = length(order);

adj = zeros(p,p);

for i = 1:p
    coeff = parents{i};
    adj(order(1:i-1),order(i)) = abs(coeff(2:i)) > threshold;
end