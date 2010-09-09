function answer = isCondInd(G, A, B, C)
%% Is A conditionally independent of B given C in the dag G
% We check the moralized ancestral graph for dseparability 
%
% A, B, C can contain multiple vars: answer is a bit vector the same length
% as A so that A(isCondInd(G, A, B, C)) gives the vars from A that are
% conditionally independent of B given C.
%
% If you want to know if all of the vars in A are conditionally independent
% of B given C, use all(isCondInd(G, A, B, C));
%
%% Example:
%
% dgm = mkAlarmDgm;
% G   = dgm.G;
% query = 14:16
% obs   = 20:35
% hidden = setdiffPMTK(1:size(G), [query, obs])
% prune = hidden(isCondInd(G, hidden, query, obs))
% prune =
%     1     2     4     7    10    12    13    18    36
%%

% This file is from pmtk3.googlecode.com

if nargin == 0, test(); return; end

if nargin < 4, C = []; end
[Ga, remaining] = ancestralGraph(G, [A, B, C]); 
Ga = moralizeGraph(Ga); 
Andx = lookupIndices(A, remaining);
Bndx = lookupIndices(B, remaining); 
Cndx = lookupIndices(C, remaining); 
Ga(Cndx, :) = 0;
Ga(:, Cndx) = 0;
R = reachability_graph(Ga); 
answer = ~any(R(Andx, Bndx), 2)'; 
end

function test()
%% Case: (chain) 1 --> 2 --> 3
G = zeros(3); 
G(1, 2) = 1;
G(2, 3) = 1; 
assert(~isCondInd(G, 1, 3, [])); 
assert(isCondInd(G, 1, 3, 2))
%% Case: (tent) 1 <-- 2 --> 3

G = zeros(3);
G(2, 1) = 1; 
G(2, 3) = 1; 
assert(~isCondInd(G, 1, 3, []));
assert(isCondInd(G, 1, 3, 2));

%% Case: (collider) 1 --> 2 <-- 3
G = zeros(3);
G(1, 2) = 1;
G(3, 2) = 1; 

assert(isCondInd(G, 1, 3, []));
assert(~isCondInd(G, 1, 3, 2));

%% Case: (boundary) 1 --> 2 <-- 3
%                         |
%                         v
%                         4
G = zeros(4);
G(1, 2) = 1;
G(3, 2) = 1;
G(2, 4) = 1;
assert(isCondInd(G, 1, 3, []));
assert(~isCondInd(G, 1, 3, 4));
end
