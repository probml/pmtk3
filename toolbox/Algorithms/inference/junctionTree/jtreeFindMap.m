function map = jtreeFindMap(jtree)
%% Find the mode, (map assignment) using max-product and traceback
% jtree is a struct as returned by e.g. jtreeCreate
%
%%

% This file is from pmtk3.googlecode.com

maximize         = true;
cliques          = jtree.cliques;
preOrder         = jtree.preOrder;
postOrder        = jtree.postOrder;
preOrderChildren = jtree.preOrderChildren;
postOrderParents = jtree.postOrderParents;
ncliques         = numel(cliques);
cliqueTree       = jtree.cliqueTree;
messages         = cell(ncliques, ncliques);
%% construct separating sets
% These can change after jtreeCreate has been called due to slicing, hence we
% calculate them here not in jtreeCreate.
sepsets  = cell(ncliques);
[is, js] = find(cliqueTree);
for k = 1:numel(is)
    i = is(k);
    j = js(k);
    sepsets{i, j} = intersectPMTK(cliques{i}.domain, cliques{j}.domain);
    sepsets{j, i} = sepsets{i, j};
end
%% collect messages
postOrder(end) = []; % remove root
for c = postOrder
    p              = postOrderParents{c}; %postOrderParents(c);
    if ~isempty(p)
      message        = tabularFactorMarginalize(cliques{c}, sepsets{c, p}, maximize);
      cliques{p}     = tabularFactorMultiply(cliques{p}, message);
      cliques{p}     = tabularFactorNormalize(cliques{p});
      messages{p, c} = message;
    end
end
map        = zeros(1, jtree.nvars);
root       = jtree.rootClqNdx;
rootClique = cliques{root};
rootDom    = rootClique.domain;
[cliques{root}, map(rootDom)] = tabularFactorMaximize(rootClique);
%% traceback
for p = preOrder
    for c = preOrderChildren{p}
        childClq               = tabularFactorDivide(cliques{c}, messages{p, c});
        message                = tabularFactorMarginalize(cliques{p}, sepsets{p, c}, maximize);
        cliques{c}             = tabularFactorMultiply(childClq, message);
        cliques{c}             = tabularFactorNormalize(cliques{c});
        messages{p, c}         = message;
        dom                    = cliques{c}.domain;
        [cliques{c}, map(dom)] = tabularFactorMaximize(cliques{c});
    end
end
end



