function [adjMatrix,nodeNames] = getDAG()

nNodes = 27;

for n = 1:nNodes
    nodeNames{n} = sprintf('N%d',n);
end

adjMatrix = zeros(nNodes);
for n1 = 1:nNodes
    for n2 = n1+1:nNodes
        if mod(n2,n1) == 0
           adjMatrix(n1,n2) = 1; 
        end
    end
end