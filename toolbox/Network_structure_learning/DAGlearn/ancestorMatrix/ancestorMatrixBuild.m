function [A] = ancestorMatrixBuild(adj)

p = length(adj);

A = zeros(p);
[i j] = find(adj);
for edge = 1:length(i)
   %fprintf('Adding Edge %d => %d\n',i(edge),j(edge)); 
   ancestorMatrixAddC_InPlace(A,i(edge),j(edge));
end
