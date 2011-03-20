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

[Ncases,Nnodes] = size(X); 
[nodeNames, verbose, method, maxFanIn] = process_options(varargin, ...
  'nodeNames', num2cell(1:Nnodes), ...
  'verbose', 1, 'method', 'MI', 'maxFanIn', 4);


X12 = canonizeLabels(X); % force to {1,2}
X01 = X12-1; % force to {0,1}
Xpm = (2*X01)-1; % force to {-1,+1}
clear X % force the code to be clear which version it is using


if nunique(X12(:))==2
  discrete = 1;
else
  error('code currently only works for binary data')
  discrete = 0;
end

assert(isequal(unique(Xpm(:))', [-1 +1]))
assert(isequal(unique(X01(:))', [0 1]))
assert(isequal(unique(X12(:))', [1 2]))


%Xstnd = standardize(X);
model.G = zeros(Nnodes, Nnodes);
model.W = zeros(Nnodes, Nnodes);
model.nodeNames = nodeNames;

switch method
  case 'L1MBold'
    % This uses L1-penalized logistic regression to fit the model.
    % See http://www.cs.ubc.ca/~murphyk/Software/DAGlearn/index.html
    penalty = log(Ncases)/2; % BIC
    clamped = false(Ncases, Nnodes);
    [model.L1MB_AND, model.L1MB_OR] = L1MB(X01, penalty, discrete, clamped, nodeNames, verbose);
    model.G = model.L1MB_OR;
    
  case 'L1MB'
    % We use Mark Schmidt's new code from
    % http://www.cs.ubc.ca/~schmidtm/Software/thesis.html
    % This picks the BIC optimal nbr set along the L1 reg path
    %weightMatrix = DAGlearnG_Select(method,X,ordered,scoreType,SC,A);
    ordered = 0; % unknown ordering
    scoreType = 0; % 0 for BIC, 1 for validation
    allowableEdges = []; % all allowed
    A = []; % not interventional data
    model.G = DAGlearn2_Select('L1', Xpm, ordered, scoreType, allowableEdges, A, verbose);
  
  case 'L1CV' % glmnet is slow, even though written in fortran
    for j=1:Nnodes 
      if verbose >= 2, printf('computing MB for node %d of %d\n', j, Nnodes); end
      notme = setdiff(1:Nnodes, j);
      [model.bestPathModel{j}, model.path{j}] = logregFitPathCv(X01(:,notme), X01(:,j), 'regType', 'L1');
      support = (model.bestPathModel{j}.w);
      nbrs{j} = notme(support);
      model.G(nbrs{j}, j) = 1;
      model.W(notme, j) = model.bestPathModel{j}.w;
    end
    
  case 'ARD' % VB is much faster than CV
    model.A = zeros(Nnodes, Nnodes);
    for j=1:Nnodes
       if verbose >= 2, fprintf('computing MB for node %d of %d\n', j, Nnodes); end
      notme = setdiff(1:Nnodes, j);
      % If you don't standardize, it picks no neighbors
       % preproc = [];
       % [model.CPD{j}] = logregFitBayes(Xstnd(:,notme), X(:,j), 'method', 'vb', ...
       % 'useARD', true, 'preproc', preproc);
      [model.CPD{j}] = logregFitBayes(X01(:,notme), X01(:,j), 'method', 'vb', ...
        'useARD', true);
      support = model.CPD{j}.relevant;
      nbrs{j} = notme(support);
      model.G(nbrs{j}, j) = 1;
      model.W(notme, j) = model.CPD{j}.weights;
      model.A(notme, j) = model.CPD{j}.alpha;
    end
    
    
  case 'MI'
    [mi, nmi, pij, pi] = mutualInfoAllPairsDiscrete(X12); %#ok
     for j=1:Nnodes
      notme = setdiff(1:Nnodes, j);
      scores = nmi(:, j);
      scores(j) = -inf;
      nbrs{j} = topAboveThresh(scores, maxFanIn, 0.1);
      model.G(nbrs{j}, j) = 1;
      model.W(notme, j) = nmi(notme, j);
     end
    
end

if verbose >= 2
  for j=1:Nnodes
    nbrs{j} = neighbors(model.G, j);
    nbrStr = sprintf('%s,', nodeNames{nbrs{j}});
    fprintf('%s depends on %s\n', nodeNames{j}, nbrStr);
  end
end

end

