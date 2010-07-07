function jtree = jtreeCalibrate(jtree)
%% Calibrate a junction tree
% jtree is a struct as returned by e.g. jtreeInit
%%
cliques          = jtree.cliques; 
sepsets          = jtree.sepsets;
preOrder         = jtree.preOrder;
postOrder        = jtree.postOrder; 
preOrderChildren = jtree.preOrderChildren; 
postOrderParents = jtree.postOrderParents; 
ncliques         = numel(cliques); 
messages         = cell(ncliques, ncliques);
%% collect messaegs
for c = postOrder
    for p = postOrderParents{c}
        message        = tabularFactorMarginalize(cliques{c}, sepsets{c, p});
        cliques{p}     = tabularFactorMultiply(cliques{p}, message);
        messages{p, c} = message;
    end
end
%% distribute messages
for p = preOrder
    for c = preOrderChildren{p}
        childClq       = tabularFactorDivide(cliques{c}, messages{p, c});
        message        = tabularFactorMarginalize(cliques{p}, sepsets{p, c});
        cliques{c}     = tabularFactorMultiply(childClq, message);
        messages{p, c} = message;
    end
end
jtree.cliques = cliques; 
end