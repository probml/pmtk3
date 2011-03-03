function [bel, logZ] = treegmInfer(model)
% Compute marginals on a tree structured graphical model
% using an up-down sweep of belief propagation
%
% model is created by treegmCreate
% and contains nodePot and edgePot
%
% OUTPUT
% nodeBel(:,t)
% logZ = log partition fn


bel = ones(model.Nnodes, model.Nstates);
for n=1:model.Nnodes
  bel(:,n) = model.nodePot(:, model.nodePotNdx(n));
end
[Nstates Nnodes] = size(bel);
Nedges = Nnodes-1;
edgeMsg = ones(Nstates, Nedges);
logZ = 0;

% Collect to root
for e=1:Nedges
  s  = model.edgeorderToRoot(e,1); % src
  t = model.edgeorderToRoo(e,t); % destn
  fprintf('up edge %s, %d->%d\n', e, s, t);
  if model.edgePotNdx(s,t) ~= 0
    edgePot = model.edgePots(:,:,model.edgePotNdx(s,t));
  else
    edgePot = model.edgePots(:,:,model.edgePotNdx(t,s))';
  end
  edgeMsg(:,e) = edgePot * bel(:,s);
  [bel(:,t), Zt] = normalize(bel(:,t) .* edgeMsg(:,e));
  logZ = logZ + log(Zt);
end

% Distribute from root
edgeorderFromRoot = model.edgeorderToRoot(end:-1:1, :);
for e=1:Nedges
  s  = edgeorderFromRoot(e,1); % src
  t = edgeorderFromRoot(e,t); % destn
  fprintf('down edge %s, %d->%d\n', e, s, t);
  if model.edgePotNdx(s,t) ~= 0
    edgePot = model.edgePots(:,:,model.edgePotNdx(s,t));
  else
    edgePot = model.edgePots(:,:,model.edgePotNdx(t,s))';
  end
  edgeMsg(:,e) = edgePot * (bel(:,s) ./ edgeMsg(:,e));
  [bel(:,t)] = normalize(bel(:,t) .* edgeMsg(:,e));
end

end
