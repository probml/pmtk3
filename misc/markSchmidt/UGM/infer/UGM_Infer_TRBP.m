function [nodeBel, edgeBel, logZ] = UGM_Infer_TRBP(nodePot,edgePot,edgeStruct,weightType)

if nargin < 4
    weightType = 1;
end

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);

% Compute Edge Appearance Probabilities
if weightType == 0
    mu = ones(nEdges,1); % Ordinary BP
elseif weightType == 1
    % Generate Random Spanning Trees until all edges are covered
    fprintf('generating random spanning trees\n');
    [nNodes,maxState] = size(nodePot);
    edgeEnds = edgeStruct.edgeEnds;
    
    i = 0;
    edgeAppears = zeros(nEdges,1);
    while 1
        i = i+1;
        edgeAppears = edgeAppears+minSpan(nNodes,[edgeEnds rand(nEdges,1)]);
        if all(edgeAppears > 0)
            break;
        end
    end
    mu = edgeAppears/i;
    fprintf('done\n');
elseif weightType == 2
    %nEdges == nNodes*(nNodes-1)/2
    mu = ((nNodes-1)/nEdges)*ones(nEdges,1);
end

if 0 % edgeStruct.useMex
    [nodeBel,edgeBel,logZ] = UGM_Infer_TRBPC(nodePot,edgePot,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(edgeStruct.V),int32(edgeStruct.E),edgeStruct.maxIter,mu);
else
    [nodeBel, edgeBel, logZ] = Infer_TRBP(nodePot,edgePot,edgeStruct,mu);
end
end

%%
function [nodeBel, edgeBel, logZ] = Infer_TRBP(nodePot,edgePot,edgeStruct,mu)

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

maximize = 0;
new_msg = UGM_TRBP(nodePot,edgePot,edgeStruct,maximize,mu);


%% Compute nodeBel
nodeBel = zeros(nNodes,maxState);
for n = 1:nNodes
    edges = E(V(n):V(n+1)-1);
    prod_of_msgs(1:nStates(n),n) = nodePot(n,1:nStates(n))';
    for e = edges(:)'
        if n == edgeEnds(e,2)
            prod_of_msgs(1:nStates(n),n) = prod_of_msgs(1:nStates(n),n) .* (new_msg(1:nStates(n),e).^mu(e));
        else
            prod_of_msgs(1:nStates(n),n) = prod_of_msgs(1:nStates(n),n) .* (new_msg(1:nStates(n),e+nEdges).^mu(e));
        end
    end
    nodeBel(n,1:nStates(n)) = prod_of_msgs(1:nStates(n),n)'./sum(prod_of_msgs(1:nStates(n),n));
end

%% Compute edgeBel
if nargout > 1
    edgeBel = zeros(maxState,maxState,nEdges);
    for e = 1:nEdges
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        
        % temp1 = nodePot by all messages to n1 except from n2
        edges = E(V(n1):V(n1+1)-1);
        temp1 = nodePot(n1,1:nStates(n1))';
        for e2 = edges(:)'
            if n1 == edgeEnds(e2,2)
                incoming = new_msg(1:nStates(n1),e2);
            else
                incoming = new_msg(1:nStates(n1),e2+nEdges);
            end
            if e ~= e2
                temp1 = temp1 .* incoming.^mu(e2);
            else
                temp1 = temp1 ./ incoming.^(1-mu(e2));
            end
        end
        
        % temp2 = nodePot by all messages to n2 except from n1
        edges = E(V(n2):V(n2+1)-1);
        temp2 = nodePot(n2,1:nStates(n2))';
        for e2 = edges(:)'
            if n2 == edgeEnds(e2,2)
                incoming = new_msg(1:nStates(n2),e2);
            else
                incoming = new_msg(1:nStates(n2),e2+nEdges);
            end
            if e ~= e2
                temp2 = temp2 .* incoming.^mu(e2);
            else
                temp2 = temp2 ./ incoming.^(1-mu(e2));
            end
        end
        
        eb = repmat(temp1,[1 nStates(n2)]).*repmat(temp2',[nStates(n1) 1]).*(edgePot(1:nStates(n1),1:nStates(n2),e).^(1/mu(e)));
        
        edgeBel(1:nStates(n1),1:nStates(n2),e) = eb./sum(eb(:));
    end
end

%% Compute Free Energy
if nargout > 2
    
    Energy1 = 0; Energy2 = 0; Entropy1 = 0; Entropy2 = 0;
    nodeBel = nodeBel+eps;
    edgeBel = edgeBel+eps;
    for n = 1:nNodes
        edges = E(V(n):V(n+1)-1);
        
        % Node Entropy (note: different weighting than in Bethe)
        Entropy1 = Entropy1 + (sum(mu(edges))-1)*sum(nodeBel(n,1:nStates(n)).*log(nodeBel(n,1:nStates(n))));
        
        % Node Energy
        Energy1 = Energy1 - sum(nodeBel(n,1:nStates(n)).*log(nodePot(n,1:nStates(n))));
    end
    for e = 1:nEdges
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        
        % Pairwise Entropy (note: different weighting than in Bethe)
        eb = edgeBel(1:nStates(n1),1:nStates(n2),e);
        Entropy2 = Entropy2 - mu(e)*sum(eb(:).*log(eb(:)));
        
        % Pairwise Energy
        ep = edgePot(1:nStates(n1),1:nStates(n2),e);
        Energy2 = Energy2 - sum(eb(:).*log(ep(:)));
    end
    F = (Energy1+Energy2) - (Entropy1+Entropy2);
    logZ = -F;
    
end
end