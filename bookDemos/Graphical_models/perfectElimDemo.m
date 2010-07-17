% Demonstrate perfect elimination ordering
% Based on Lauritzen's Saint-Flour notes 2006

%% Non-chordal Example from Fig 3.6 
% We use the node number in fig 3.3 when creating the graph
G = zeros(7,7);
G(1,[2 3])=1;
G(2,[1 4 5])=1;
G(3,[1 5])=1;
G(4,[2 7])=1;
G(5,[2 3 6 7])=1;
G(6,[5 7])=1;
G(7,[4 5 6])=1;
assert(isequal(G,G'));
%drawNetwork(G)

[order, chordal] = perfectElimOrderKpm(G);
assert(~chordal)

%% Chordal Example  from fig 3.7
G2 = G;
G2(3,5)=0; G2(5,3)=0; % remove edge
G2(4,5)=1; G2(5,4)=1; % add edge
[order, chordal] = perfectElimOrderKpm(G2)
assert(chordal)