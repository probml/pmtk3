function [adj] = fixed_Chain(nNodes)
adj = zeros(nNodes);
for i = 1:nNodes-1
    adj(i,i+1) = 1;
    adj(i+1,i) = 1;
end
