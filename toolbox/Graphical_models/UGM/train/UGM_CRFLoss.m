function [f,g] = UGM_loss(wv,X,Xedge,y,edgeStruct,infoStruct,inferFunc,varargin)
% wv(variable)
% X(instance,feature,node)
% Xedge(instance,feature,edge)
% y(instance,node)
% edgeStruct
% inferFunc
% varargin - additional parameters of inferFunc

showErr = 0;

[nInstances,nNodeFeatures,nNodes] = size(X);
nEdgeFeatures = size(Xedge,2);
nFeatures = nNodeFeatures+nEdgeFeatures;
edgeEnds = edgeStruct.edgeEnds;
nEdges = size(edgeEnds,1);
tieNodes = infoStruct.tieNodes;
tieEdges = infoStruct.tieEdges;
ising = infoStruct.ising;
nStates = edgeStruct.nStates;
maxState = max(nStates);

% Form weights
[w,v] = UGM_splitWeights(wv,infoStruct);

f = 0;
if nargout > 1
    gw = zeros(size(w));
    gv = zeros(size(v));
end

% Make Potentials
nodePot = UGM_makeCRFNodePotentials(X,w,edgeStruct,infoStruct);
if edgeStruct.useMex
    edgePot = UGM_makeEdgePotentialsC(Xedge,v,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(infoStruct.tieEdges),int32(infoStruct.ising));
else
    edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
end

% Check that potentials don't overflow
if sum(nodePot(:))+sum(edgePot(:)) > 1e100
    f = inf;
    if nargout > 1
        gw = gw(infoStruct.wLinInd);
        gv = gv(infoStruct.vLinInd);
        g = [gw(:);gv(:)];
    end
    return;
end

% Always use the same seed (makes learning w/ stochastic inference more robust)
randState = rand('state');
rand('state',0);
randnState= randn('state');
randn('state',0);

if edgeStruct.useMex
    % Set f to be the negative sum of the unnormalized potentials
    f = UGM_Loss_subC(int32(y),nodePot,edgePot,int32(edgeEnds));
else
    f = -computeUnnormalizedPotentials(y,nodePot,edgePot,edgeEnds);
end

for i = 1:nInstances

        % For CRFs, we need to do inference on each example
        [nodeBel,edgeBel,logZ] = inferFunc(nodePot(:,:,i),edgePot(:,:,:,i),edgeStruct,varargin{:});

    % Update objective based on this training example
    f = f + logZ;

    if nargout > 1
        % Update gradient
        if edgeStruct.useMex
            % Update gw and gv in-place
            UGM_updateGradientC(gw,gv,X(i,:,:),Xedge(i,:,:),y(i,:),nodeBel,edgeBel,int32(nStates),int32(tieNodes),int32(tieEdges),int32(ising),int32(edgeEnds));
        else
            [gw,gv] = updateGradient(gw,gv,X(i,:,:),Xedge(i,:,:),y(i,:),nodeBel,edgeBel,infoStruct,edgeStruct);
        end
    end

end

if nargout > 1
    gw = gw(infoStruct.wLinInd);
    gv = gv(infoStruct.vLinInd);
    g = [gw(:);gv(:)];
end

% Reset state
rand('state',randState);
randn('state',randnState);

end

function [f] = computeUnnormalizedPotentials(y,nodePot,edgePot,edgeEnds)
[nInstances,nNodes] = size(y);
nEdges = size(edgeEnds,1);
f = 0;
for i = 1:nInstances
    % Caculate Potential of Observed Labels
    pot = 0;
    for n = 1:nNodes
        pot = pot + log(nodePot(n,y(i,n),i));
    end
    for e = 1:nEdges
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        pot = pot + log(edgePot(y(i,n1),y(i,n2),e,i));
    end

    % Update  based on this training example
    f = f + pot;
end
end

function [gw,gv] = updateGradient(gw,gv,X,Xedge,y,nodeBel,edgeBel,infoStruct,edgeStruct)
[nInstances nNodeFeatures nNodes] = size(X);
nEdgeFeatures = size(Xedge,2);
edgeEnds = edgeStruct.edgeEnds;
nEdges = size(edgeEnds,1);
tieNodes = infoStruct.tieNodes;
tieEdges = infoStruct.tieEdges;
ising = infoStruct.ising;
nStates = edgeStruct.nStates;
maxState = max(nStates);


% Update gradient of node features
for n = 1:nNodes
    for s = 1:nStates(n)-1
        if s == y(1,n)
            O = X(1,:,n);
        else
            O = zeros(1,nNodeFeatures);
        end
        E = nodeBel(n,s)*X(1,:,n);

        if tieNodes
            gw(:,s) = gw(:,s) - (O - E)';
        else
            gw(:,s,n) = gw(:,s,n) - (O - E)';
        end
    end
end

% Update gradient of edge features
for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);
    if ising == 2
        for s = 1:min(nStates(n1),nStates(n2))
           if y(1,n1) == s && y(1,n2) == s
               O = Xedge(1,:,e);
           else
               O = zeros(1,nEdgeFeatures);
           end
           E = edgeBel(s,s,e)*Xedge(1,:,e);
           
           if tieEdges
               gv(:,s) = gv(:,s) - (O - E)';
           else
               gv(:,s,e) = gv(:,s,e) - (O - E)';
           end
        end
    elseif ising
        if y(1,n1)==y(1,n2)
            O = Xedge(1,:,e);
        else
            O = zeros(1,nEdgeFeatures);
        end
        E = (sum(diag(edgeBel(:,:,e))))*Xedge(1,:,e);

        if tieEdges
            gv = gv - (O - E)';
        else
            gv(:,e) = gv(:,e) - (O - E)';
        end
    else
        for s1 = 1:nStates(n1)
            for s2 = 1:nStates(n2)
                if s1 == nStates(n1) && s2 == nStates(n2)
                    % This element is fixed at 0
                    continue;
                end

                if s1 == y(1,n1) && s2 == y(1,n2)
                    O = Xedge(1,:,e);
                else
                    O = zeros(1,nEdgeFeatures);
                end
                E = edgeBel(s1,s2,e)*Xedge(1,:,e);

                s = (s2-1)*maxState+s1; % = sub2ind([maxState maxState],s1,s2);

                if tieEdges
                    gv(:,s) = gv(:,s) - (O-E)';
                else
                    gv(:,s,e) = gv(:,s,e) - (O-E)';
                end
            end
        end
    end
end
end
