function dgm = dgmFit(X, varargin)
%% Fit structure and parameters of a DGM
%
% X is an N*D matrix of binary (0/1) values
%
% We use the L1MB+local search algorithm to find the structure
% This uses L1-penalized logistic regression to fit the model.
% See http://www.cs.ubc.ca/~murphyk/Software/DAGlearn/index.html
%
% We then refit the CPDs usign tables, to simplify subsequent inference

[Ncases,Nnodes] = size(X);
Nstates = nunique(X(:));
if Nstates ~= 2
  error('can currently only handle binary nodes')
end

nodeNames = cellfun(@(d) sprintf('n%d', d), num2cell(1:Nnodes), 'uniformoutput', false);
[nodeNames, maxFanIn, verbose] = process_options(varargin, ...
  'nodeNames', nodeNames, 'maxFanIn', 4, 'verbose', true);

%% Fit structure
search.depnet = depnetFit(X, 'method', 'MI', 'verbose', false, 'nodeNames', nodeNames, ...
  'maxFanIn', maxFanIn); 
legalParents = search.depnet.G;

probRndRestart = 0;
verbose = 1;
nEvals = 250;
penalty = log(Ncases)/2; % BIC
Xcan = canonizeLabels(X); % {1,2}
Xpm = (2*(Xcan-1))-1; % force to {-1,+1}
assert(isequal(unique(Xpm(:))', [-1 +1]))
discrete = 1;
clamped = zeros(Ncases, Nnodes);
[G, search.scores, search.evals] = ...
  DAGsearch(Xpm, nEvals, probRndRestart, penalty, discrete, clamped, legalParents, verbose);


% Check fan-in of each node. If too large,
% can cause problems when fitting tabular CPDs.
for j=1:Nnodes
  npa(j) = numel(parents(G, j));
  if npa(j) > 5
    fprintf('warning: node %d has %d parents\n', j, npa(j));
  end
end


%% Fit params
stateSizes = Nstates*ones(1,Nnodes);
CPDs = mkRndTabularCpds(G, stateSizes);
dgm = dgmCreate(G, CPDs, 'precomputeJtree', true, 'nodenames', nodeNames);
fprintf('treewidth is %d\n', dgm.jtree.treewidth);
dgm = dgmTrain(dgm, 'data', Xcan);

% store info about structure learning process
dgm.npa = npa;
dgm.search = search; 


end
