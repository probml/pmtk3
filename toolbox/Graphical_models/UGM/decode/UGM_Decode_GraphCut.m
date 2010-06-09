function  [y] = UGM_Decode_GC(nodePot, edgePot, edgeStruct)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)

verbose = 0;

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

assert(all(nStates == 2),'Graph Cuts only implemented for binary graphs');

% Make Energies
nodeEnergy = -log(nodePot);
edgeEnergy = -log(edgePot);

% Check Sub-Modularity Condition
for e = 1:nEdges
    assert(edgeEnergy(1,1,e) + edgeEnergy(2,2,e) <= edgeEnergy(1,2,e) + edgeEnergy(2,1,e),...
        'Graph Cuts only implemented for sub-modular potentials\n');
end

% Make Graph
sCapacities = zeros(nNodes,1);
eCapacities = zeros(nEdges,1);
tCapacities = zeros(nNodes,1);
for n = 1:nNodes
    if nodeEnergy(n,1) < nodeEnergy(n,2)
        sCapacities(n) = sCapacities(n) + nodeEnergy(n,2) - nodeEnergy(n,1);
    else
        tCapacities(n) = tCapacities(n) + nodeEnergy(n,1) - nodeEnergy(n,2);
    end
    edges = E(V(n):V(n+1)-1);
    for e = edges(:)'
        if n == edgeEnds(e,1)
            sCapacities(n) = sCapacities(n) + edgeEnergy(2,1,e) - edgeEnergy(1,1,e);
            eCapacities(e) = edgeEnergy(1,2,e) + edgeEnergy(2,1,e) - edgeEnergy(1,1,e) - edgeEnergy(2,2,e);
        else
            tCapacities(n) = tCapacities(n) + edgeEnergy(2,1,e) - edgeEnergy(2,2,e);
        end
    end
end

%% Solve Max-Flow Problem

% Initialize
f_s = zeros(nNodes,1);
f_e = zeros(nEdges,2);
f_t = zeros(nNodes,1);

% To speed things up, initialize flows that don't go through edges
for n = 1:nNodes
    cf = min(sCapacities(n),tCapacities(n));
    if cf > 0
        if verbose
        fprintf('Initializing Direct Flow through %d\n',n);
        end
        f_s(n) = cf;
        f_t(n) = cf;
    end
end

while 1
    % Compute Residual Network
    g_s = sCapacities - f_s;
    g_e = [eCapacities zeros(nEdges,1)] - f_e;
    g_t = tCapacities - f_t;
    
    % Find an Augmenting Path in Residual Network
    expanded = zeros(nNodes,1);
    Q = find(g_s > 0);
    expanded(g_s > 0) = 1;
    path = 0;
    traceBack = zeros(nNodes,3);
    while ~isempty(Q)
        % Get first element in Q
        if verbose
        fprintf('Processing %d\n',Q(1));
        end
        n = Q(1);
        Q = Q(2:end);

        % Check if we have an augmenting path to sink
        if g_t(n) > 0
            % We have found an augmenting path
            if verbose
            fprintf('Path Found\n');
            end
            path = n;
            break;
        end

        % Check if we can push flow along one of n's edges
        edges = E(V(n):V(n+1)-1);
        for e = edges(:)'
            if n == edgeEnds(e,1)
                n2 = edgeEnds(e,2);
                if g_e(e,1) > 0 && ~expanded(n2)
                    % Add Neighbor to Q
                    if verbose
                    fprintf('Adding %d to list\n',n2);
                    end
                    expanded(n2) = 1;
                    Q(end+1) = n2;
                    traceBack(n2,:) = [n e 1];
                end
            else
                n2 = edgeEnds(e,1);
                if g_e(e,2) > 0 && ~expanded(n2)
                    % Add Neighbor to Q
                    if verbose
                    fprintf('Adding %d to list\n',n2);
                    end
                    expanded(n2) = 1;
                    Q(end+1) = n2;
                    traceBack(n2,:) = [n e 2];
                end
            end
        end
    end
    
    if path
        if verbose
        fprintf('Path Found during BFS\n');
        end
        
        n = path;
        if traceBack(n,1) == 0 % This case should never happen due to initialization
            if verbose
            fprintf('Direct path from source to %d to sink\n',n);
            end
            
            % Compute capacity of flow in residual network
            cf = min(g_s(n),g_t(n));
            
            % Update flows
            f_s(n) = f_s(n) + cf;
            f_t(n) = f_t(n) + cf;
            
        else
            if verbose
            fprintf('Indirect path from source to sink through edge\n');
            end
            
            % Compute capacity of flow in residual network
            n = path;
            cf = g_t(n);
            while 1
               if traceBack(n,1) == 0
                  cf = min(cf,g_s(n)); 
                  break;
               else
                   if traceBack(n,3) == 1 % Forward Edge
                       if verbose
                       fprintf('Pushing flow forward\n');
                       end
                       e = traceBack(n,2);
                       cf = min(cf,g_e(e,1));
                   else
                       if verbose
                       fprintf('Pushing flow backwards\n');
                       end
                       e = traceBack(n,2);
                       cf = min(cf,g_e(e,2));
                   end
                   n = traceBack(n);
               end
            end
            
            % Update flows
            n = path;
            f_t(n) = f_t(n) + cf;
            while 1
               if traceBack(n,1) == 0
                  f_s(n) = f_s(n) + cf;
                  break;
               else
                   if traceBack(n,3) == 1 % Forward Edge
                       e = traceBack(n,2);
                       f_e(e,1) = f_e(e,1) + cf;
                       f_e(e,2) = -f_e(e,1);
                   else
                       e = traceBack(n,2);
                       f_e(e,2) = f_e(e,2) + cf;
                       f_e(e,1) = -f_e(e,2);
                   end
                   n = traceBack(n);
               end
            end
        end
    else
        if verbose
        fprintf('No Augmenting Path found during BFS\n');
        end
        break;
    end
end
% Update

%% Compute Min-Cut: nodes that can be reached by S in residual network
y = -expanded+2;