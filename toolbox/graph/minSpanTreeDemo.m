%% Demo of minimum spanning tree
% Example from Cormen, Leisersen, Rivest p508

a=1; b=2; c=3; d=4; e=5; f=6; g=7; h=8; i=9;
G = zeros(9,9);
G(a,b)=4; G(a,h)=8;
G(b,c)=8; G(b,h)=11;
G(c,d)=7; G(c,i)=2; G(c,f)=4;
G(d,f)=14; G(d,e)=9;
G(e,f)=10; 
G(f,g)=2;
G(g,i)=6; G(g,h)=1;
G(h,i) = 7;
G = mkSymmetric(G);
%figure; drawNetwork(G)

A = G; A((A==0))=inf;
[T, cost] =  minSpanTreeKruskal(A) % Kruskal
assert(cost==37)

[T2, cost2] =  minSpanTreePrim(A) % Prim
assert(cost2==37)
%drawNetwork(T2)


% Example from Aho, Hopcroft Ullman p234
G = zeros(6,6);
G(1,2)=6; G(1,3) = 1; G(1,4) = 5;
G(2,5)=3; G(2,3)=5; 
G(3,4)=5; G(3,5)=6; G(3,6)=4;
G(4,6)=2;
G(5,6)=6;

G = mkSymmetric(G);
A = G; A((A==0))=inf; % set absent edgges to impossible

[T, cost] =  minSpanTreeKruskal(A) % Kruskal
assert(cost==15)

[T2, cost2] =  minSpanTreePrim(A) % Prim
assert(cost2==15)
