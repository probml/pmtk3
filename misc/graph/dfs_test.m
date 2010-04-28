% Do the example in fig 23.4 p479 of Cormen, Leiserson and Rivest (1994)

u = 1; v = 2; w = 3; x = 4; y = 5; z = 6;
n = 6;
dag=zeros(n,n);
dag(u,[v x])=1;
dag(v,y)=1;
dag(w,[y z])=1;
dag(x,v)=1;
dag(y,x)=1;
dag(z,z)=1;

[d, pre, post, cycle, f, pred] = dfs(dag, [], 1);
assert(isequal(d, [1 2 9 4 3 10]))
assert(isequal(f, [8 7 12 5 6 11])
assert(cycle)

% Now give it an undirected cyclic graph
G = mk_2D_lattice(2,2,0);
% 1 - 3
% |   |
% 2 - 4
[d, pre, post, cycle, f, pred] = dfs(G, [], 0);
% d = [1 2 4 3]
assert(cycle)

% Now break the cycle
G(1,2)=0; G(2,1)=0;
[d, pre, post, cycle, f, pred] = dfs(G, [], 0);
assert(~cycle)
