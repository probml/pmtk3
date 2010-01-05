function [nll,g] = crfChain_loss(wv,X,y,nStates,nFeatures,featureStart,sentences)

nSentences = size(sentences,1);

% Get the weights {w,v,v_start,v_end} out of the vector wv
nFeaturesTotal = featureStart(end)-1;
w = reshape(wv(1:nFeaturesTotal*nStates),nFeaturesTotal,nStates);
v_start = wv(nFeaturesTotal*nStates+1:nFeaturesTotal*nStates+nStates);
v_end = wv(nFeaturesTotal*nStates+nStates+1:nFeaturesTotal*nStates+2*nStates);
v = reshape(wv(nFeaturesTotal*nStates+2*nStates+1:end),nStates,nStates);

f = 0;
gw = zeros(featureStart(end)-1,nStates);
gv_start = zeros(nStates,1);
gv_end = zeros(nStates,1);
gv = zeros(nStates);
for s = 1:nSentences
    nNodes = sentences(s,2)-sentences(s,1)+1;
    y_s = y(sentences(s,1):sentences(s,2));
    
    [nodePot,edgePot]=crfChain_makePotentials(X,w,v_start,v_end,v,nFeatures,featureStart,sentences,s);
    [nodeBel,edgeBel,logZ] = crfChain_infer(nodePot,edgePot);
    % Add log-potential of the training data labels
    for n = 1:nNodes % nodes
       f = f + log(nodePot(n,y_s(n)));
    end
    for n = 1:nNodes-1 %edges
       f = f + log(edgePot(y_s(n),y_s(n+1))); 
    end
    
    % Subract the log-normalizing constant
    f = f - logZ;
    
    % Update gradient of node features
    for n = 1:nNodes
        features = X(sentences(s,1)+n-1,:); % features for word w in sentence s
         for feat = 1:length(nFeatures)
             if features(feat) ~= 0 % we ignore features that are 0
                 featureParam = featureStart(feat)+features(feat)-1;
                 for state = 1:nStates
                     O = (state == y_s(n)); % feature under observed dist'n
                     E = nodeBel(n,state); % feature under expected dist'n
                     gw(featureParam,state) = gw(featureParam,state) - O + E;
                 end
             end
         end
    end
    
    % Update gradient of BoS and EoS transitions
    for state = 1:nStates
       O = (state == y_s(1));
       E = nodeBel(1,state);
       gv_start(state) = gv_start(state) - O + E;
       O = (state == y_s(end));
       E = nodeBel(end,state);
       gv_end(state) = gv_end(state) - O + E;
    end
    
    % Update gradiet of transitions
    for n = 1:nNodes-1
        for state1 = 1:nStates
            for state2 = 1:nStates
                O = ((state1 == y_s(n)) && (state2 == y_s(n+1)));
                E = edgeBel(state1,state2,n);
                gv(state1,state2) = gv(state1,state2) - O + E;
            end
        end
    end
end

% Make final results
drawnow;
nll = -f;
g = [gw(:);gv_start;gv_end;gv(:)];