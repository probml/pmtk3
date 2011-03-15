function model = depnetFit(X, varargin)
%% Fit structure of a dependency network
%
% Input:
% X is an N*D matrix of binary (0/1) or {1,2}
% Optional args
% 'method' - {'ARD', 'MI', 'L1CV', 'L1MB'}
% maxFanIn - only used by MI
%
% Output:
% model.G(s,t) = 1 if s depends on t (sparse)
% model.W(s,t) is some measure of the edge strength (dense)

X = canonizeLabels(X)-1; % force to {0,1}
[Ncases,Nnodes] = size(X); 
[nodeNames, verbose, method, maxFanIn] = process_options(varargin, ...
  'nodeNames', num2cell(1:Nnodes), ...
  'verbose', true, 'method', 'MI', 'maxFanIn', 4);

if isequal(unique(X(:))', [0 1])
  discrete = 1;
else
  error('code currentl onyl works for binary data')
  discrete = 0;
end

%Xstnd = standardize(X);
model.G = zeros(Nnodes, Nnodes);
model.W = zeros(Nnodes, Nnodes);
model.nodeNames = nodeNames;

switch method
  case 'L1MB'
    % We use the L1MB+local search algorithm to find the structure
    % This uses L1-penalized logistic regression to fit the model.
    % See http://www.cs.ubc.ca/~murphyk/Software/DAGlearn/index.html
    %
    penalty = log(Ncases)/2; % BIC
    clamped = false(Ncases, Nnodes);
    [model.L1MB_AND, model.L1MB_OR] = L1MB(X, penalty, discrete, clamped, nodeNames, verbose);
    model.G = model.L1MB_OR;
    
  case 'L1CV' % glmnet is slow, even though written in fortran
    for j=1:Nnodes 
      if verbose, printf('computing MB for node %d of %d\n', j, Nnodes); end
      notme = setdiff(1:Nnodes, j);
      [model.bestPathModel{j}, model.path{j}] = logregFitPathCv(X(:,notme), X(:,j), 'regType', 'L1');
      support = (model.bestPathModel{j}.w);
      nbrs{j} = notme(support);
      model.G(j, nbrs{j}) = 1;
      model.W(j, notme) = model.bestPathModel{j}.w;
    end
    
  case 'ARD' % VB is much faster than CV
    model.A = zeros(Nnodes, Nnodes);
    for j=1:Nnodes
       if verbose, printf('computing MB for node %d of %d\n', j, Nnodes); end
      notme = setdiff(1:Nnodes, j);
      % If you don't standardize, it picks no neighbors
       % preproc = [];
       % [model.CPD{j}] = logregFitBayes(Xstnd(:,notme), X(:,j), 'method', 'vb', ...
       % 'useARD', true, 'preproc', preproc);
      [model.CPD{j}] = logregFitBayes(X(:,notme), X(:,j), 'method', 'vb', ...
        'useARD', true);
      support = model.CPD{j}.relevant;
      nbrs{j} = notme(support);
      model.G(j, nbrs{j}) = 1;
      model.W(j, notme) = model.CPD{j}.weights;
      model.A(j, notme) = model.CPD{j}.alpha;
    end
    
    
  case 'MI'
    [mi, nmi, pij, pi] = mutualInfoAllPairsDiscrete(X, unique(X(:))); %#ok
     for j=1:Nnodes
      notme = setdiff(1:Nnodes, j);
      scores = nmi(j, :);
      scores(j) = -inf;
      [scores2, perm] = sort(scores, 'descend');
      ndx = (scores2 > 0.2);
      perm = perm(ndx);
      nsupport = min(numel(perm), maxFanIn);
      nbrs{j} = perm(1:nsupport);
      model.G(j, nbrs{j}) = 1;
      model.W(j, notme) = nmi(j, notme);
    end
    
    
end

if ~verbose, return; end
for j=1:Nnodes
  nbrs{j} = neighbors(model.G, j);
  nbrStr = sprintf('%s,', nodeNames{nbrs{j}});
  fprintf('%s depends on %s\n', nodeNames{j}, nbrStr);
end

end

