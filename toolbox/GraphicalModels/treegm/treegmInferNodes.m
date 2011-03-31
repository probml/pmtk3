function [logZ, nodeBel,  edgeBel] = treegmInferNodes(model, localFeatures, softev)
% Compute marginals on a tree structured graphical model
% using an up-down sweep of belief propagation
%
% INPUT
% model is created by treegmCreate 
% localFeatures is an optional D*Nnodes matrix containing local evidence 
% If present, we evaluate the local likelihood using model.localCPDs{t}
% and add this in to the node beliefs.
% Or we can pass in softev(k,t) directly (allows batch computation)
%
% OUTPUT
% logZ = log partition fn
% nodeBel(:,t)
% edgeBel(:,:,e) where model.edges(e,:)=[s t]

if nargin < 2, localFeatures = []; end
if nargin < 3, softev = []; end
logZ = 0;


nodePots = ones(model.Nstates, model.Nnodes);
for n=1:model.Nnodes
  nodePots(:,n) = model.nodePot(:, model.nodePotNdx(n));
end
assert(~any(isnan(nodePots(:))))
if ~isempty(localFeatures)
  softev = localEvToSoftEv(model.obsmodel, localFeatures);
end
if ~isempty(softev)
  assert(~any(isnan(softev(:))))
  ndx = (softev==0);
  softev(ndx) = eps; % replace zeros with epsilon
  nodePots = nodePots .* softev;
end


nodeBel = nodePots;


[Nstates Nnodes] = size(nodeBel);
Nedges = size(model.edges, 1); % Nnodes-1;
edgeMsgUp = ones(Nstates, Nedges);
edgeMsgDown = ones(Nstates, Nedges);
% The size of a message is the size of the recipient


%% Collect to root
for e=1:Nedges
  s  = model.edges(e,1); % src
  t = model.edges(e,2); % destn
  %fprintf('up edge %d, %d->%d\n', e, s, t);
  if model.edgePotNdx(s,t) ~= 0
    edgePot = model.edgePot(:,:,model.edgePotNdx(s,t))';
  else
    edgePot = model.edgePot(:,:,model.edgePotNdx(t,s));
  end
  edgeMsgUp(:,e) = edgePot * nodeBel(:,s);
  [nodeBel(:,t), Zt] = normalize(nodeBel(:,t) .* edgeMsgUp(:,e));
  assert(~any(isnan(nodeBel(:,s))))
  assert(~any(isnan(nodeBel(:,t))))
  assert(~all(nodeBel(:,s)==0))
  assert(~all(nodeBel(:,t)==0))
  logZ = logZ + log(Zt);
end

% Normalize all isolated root nodes
for n=model.roots(:)'
  [nodeBel(:,n), Zn] = normalize(nodeBel(:,n));
  logZ = logZ + log(Zn);
end

%% Distribute from root
for e=Nedges:-1:1 
  s  = model.edges(e,2); % src
  t = model.edges(e,1); % destn
  %fprintf('down edge %d, %d->%d\n', e, s, t);
  if model.edgePotNdx(s,t) ~= 0
    edgePot = model.edgePot(:,:,model.edgePotNdx(s,t))';
  else
    edgePot = model.edgePot(:,:,model.edgePotNdx(t,s));
  end
  % We divide out the message that was sent in to s (from t)
  % to get the product of all-but-one messages
  edgeMsgDown(:,e) = edgePot * (nodeBel(:,s) ./ edgeMsgUp(:,e));
  [nodeBel(:,t)] = normalize(nodeBel(:,t) .* edgeMsgDown(:,e));
  assert(~any(isnan(nodeBel(:,t))))
end


%% Compute edge marginals if requested
if nargout < 3, return; end
edgeBel = ones(model.Nstates, model.Nstates, Nedges);
for e=1:Nedges
  s  = model.edges(e,1); % src
  t = model.edges(e,2); % destn
  bels = nodeBel(:,s) ./ edgeMsgDown(:,e);
  belt = nodeBel(:,t) ./ edgeMsgUp(:,e);
  % KPM 3/31/11 added transpose to edgeBel(:,:,e)=(...)'
  % to make treeInferDemo work after changing
  % from treeMsgOrder to treeMsgOrderPmtk.
  % Not sure why this is needed.
  if model.edgePotNdx(s,t) ~= 0
    edgePot = model.edgePot(:,:,model.edgePotNdx(s,t));
    edgeBel(:,:,e) = normalize(edgePot .* (bels * belt'))';
  else
    edgePot = model.edgePot(:,:,model.edgePotNdx(t,s));
    edgeBel(:,:,e) = normalize(edgePot .* (belt * bels'))';
  end
end

%{
%% Compute logZ
edgePots = zeros(Nstates, Nstates, Nedges);
for e=1:Nedges
  s  = model.edges(e,1); % src
  t = model.edges(e,2); % destn
  if model.edgePotNdx(s,t) ~= 0
    edgePots(:,:,e) = model.edgePot(:,:,model.edgePotNdx(s,t));
  else
    edgePots(:,:,e) = model.edgePot(:,:,model.edgePotNdx(t,s));
  end
end
B = betheFreeEnergy(model.adjmat, nodePots, edgePots, nodeBel, edgeBel);
logZ = -B;
%}

end

