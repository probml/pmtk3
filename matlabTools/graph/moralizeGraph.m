function [M, moral_edges] = moralizeGraph(G)
% Ensure that for every child, all its parents are married (connected)
% and then drop directionality of edges.

% This file is from pmtk3.googlecode.com


M = G;
n = length(M);
for i=1:n
    fam = family(G, i);
    M(fam, fam)=1;
end
M = setdiag(M, 0);
if nargout > 1
    moral_edges = sparse(triu(max(0, M-G), 1));
end
M = mkSymmetric(M);
end

function ps = parents(G, i)
ps = find(G(:, i))';
end

function f = family(G, i)
f = [parents(G, i) i];
end

