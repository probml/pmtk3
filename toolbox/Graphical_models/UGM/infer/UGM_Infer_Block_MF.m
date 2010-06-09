function [nodeBel, edgeBel, logZ] = UGM_Infer_Block_MF(nodePot,edgePot,edgeStruct,blocks,inferFunc)

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;
maxIter = edgeStruct.maxIter;

nBlocks = length(blocks);



nodeBel = nodePot;
for n = 1:nNodes
    nodeBel(n,:) = nodeBel(n,:)/sum(nodeBel(n,:));
end

for i = 1:maxIter
    oldNodeBel = nodeBel;

    
    for b = 1:nBlocks
        % Compute Graph where where all nodes outside the block
        % have been replaced with a mean-field approximation
        clamped = -ones(nNodes,1);
        clamped(blocks{b}) = 0;
        [mfNP,mfEP,mfES,edgeMap(:,b)] = UGM_makeClampedPotentials(nodePot, edgePot, edgeStruct, clamped,nodeBel);

        % Do inference on the modified graph to update the blocks
        [nodeBel(blocks{b},:),mfEB{b},mfLogZ(b)] = inferFunc(mfNP,mfEP,mfES);
    end

    change = sum(abs(nodeBel(:)-oldNodeBel(:)));
    fprintf('Iter = %d of %d, change = %f\n',i,maxIter,change);
    
    if change < 1e-4
        break;
    end
end

if nargout > 1
    edgeBel = zeros(maxState,maxState,nEdges);
    for e = 1:nEdges
        for b = 1:nBlocks
            if edgeMap(e,b) ~= 0
                edgeBel(:,:,e) = mfEB{b}(:,:,edgeMap(e,b));
            end
        end
    end
    % Compute edge beliefs for edges between blocks
    % (the edgeBel computation assumes that blocks are disjoint)
    U = 0;
    for e = 1:nEdges
        if sum(sum(edgeBel(:,:,e))) == 0
            n1 = edgeEnds(e,1);
            n2 = edgeEnds(e,2);
            for s1 = 1:nStates(n1)
                for s2 = 1:nStates(n2)
                    edgeBel(s1,s2,e) = nodeBel(n1,s1)*nodeBel(n2,s2);
                end
            end
            
            if nargout >= 3
            % Pairwise Mean-Field Average Energy Term
                U = U + sum(sum(edgeBel(1:nStates(n1),1:nStates(n2),e).*log(edgePot(1:nStates(n1),1:nStates(n2),e))));
            end
        end
    end
end

if nargout > 2
    logZ = sum(mfLogZ)-U;
end


