% Demo of topological sorting
% Based on http://en.wikipedia.org/wiki/Topological_sorting. 

% For octave source code:
%http://old.nabble.com/topological-sort-td29696263.html

C=cell(11,1);
C{11}=[7 5];
C{8}=[7 3];
C{2}=11;
C{9}=[8 11];
C{10}=[3 11];

D = 11;
adj  = zeros(D,D);
for j=1:D
  if ~isempty(C{j})
    adj(C{j}, j) = 1;
  end
end
[toporder] = toposort(adj);


G = adj;
Nnodes = D;
nodeNames = cellfun(@(d) sprintf('%d', d), num2cell(1:Nnodes), 'uniformoutput', false);

graphviz(G, 'labels', nodeNames, 'directed', 1, 'filename', 'tmp');


[G, toporder, invtoporder] = toporderDag(G);

for j=1:Nnodes
  nodeNames2{j} = sprintf('%d (orig %d)', j, toporder(j));
end
graphviz(G, 'labels', nodeNames2, 'directed', 1, 'filename', 'tmp2');
