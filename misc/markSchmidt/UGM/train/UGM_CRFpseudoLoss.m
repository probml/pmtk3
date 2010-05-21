function [f,g,H] = UGM_loss(wv,X,Xedge,y,edgeStruct,infoStruct)
% wv(variable)
% X(instance,feature,node)
% Xedge(instance,feature,edge)
% y(instance,node)
% edgeStruct
% inferFunc
% tied

% Form weights
[w,v] = UGM_splitWeights(wv,infoStruct);

% Make Potentials
nodePot = UGM_makeCRFNodePotentials(X,w,edgeStruct,infoStruct);
if edgeStruct.useMex
    edgePot = UGM_makeEdgePotentialsC(Xedge,v,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(infoStruct.tieEdges),int32(infoStruct.ising));
else
    edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
end

if nargout >= 3
    assert(all(edgeStruct.nStates==2) && infoStruct.ising==1 && infoStruct.tieNodes==infoStruct.tieEdges,...
        'Pseudo-Hessian only implemented for 2 state Ising w/ fully tied/untied params');
end


if edgeStruct.useMex
    edgeEnds = edgeStruct.edgeEnds;
    V = edgeStruct.V;
    E = edgeStruct.E;
    nStates = edgeStruct.nStates;
    ising = infoStruct.ising;
    gw = zeros(size(w));
    gv = zeros(size(v));
    if nargout >= 3
        tied = infoStruct.tieNodes;
        Hw = zeros(numel(w));
        Hv = zeros(numel(v));
        Hwv = zeros(numel(v),numel(w));
        % gw,gv,Hw,Hv,Hwv are updated in place
        [f] = UGM_PseudoHessC(gw,gv,w,v,X,Xedge,int32(y),nodePot,edgePot,int32(edgeEnds),int32(V),int32(E),int32(tied),Hw,Hv,Hwv);
    else
        tieNodes = infoStruct.tieNodes;
        tieEdges = infoStruct.tieEdges;
        % gw and gv are updated in place
        [f] = UGM_PseudoLossC(gw,gv,w,v,X,Xedge,int32(y),nodePot,edgePot,int32(edgeEnds),int32(V),int32(E),int32(nStates),int32(tieNodes),int32(tieEdges),int32(ising));
    end
else
    if nargout >= 3
        [f,gw,gv,Hw,Hv,Hwv] = PseudoLoss(w,v,X,Xedge,y,nodePot,edgePot,edgeStruct,infoStruct);
    else
        [f,gw,gv] = PseudoLoss(w,v,X,Xedge,y,nodePot,edgePot,edgeStruct,infoStruct);
    end
end

gw = gw(infoStruct.wLinInd);
gv = gv(infoStruct.vLinInd);
g = [gw(:);gv(:)];

if nargout >= 3
    Hw = Hw(infoStruct.wLinInd,infoStruct.wLinInd);
    Hv = Hv(infoStruct.vLinInd,infoStruct.vLinInd);
    H = [Hw Hwv'
        Hwv Hv];
end

end

%% Matlab version
function [f,gw,gv,Hw,Hv,Hwv] = PseudoLoss(w,v,X,Xedge,y,nodePot,edgePot,edgeStruct,infoStruct)

[nInstances,nNodeFeatures,nNodes] = size(X);
nEdgeFeatures = size(Xedge,2);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nEdges = size(edgeEnds,1);
tieNodes = infoStruct.tieNodes;
tieEdges = infoStruct.tieEdges;
ising = infoStruct.ising;
nStates = edgeStruct.nStates;
maxState = max(nStates);

showMM = 0;

f = 0;
gw = zeros(size(w));
gv = zeros(size(v));

if nargout > 3
    Hw = zeros(numel(w));
    Hv = zeros(numel(v));
    Hwv = zeros(numel(v),numel(w));
end

