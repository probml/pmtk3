function [samples] = UGM_Sample_VarMCMC(nodePot,edgePot,edgeStruct,burnIn,varProb)
% MCMC sampler that switches between random walk MH and variational MF
% sampling
%
% varProb is the probability of trying the variational move
% (set to 0 for purely variational proposals)

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;
maxIter = edgeStruct.maxIter;

% Fit mean-field model
MFnodeBel = UGM_Infer_MeanField(nodePot,edgePot,edgeStruct);

% Initialize
y = meanFieldSample(MFnodeBel);

samples = zeros(nNodes,maxIter);
for i=  1:burnIn+maxIter

    if rand < varProb
        % Do variational Metropolis-Hastings step
        %fprintf('Computing Variational Sample\n');
        logPot = UGM_LogConfigurationPotential(y,nodePot,edgePot,edgeEnds);
        mfLogPot = 0;
        for n = 1:nNodes
            mfLogPot = mfLogPot + log(MFnodeBel(n,y(n)));
        end
        
        y_new = meanFieldSample(MFnodeBel);
        logPot_new = UGM_LogConfigurationPotential(y_new,nodePot,edgePot,edgeEnds);
        mfLogPot_new = 0;
        for n = 1:nNodes
            mfLogPot_new = mfLogPot_new + log(MFnodeBel(n,y_new(n)));
        end
        
        %imagesc([reshape(y,32,32) reshape(y_new,32,32)])
        %colormap gray
        
        logAcceptance = logPot_new + mfLogPot - logPot - mfLogPot_new;
        acceptance = exp(logAcceptance);
        if rand < acceptance
            y = y_new;
            %fprintf('Accepted\n');
        else
            %fprintf('Rejected\n');
        end
        
        %pause
    else
        % Do Gibbs step
        %fprintf('Computing Gibbs Sample\n');
        y = gibbsSample(y,nodePot,edgePot,nStates,edgeEnds,V,E);
    end
    
    if i > burnIn
        samples(:,i-burnIn) = y;
    end
end
end

function [y] = meanFieldSample(nodeBel)
[nNodes,maxStates] = size(nodeBel);
y = zeros(nNodes,1);
for n = 1:nNodes
    y(n) = sampleDiscrete(nodeBel(n,:));
end
end

function [y] = gibbsSample(y,nodePot,edgePot,nStates,edgeEnds,V,E)
[nNodes,maxState] = size(nodePot);

for n = 1:nNodes

    % Compute Node Potential
    pot = nodePot(n,1:nStates(n));

    % Find Neighbors
    edges = E(V(n):V(n+1)-1);

    % Multiply Edge Potentials
    for e = edges(:)'
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);

        if n == edgeEnds(e,1)
            ep = edgePot(1:nStates(n1),y(n2),e)';
        else
            ep = edgePot(y(n1),1:nStates(n2),e);
        end
        pot = pot .* ep;
    end

    % Sample State;
    y(n) = sampleDiscrete(pot./sum(pot));
end

end