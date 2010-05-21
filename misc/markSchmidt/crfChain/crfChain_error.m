function [err] = crfChain_error(w,v_start,v_end,v,X,y,nStates,nFeatures,featureStart,sentences,type,useMex)

wv = [w(:);v_start(:);v_end(:);v(:)];

nSentences = size(sentences,1);

err = 0;
Z = 0;
for s = 1:nSentences
    y_s = y(sentences(s,1):sentences(s,2));
    if useMex
        [nodePot,edgePot] = crfChain_makePotentialsC(X,wv,nFeatures,featureStart,sentences,s,nStates);
    else
    [nodePot,edgePot]=crfChain_makePotentials(X,w,v_start,v_end,v,nFeatures,featureStart,sentences,s);
    end
    if strcmp(type,'infer')
        if useMex
        [nodeBel,edgeBel,logZ] = crfChain_inferC(nodePot,edgePot);
        else
        [nodeBel,edgeBel,logZ] = crfChain_infer(nodePot,edgePot);
        end
        [junk yhat] = max(nodeBel,[],2);
    else
        yhat = crfChain_decode(nodePot,edgePot);
    end
        
    err = err+sum(yhat~=y_s);
    Z = Z+length(y_s);
end
err=err/Z;