function  [y] = UGM_Decode_Block_ICM(nodePot, edgePot, edgeStruct, blocks, decodeFunc,y)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

% Initialize
nBlocks = length(blocks);
if nargin < 6
    [junk y] = max(nodePot,[],2);
end

done = 0;
while ~done
    done = 1;
    for b = 1:nBlocks
        clamped = y;
        clamped(blocks{b}) = 0;
        
      [clampedNP,clampedEP,clampedES] = UGM_makeClampedPotentials(nodePot, edgePot, edgeStruct, clamped);
        
      clampedY = decodeFunc(clampedNP,clampedEP,clampedES);
      
      if any(clampedY ~= y(blocks{b}))
          fprintf('Block Improvement!\n');
          y(blocks{b}) = clampedY;
          done = 0;
      end
    end

end