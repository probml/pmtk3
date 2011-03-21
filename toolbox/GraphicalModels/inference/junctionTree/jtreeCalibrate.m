function [jtree, logZ] = jtreeCalibrate(jtree)
%% Calibrate a junction tree
% jtree is a struct as returned by e.g. jtreeCreate
%
% logZ  - log of the partition sum
%%

% This file is from pmtk3.googlecode.com

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
% KPM 21march 2011
% We need to store Z(i) for each msg that is sent, even if the
% graph is disconnected or only has one node
% We also need to ensure we normalize as we go to prevent underflow.

Z = nan(numel(postOrder), 1);
i = 1;
for c = postOrder
  p                  = postOrderParents{c}; 
  if isempty(p) % I am an isolated node with no parents
    [cliques{c}, Z(i)] = tabularFactorNormalize(cliques{c});
    i=i+1;
  else
    message            = tabularFactorMarginalize(cliques{c}, sepsets{c, p});
    cliques{p}         = tabularFactorMultiply(cliques{p}, message);
    [cliques{p}, Z(i)] = tabularFactorNormalize(cliques{p});
    i = i+1;
    messages{p, c} = message;
  end
end
assert(~any(isnan(Z)))

 %{
  postOrder(end) = []; % remove root as it has no one to send to in this phase
  Z = zeros(numel(postOrder), 1);
  i = 1;
  for c = postOrder
    p                  = postOrderParents{c}; %postOrderParents(c);
    if ~isempty(p)
      message            = tabularFactorMarginalize(cliques{c}, sepsets{c, p});
      cliques{p}         = tabularFactorMultiply(cliques{p}, message);
      [cliques{p}, Z(i)] = tabularFactorNormalize(cliques{p});
      i = i+1;
      messages{p, c} = message;
    end
  end
%}

%% distribute messages
for p = preOrder
    for c = preOrderChildren{p}
      msg = messages{p,c};
      if ~isempty(msg)
        childClq        = tabularFactorDivide(cliques{c}, messages{p, c});
        message         = tabularFactorMarginalize(cliques{p}, sepsets{p, c});
        cliques{c}      = tabularFactorMultiply(childClq, message);
        cliques{c}      = tabularFactorNormalize(cliques{c});
        messages{p, c}  = message;
      end
    end
end
jtree.cliques = cliques;
logZ = sum(log(Z + eps));

end
