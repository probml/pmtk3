%% Demonstrate perfect elimination ordering
% Based on Lauritzen's Saint-Flour notes 2006
%% Non-chordal Example from Fig 3.6 

% This file is from pmtk3.googlecode.com

G = zeros(7,7);
G(1,[2 3 4])=1;
G(2,[1 3 6])=1;
G(3,[1 2 4 5 7])=1;
G(4,[1 3 5])=1;
G(5,[3 4])=1;
G(6,[2 7])=1;
G(7,[6 3])=1;
assert(isequal(G,G'));
%drawNetwork(G)

[order, chordal] = perfectElimOrder(G);
assert(~chordal)

%% Chordal Example  from fig 3.7
G2 = G;
G2(3,7)=0; G2(7,3)=0; % remove edge
G2(1,3)=1; G2(3,1)=1; % add edge
[order, chordal, cliques, numpa] = perfectElimOrder(G2)
assert(chordal)
%[re_index_cliques, cliques]= chordal2RipCliques(G2, order)

 jtree = mcsCliques2Jtree(cliques)
