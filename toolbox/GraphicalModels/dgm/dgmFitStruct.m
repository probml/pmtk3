function dgm = dgmFitStruct(X, varargin)
%% Fit structure and parameters of a DGM
%
% X is an N*D matrix of binary (0/1) values
%
% We use the L1MB+local search algorithm to find the structure
% This uses L1-penalized logistic regression to fit the model.
% See http://www.cs.ubc.ca/~murphyk/Software/DAGlearn/index.html
%
% We then refit the CPDs usign tables, to simplify subsequent inference.
% If figFolder is non-empty, we store a graphviz figure of the structure.

[Ncases,Nnodes] = size(X); %#ok
Nstates = nunique(X(:));
if Nstates ~= 2
  error('can currently only handle binary nodes')
end

nodeNames = cellfun(@(d) sprintf('n%d', d), num2cell(1:Nnodes), 'uniformoutput', false);

[nodeNames, maxFanInDepNet, maxFanInDag, verbosity, emptyGraph, maxFamEvals, nrestarts, edgeRestrict, ...
  figFolder, maxIter, initMethod] = ...
  process_options(varargin, ...
  'nodeNames', nodeNames, 'maxFanInDepNet', 10, 'maxFanInDag', 4, 'verbosity', 1, ...
  'emptyGraph', false, 'maxFamEvals', 1000, 'nrestarts', 0, 'edgeRestrict', 'MI', 'figFolder', [], ...
  'maxIter', 1000, 'initMethod', 'tree');


X12 = canonizeLabels(X); % {1,2}
X01 = X12-1;
Xpm = (2*X01)-1; % force to {-1,+1}
clear X


%% Fit structure

if emptyGraph
  G = zeros(Nnodes, Nnodes); % indep model
  search = [];
else
  if strcmpi(edgeRestrict, 'none')
    allowableEdges = [];
    search.depnet = [];
  else
    search.depnet = depnetFit(X12, 'method', edgeRestrict, 'verbose', verbosity, 'nodeNames', nodeNames, ...
      'maxFanIn', maxFanInDepNet);
    allowableEdges = search.depnet.G;
  end
  
  % Convert depnet to DAG
  
  %{
  % We use Mark Schmidt's DAGlearn code from
  % http://www.cs.ubc.ca/~murphyk/Software/DAGlearn/
  legalParents = search.depnet.G;
  probRndRestart = 0;
  penalty = log(Ncases)/2; % BIC
  discrete = 1;
  clamped = zeros(Ncases, Nnodes);
  [G, search.scores, search.evals] = ...
    DAGsearch(Xpm, maxFamEvals, probRndRestart, penalty, discrete, clamped, legalParents, verbose);
  %}
  

  % We use Mark Schmidt's new code from
  % http://www.cs.ubc.ca/~schmidtm/Software/thesis.html
  % See demo_DAGlearn2 for example of usage
 
  switch initMethod
    case 'empty'
      initG = [];
    case 'tree'
      [tree] = treegmFit(X12);
      initG = tree.dirTree;
      %initG = tree.adjmat;
  end
  
  interv = [];
  scoreType = 0; % 0 for BIC, 1 for validation
  hashTable = java.util.Hashtable;
  [dag{1}, hashTable, search.scores{1}, search.funEvals{1}] = DAGlearn2_DAGsearch_KPM(Xpm, ...
    scoreType, allowableEdges, ...
    initG, interv, maxFamEvals, hashTable,  verbosity, maxIter, maxFanInDag);
  cost(1) = min(search.scores{1});
  
  for i = 1:nrestarts
    fprintf('dgmFit structure learning: restart %d of %d\n', i, nrestarts);
    % start from  random DAG
    nNodes = Nnodes;
    adjInit = (rand(nNodes).*triu(ones(nNodes),1)) > 0.5;
    perm = randperm(nNodes);
    adjInit = adjInit(perm,perm);
    % Force random DAG to agree with L1MB pruning
    adjInit = adjInit.*(allowableEdges ~= 0);
    
    
    % Run DAG-search, re-using hash table of family evals
    [dag{i+1}, hashTable, search.scores{i+1}, search.funEvals{i+1}] = ...
      DAGlearn2_DAGsearch_KPM(Xpm, scoreType, allowableEdges, adjInit, interv, maxFamEvals, hashTable, ...
      verbosity, maxFanInDag);
    cost(i+1) = min(search.scores{i+1});
  end
  cost
  [~, best] = min(cost);
  G = dag{best};
end


% Check fan-in of each node. If too large,
% can cause problems when fitting tabular CPDs.
for j=1:Nnodes
  npa(j) = numel(parents(G, j));
  if npa(j) > maxFanInDag  % this should not happen!
    fprintf('warning: node %d has %d parents\n', j, npa(j));
  end
end

if ~isempty(figFolder)
  if ~isempty(search) && ~isempty(search.depnet)
    graphviz(search.depnet.G, 'labels', nodeNames, 'directed', 1, ...
      'filename', fullfile(figFolder, 'depnet'));
  end
  graphviz(G, 'labels', nodeNames, 'directed', 1, ...
    'filename', fullfile(figFolder, 'dgmPreTopo'));
end

%% Fit params
%stateSizes = Nstates*ones(1,Nnodes);
%CPDs = mkRndTabularCpds(G, stateSizes);
%dgm = dgmCreate(G, CPDs, 'precomputeJtree', true, 'nodenames', nodeNames);
dgm = dgmCreateTopo(G, 'nodenames', nodeNames);
if ~isempty(figFolder)
  graphviz(dgm.G, 'labels', dgm.nodeNames, 'directed', 1, ...
    'filename', fullfile(figFolder, 'dgmPostTopo'));
end

% Fit parameters - we assume tabular CPDs
%dgm = dgmTrainTopo(dgm, 'data', Xcan);
for i=1:Nnodes
  dom = [parents(dgm.G, i), i];
  dom = dgm.toporder(dom);
  CPD = dgm.CPDs{i};
  CPD = CPD.fitFn(CPD, X12(:, dom));
  dgm.CPDs{i} = CPD;
end

% store info about structure learning process
dgm.npa = npa;
dgm.search = search; 


end
