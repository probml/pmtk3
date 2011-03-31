%% Group-Sparse Simultaneous Regression
% We will solve min_W ||XW-Y||^2 + lambda * sum_g ||W_g||_inf,
% where we use the 'groups' g to encourage that we select variables that
% are relevant across the output variables
%
% We solve this non-differentiable problem by transforming it into the
% equivalent problem: 
% min_w ||XW-Y||^2 + lambda * sum_g alpha_g, s.t. forall_g alpha_g >= ||W_g||_inf
%
% Using group-sparsity to select variables that are relevant across regression
% tasks is described in:
% Turlach, Venables, and Wright.  <http://pages.cs.wisc.edu/~swright/papers/tvw.pdf Simultaneous Variable Selection>.  Technometrics
% (2005).
%
% The auxiliary variable formulation is described in:
% Schmidt, Murphy, Fung, and Rosales.  <http://www.cs.ubc.ca/~murphyk/Papers/cvpr08.pdf Structure Learning in Random Field for
% Heart Motion Abnormality Detection>.  CVPR (2008).
% 
% Computing the projection in the auxiliary variable formulation can be
% done in O(n log n), this is described in the
% <http://www.cs.ubc.ca/~murphyk/Software/L1CRF/cvpr08_extra.pdf addendum>
% of the above paper:

% Generate synthetic data
nInstances = 10;
nVars = 4;
nOutputs = 100;
X = randn(nInstances,nVars);
W = diag(rand(nVars,1) > .75)*randn(nVars,nOutputs);
Y = X*W + randn(nInstances,nOutputs);

% Initial guess of parameters
W_groupSparse = zeros(nVars,nOutputs);

% Set up Objective Function
funObj = @(W)SimultaneousSquaredError(W,X,Y);

% Set up Groups
groups = repmat([1:nVars]',1,nOutputs);
groups = groups(:);
nGroups = max(groups);

% Initialize auxiliary variables that will bound norm
lambda = 250;
alpha = zeros(nGroups,1);
penalizedFunObj = @(W)auxGroupLoss(W,groups,lambda,funObj);

% Set up L_1,inf Projection Function
[groupStart,groupPtr] = groupl1_makeGroupPointers(groups);
funProj = @(W)auxGroupL2Project(W,nVars*nOutputs,groupStart,groupPtr);

% Solve with PQN
fprintf('\nComputing group-sparse simultaneous regression parameters...\n');
Walpha = minConF_SPG(penalizedFunObj,[W_groupSparse(:);alpha],funProj);

% Extract parameters from augmented vector
W_groupSparse(:) = Walpha(1:nVars*nOutputs);
W_groupSparse(abs(W_groupSparse) < 1e-4) = 0;

break
subplot(1,2,1);
imagesc(W_groupSparse~=0);colormap gray
title('Sparsity Pattern');
ylabel('variable');
xlabel('output target');
subplot(1,2,2);
imagesc(W_groupSparse);colormap gray
title('Variable weights');
ylabel('variable');
xlabel('output target');

% Check selected variables
for s = 1:nVars
   fprintf('Number of tasks where variable %d was selected: %d (of %d)\n',s,nnz(W_groupSparse(s,:)),nOutputs); 
end
fprintf('Total number of variables selected: %d (of %d)\n',nnz(sum(W_groupSparse,2)),nVars);
pause


