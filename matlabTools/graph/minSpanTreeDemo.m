%% Demo of minimum spanning tree
function minSpanTreeDemo()

% This file is from pmtk3.googlecode.com

%% Example from Cormen, Leisersen, Rivest p508

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
if 0
h=drawNetwork(G, '-undirected', true);
freeze(h)
title('graph')
printPmtkFigure('minSpanTreeGraph')
end

A = G; A((A==0))=inf;
[T, cost] =  minSpanTreeKruskal(A); % Kruskal
assert(cost==37)
if 0
h2=plotTree(G, T);
%freeze(h2)
title('output of Kruskal (blue=tree)')
printPmtkFigure('minSpanTreeKruskal')
end

[T2, cost2] =  minSpanTreePrim(A); % Prim
assert(cost2==37)
if 0
h3=plotTree(G, T2);
%freeze(h3)
title('output of Prim (blue=tree)')
printPmtkFigure('minSpanTreePrim')
end

[T3] =  mst_prim(A); % Prim
cost3 = sum(A(find(T3)))/2;
assert(cost3==37)


%% Example from Aho, Hopcroft Ullman p234
G = zeros(6,6);
G(1,2)=6; G(1,3) = 1; G(1,4) = 5;
G(2,5)=3; G(2,3)=5; 
G(3,4)=5; G(3,5)=6; G(3,6)=4;
G(4,6)=2;
G(5,6)=6;

G = mkSymmetric(G);
A = G; A((A==0))=inf; % set absent edgges to impossible

[T, cost] =  minSpanTreeKruskal(A); % Kruskal
assert(cost==15)

[T2, cost2] =  minSpanTreePrim(A); % Prim
assert(cost2==15)

[T3] =  mst_prim(A); % Prim
cost3 = sum(A(find(T3)))/2;
assert(cost3 == 15);

end

function h=plotTree(G,T)
% orange = not in tree, blue = in tree
e = 1;
Nnodes = size(G,1);
colors = pmtkColors;
for i=1:Nnodes
  nodeNames{i} = sprintf('v%d', i);
  for j=1:Nnodes
    if G(i,j) == 0, continue; end
    src  = sprintf('%d', i);
    dest  = sprintf('%d', j);
    edgeColors{e,1} =  src;
    edgeColors{e,2} = dest;
    edgeStyles{e,1} =  src;
    edgeStyles{e,2} = dest;
    if T(i,j)==1 || T(j,i)==1
      edgeColors{e,3} = colors{1};
      edgeStyles{e,3} = '-';
    else
      edgeColors{e,3} = colors{2};
      edgeStyles{e,3} = ':';
    end
    e=e+1;
  end
end
h=drawNetwork('-adjMat', G, '-undirected', true, ...
 '-edgeColors', edgeColors, '-edgeStyles', edgeStyles);
end
