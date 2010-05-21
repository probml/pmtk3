function  [y] = UGM_Decode_AlphaBetaSwap(nodePot, edgePot, edgeStruct, decodeFunc,y)
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
maxState = max(nStates);

% Initialize
if nargin < 5
    [junk y] = max(nodePot,[],2);
end
UGM_ConfigurationPotential(y,nodePot,edgePot,edgeStruct.edgeEnds);

% Do Alpha-Beta swaps until convergence
while 1
    y_old = y;
   
    for s1 = 1:maxState
        for s2 = s1+1:maxState
            swapPositions = find(y==s1 | y==s2);
            if ~isempty(swapPositions)
                % Find optimal re-arrangement of nodes assigned to s1 or s2
                fprintf('Swapping %d and %d\n',s1,s2);
                clamped = y;
                clamped(swapPositions) = 0;
                [clampedNP,clampedEP,clampedES] = UGM_makeClampedPotentials(nodePot,edgePot,edgeStruct,clamped);
                
                if 0
                    clampedY = decodeFunc(clampedNP,clampedEP,clampedES);
                else
                    % Remove all other labels
                    clampedNP = clampedNP(:,[s1 s2]);
                    clampedEP = clampedEP([s1 s2],[s1 s2],:);
                    clampedES.nStates = 2*ones(size(nStates));

                    ytmp = decodeFunc(clampedNP,clampedEP,clampedES);
                    
                    clampedY = zeros(size(ytmp));
                    clampedY(ytmp==1) = s1;
                    clampedY(ytmp==2) = s2;
                end
                y(swapPositions) = clampedY;
            end
        end
    end
    
    if all(y==y_old)
        break;
    end
end
