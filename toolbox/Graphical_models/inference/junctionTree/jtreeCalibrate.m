function jtree = jtreeCalibrate(jtree)
%% Calibrate a junction tree
% jtree is a struct as returned by e.g. jtreeInit
%%
cliques          = jtree.cliques; 
preOrder         = jtree.preOrder;
postOrder        = jtree.postOrder; 
preOrderChildren = jtree.preOrderChildren; 
postOrderParents = jtree.postOrderParents; 
ncliques         = numel(cliques); 
cliqueTree       = jtree.cliqueTree; 
messages         = cell(ncliques, ncliques);
%% construct separating sets
sepsets  = cell(ncliques);
[is, js] = find(cliqueTree);
for k = 1:numel(is)
    i = is(k);
    j = js(k);
    sepsets{i, j} = intersectPMTK(cliques{i}.domain, cliques{j}.domain);
    sepsets{j, i} = sepsets{i, j};
end
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