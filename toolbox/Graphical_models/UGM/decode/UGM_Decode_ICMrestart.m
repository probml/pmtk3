function  [y] = UGM_Decode_ICM(nodePot, edgePot, edgeStruct,nRestarts)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)

[nNodes,maxState] = size(nodePot);

maxPot = -inf;
for i = 1:nRestarts
    fprintf('Decoding with ICM with restart %d...\n',i);
    y_sub = ceil(rand(nNodes,1).*edgeStruct.nStates);
    y_sub = UGM_Decode_ICM(nodePot,edgePot,edgeStruct,y_sub);
    
    logPot = UGM_LogConfigurationPotential(y_sub,nodePot,edgePot,edgeStruct.edgeEnds);
    if logPot > maxPot
        fprintf('New Best\n');
        maxPot = logPot;
        y = y_sub;
    end
end