function [w,v_start,v_end,v] = crfChain_splitWeights(wv,featureStart,nStates)

nFeaturesTotal = featureStart(end)-1;
w = reshape(wv(1:nFeaturesTotal*nStates),nFeaturesTotal,nStates);
v_start = wv(nFeaturesTotal*nStates+1:nFeaturesTotal*nStates+nStates);
v_end = wv(nFeaturesTotal*nStates+nStates+1:nFeaturesTotal*nStates+2*nStates);
v = reshape(wv(nFeaturesTotal*nStates+2*nStates+1:end),nStates,nStates);