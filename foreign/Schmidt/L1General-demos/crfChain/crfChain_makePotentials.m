function [nodePot,edgePot] = crfChain_makePotentials(X,w,v_start,v_end,v,nFeatures,featureStart,sentences,s)
% Make Potentials for Sentence s
nFeaturesTotal = featureStart(end)-1;
nNodes = sentences(s,2)-sentences(s,1)+1;
nStates = length(v_start);

% Make node potentials
nodePot = zeros(nNodes,nStates);
for n = 1:nNodes
    features = X(sentences(s,1)+n-1,:); % features for word w in sentence s

    for state = 1:nStates
        pot = 0;
        for f = 1:length(nFeatures)
            if features(f) ~= 0 % we ignore features that are 0
                featureParam = featureStart(f)+features(f)-1;
                pot = pot+w(featureParam+nFeaturesTotal*(state-1));
            end
        end
        nodePot(n,state) = pot;
    end
end
nodePot(1,:) = nodePot(1,:) + v_start'; % Modification for beginning of sentence
nodePot(end,:) = nodePot(end,:) + v_end'; % Modification for end of sentence
nodePot = exp(nodePot);

% Transitions are not dependent on features, so are position independent
edgePot = exp(v); 