for i = 1:nInstances
    for n = 1:nNodes

        %% Update Objective
        % Find Neighbors
        edges = E(V(n):V(n+1)-1);

        % Compute Probability of Each State with Neighbors Fixed
        pot = nodePot(n,1:nStates(n),i);
        for e = edges(:)'
            n1 = edgeEnds(e,1);
            n2 = edgeEnds(e,2);

            if n == edgeEnds(e,1)
                ep = edgePot(1:nStates(n),y(i,n2),e,i).';
            else
                ep = edgePot(y(i,n1),1:nStates(n),e,i);
            end
            pot = pot .* ep;
        end

        % Update Objective
        f = f - log(pot(y(i,n))) + log(sum(pot));

        %% Update Gradient
        if nargout > 1
            nodeBel = pot/sum(pot);
            % Update Gradient of Node Weights
            for s = 1:nStates(n)-1
                if s == y(i,n)
                    Obs = X(i,:,n);
                else
                    Obs = zeros(1,nNodeFeatures);
                end
                Exp = nodeBel(s)*X(i,:,n);

                if tieNodes
                    gw(:,s) = gw(:,s) - (Obs - Exp).';
                else
                    gw(:,s,n) = gw(:,s,n) - (Obs - Exp).';
                end
            end

            % Update Gradient of Edge Weights
            for e = edges(:)'

                n1 = edgeEnds(e,1);
                n2 = edgeEnds(e,2);

                if ising == 2
                    if y(i,n1) == y(i,n2)
                        Obs = Xedge(i,:,e);
                    else
                        Obs = zeros(1,nEdgeFeatures);
                    end
                    
                    y_neigh = UGM_getNeighborState(i,n,e,y,edgeEnds);

                    if y_neigh <= length(nodeBel)
                        Exp = nodeBel(y_neigh)*Xedge(i,:,e);
                    else
                        Exp = zeros(1,nEdgeFeatures);
                    end
                        
                    if tieEdges
                        gv(:,y_neigh) = gv(:,y_neigh) - (Obs - Exp).';
                    else
                        gv(:,y_neigh,e) = gv(:,y_neigh,e) - (Obs - Exp).';
                    end
                elseif ising
                    if y(i,n1) == y(i,n2)
                        Obs = Xedge(i,:,e);
                    else
                        Obs = zeros(1,nEdgeFeatures);
                    end

                    y_neigh = UGM_getNeighborState(i,n,e,y,edgeEnds);

                    if y_neigh <= length(nodeBel)
                        Exp = nodeBel(y_neigh)*Xedge(i,:,e);
                    else
                        Exp = zeros(1,nEdgeFeatures);
                    end

                    if tieEdges
                        gv = gv - (Obs - Exp).';
                    else
                        gv(:,e) = gv(:,e) - (Obs - Exp).';
                    end
                else
                    for s = 1:nStates(n)
                        if n == edgeEnds(e,1)
                            neigh = n2;
                        else
                            neigh = n1;
                        end

                        if s == nStates(n) && y(i,neigh) == nStates(neigh)
                            % This element is fixed at 0
                            continue;
                        end

                        if s == y(i,n)
                            Obs = Xedge(i,:,e);
                        else
                            Obs = zeros(1,nEdgeFeatures);
                        end
                        Exp = nodeBel(s)*Xedge(i,:,e);

                        if n == edgeEnds(e,1)
                            s1 = s;
                            s2 = y(i,neigh);
                        else
                            s1 = y(i,neigh);
                            s2 = s;
                        end

                        sInd = (s2-1)*maxState+s1;
                        if tieEdges
                            gv(:,sInd) = gv(:,sInd) - (Obs - Exp).';
                        else
                            gv(:,sInd,e) = gv(:,sInd,e) - (Obs - Exp).';
                        end
                    end
                end
            end
        end

        %% Update Hessian 
        % (only for binary, ising, and tieNodes==tieEdges)

        if nargout >= 4
            % Update Hessian of node weights
            inner = nodeBel(1)*nodeBel(2);

            if tieNodes
                ind1 = 1:nNodeFeatures;
                ind2 = 1:nNodeFeatures;
            else
                ind1 = sub2ind(size(gw),1:nNodeFeatures,repmat(1,[1 nNodeFeatures]),repmat(n,[1 nNodeFeatures]));
                ind2 = sub2ind(size(gw),1:nNodeFeatures,repmat(1,[1 nNodeFeatures]),repmat(n,[1 nNodeFeatures]));
            end
            Hw(ind1,ind2) = Hw(ind1,ind2) + X(i,:,n)'*inner*X(i,:,n);

            % Update Hessian of edge weights wrt node/edge weights
            if tieEdges
                A = zeros(1,nEdgeFeatures);

                for e = edges(:)'
                    y_neigh = UGM_getNeighborState(i,n,e,y,edgeEnds);

                    if y_neigh == 1
                        A = A + Xedge(i,:,e);
                    else
                        A = A - Xedge(i,:,e);
                    end
                end

                Hwv = Hwv + A'*inner*X(i,:,n);
                Hv = Hv + A'*inner*A;

            else % Untied Edges
                for e1 = edges(:)'

                    y_neigh1 = UGM_getNeighborState(i,n,e1,y,edgeEnds);
                                        
                    ind1 = sub2ind(size(gv),1:nEdgeFeatures,repmat(1,[1 nEdgeFeatures]),repmat(e1,[1 nEdgeFeatures]));
                    ind2 = sub2ind(size(gw),1:nNodeFeatures,repmat(1,[1 nNodeFeatures]),repmat(n,[1 nNodeFeatures]));

                    if y_neigh1 == 1
                        Hwv(ind1,ind2) = Hwv(ind1,ind2) + Xedge(i,:,e1)'*inner*X(i,:,n);
                    else
                        Hwv(ind1,ind2) = Hwv(ind1,ind2) - Xedge(i,:,e1)'*inner*X(i,:,n);
                    end

                    for e2 = edges(:)'
                        y_neigh2 = UGM_getNeighborState(i,n,e2,y,edgeEnds);
                        
                        ind2 = sub2ind(size(gv),1:nEdgeFeatures,repmat(1,[1 nEdgeFeatures]),repmat(e2,[1 nEdgeFeatures]));

                        if y_neigh1 == y_neigh2
                            Hv(ind1,ind2) = Hv(ind1,ind2) + Xedge(i,:,e1)'*inner*Xedge(i,:,e2);
                        else
                            Hv(ind1,ind2) = Hv(ind1,ind2) - Xedge(i,:,e1)'*inner*Xedge(i,:,e2);
                        end

                    end

                end

            end
     

        end

        if showMM
            nodeBel = pot./sum(pot);
            [junk mm(i,n)] = max(nodeBel);
        end
    end
end

if showMM
    sum(mm(:) ~= y(:))/numel(y)
    pause;
end

end

function [y_neigh] = UGM_getNeighborState(i,n,e,y,edgeEnds)
% Returns state of neighbor of node n along edge e

if n == edgeEnds(e,1)
    y_neigh = y(i,edgeEnds(e,2));
else
    y_neigh = y(i,edgeEnds(e,1));
end
end

% pot: (e^(w*n)*e^(v*a)*e^(v*b))
% Z: e^(w*n)*e^(v*a)*e^(v*b) + e^(m*n)*e^(v*c)*e^(v*d)
