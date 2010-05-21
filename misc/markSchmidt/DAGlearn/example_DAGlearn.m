data = 'factors';
nSamples = 10000;
nEvals = 2500;
discrete = 0; % Set to 1 for binary data
interv = 1; % Set to 0 for observational data
rand('state',0);
randn('state',0);

% Generate Data
[X,clamped,DAG,nodeNames] = sampleNetwork(data,nSamples,discrete,interv,1);

% Use BIC penalty
penalty = log(nSamples)/2;

% Run DAG-Search
fprintf('Running DAG-Search for 2500 evaluations:\n');
potentialParents = ones(size(X,2));
adj_DS = DAGsearch(X,nEvals,0,penalty,discrete,clamped,potentialParents,1);

fprintf('(paused)\n');
pause;

% Run Order-Search+Lasso
fprintf('Running Order-Search for 2500 evaluations:\n');
adj_OS = OrderSearch(X,nEvals,0,penalty,discrete,clamped,potentialParents);

fprintf('(paused)\n');
pause;

% Run DAG-Search with Sparse Candidate pruning
fprintf('Running Sparse Candidate(k=10) Pruned Dag-Search for 2500 evaluations\n');
SC = SparseCandidate(X,clamped,10);
adj_DS_SC = DAGsearch(X,nEvals,0,penalty,discrete,clamped,SC);

fprintf('(paused)\n');
pause;

% Learn a Dependency network using L1MB
fprintf('Running L1MB\n');
[L1MB_AND,L1MB_OR] = L1MB(X,penalty,discrete,clamped,nodeNames);

fprintf('(paused)\n');
pause;

% Run DAG-Search, restricting edges to those in the Dependency Network
% L1MB_OR
fprintf('Running DAG-Search, restricted to L1MB for 2500 evaluations\n');
adj_DS_L1MB = DAGsearch(X,nEvals,0,penalty,discrete,clamped,L1MB_OR);

err_DS = sum(adj_DS(:)~=DAG(:))
err_OS = sum(adj_OS(:)~=DAG(:))
err_DS_SC = sum(adj_DS_SC(:)~=DAG(:))
err_DS_L1MB = sum(adj_DS_L1MB(:)~=DAG(:))

%drawGraph(adj_DS_L1MB,'labels',nodeNames);
draw_layout(adj_DS_L1MB,nodeNames,ones(27,1))