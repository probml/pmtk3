function [pre, post, pred, cycle, d, f] = dfsearch(G, start, directed)
%% DFS Perform a depth-first search of the graph starting from 'start'
%
% Input:
% G(i, j) = 1 iff i is connected to j.
% start is the root vertex of the dfs tree; if [], all nodes are searched
% directed = 1 if the graph is directed
%
% Output:
% d(i) is the time at which node i is first discovered.
% pre is a list of the nodes in the order in which they are first encountered (opened).
% post is a list of the nodes in the order in which they are last encountered (closed).
% 'cycle' is true iff a (directed) cycle is found.
% f(i) is the time at which node i is finished.
% pred(i) is the predecessor of i in the dfs tree.
%
% If the graph is a tree, preorder is parents before children,
% and postorder is children before parents.
% For a DAG, topological order = reverse(postorder).
%
% See Cormen, Leiserson and Rivest, "An intro. to algorithms" 1994, p478.
%%

% This file is from pmtk3.googlecode.com

warning('dfsearchPMTK may be buggy')

n     = length(G);
S     = zeros(1, n); % store node states, 0, 1, or 2
T     = 0;           % time step
d     = zeros(1, n);
f     = zeros(1, n);
pred  = zeros(1, n);
cycle = 0;
pre   = [];
post  = [];

if ~isempty(start)
    [S, T, d, f, pred, cycle, pre, post] = ...
        visitNode(start, G, directed, S, T, d, f, pred, cycle, pre, post);
end
for u = 1:n
    if S(u)==0
        [S, T, d, f, pred, cycle, pre, post] = ...
            visitNode(u, G, directed, S, T, d, f, pred, cycle, pre, post);
    end
end
end


function [S, T, d, f, pred, cycle, pre, post] = ...
    visitNode(u, G, directed, S, T, d, f, pred, cycle, pre, post)

pre  = [pre u];
S(u) = 1;
T    = T + 1;
d(u) = T;
if directed
    ns = children(G, u);
else
    ns = neighbors(G, u);
    if pred(u)
        ns = setdiffPMTK(ns, pred(u)); % don't go back to visit the guy who called you!
    end
end
for v = ns
    switch S(v)
        case 0, % not visited v before (tree edge)
            pred(v) = u;
            [S, T, d, f, pred, cycle, pre, post] = ...
                visitNode(v, G, directed, S, T, d, f, pred, cycle, pre, post);
        case 1, % back edge - v has been visited, but is still open
            cycle = 1;
            %case 2, % v has been visited, but is closed
            % no-op
    end
end
S(u) = 2;
post = [post u];
T    = T + 1;
f(u) = T;
end
