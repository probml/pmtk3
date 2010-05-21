clear all
close all
f = 1;

%% Linear Regression on the Simplex
% We will solve min_w ||Xw-y||^2, s.t. w >= 0, sum(w)=1
%
% Projection onto the simplex can be computed in O(n log n), this is
% described in (among other places):
% Michelot.  <http://www.springerlink.com/content/q1636371674m36p1 A Finite Algorithm for Finding the Projection of a
% Point onto the Canonical Simplex of R^n>.  Journal of Optimization Theory
% and Applications (1986).

% Generate Syntehtic Data
nInstances = 50;
nVars = 10;
X = randn(nInstances,nVars);
w = rand(nVars,1).*(rand(nVars,1) > .5);
y = X*w + randn(nInstances,1);

% Initial guess of parameters
wSimplex = zeros(nVars,1);

% Set up Objective Function
funObj = @(w)SquaredError(w,X,y);

% Set up Simplex Projection Function
funProj = @(w)projectSimplex(w);

% Solve with PQN
fprintf('\nComputing optimal linear regression parameters on the simplex...\n');
wSimplex = minConf_PQN(funObj,wSimplex,funProj);

% Check if variable lie in simplex
wSimplex'
fprintf('Min value of wSimplex: %.3f\n',min(wSimplex));
fprintf('Max value of wSimplex: %.3f\n',max(wSimplex));
fprintf('Sum of wSimplex: %.3f\n',sum(wSimplex));
pause

%% Lasso regression
% We will solve min_w ||Xw-y||^2 s.t. sum_i |w_i| <= tau
%
% Projection onto the L1-Ball can be computed in O(n), see:
% Duchi, Shalev-Schwartz, Singer, and Chandra.  <http://icml2008.cs.helsinki.fi/papers/361.pdf Efficient Projections onto
% the L1-Ball for Learning in High Dimensions>.  ICML (2008).

% Generate Syntehtic Data
nInstances = 500;
nVars = 50;
X = randn(nInstances,nVars);
w = randn(nVars,1).*(rand(nVars,1) > .5);
y = X*w + randn(nInstances,1);

% Initial guess of parameters
wL1 = zeros(nVars,1);

% Set up Objective Function
funObj = @(w)SquaredError(w,X,y);

% Set up L1-Ball Projection
tau = 2;
funProj = @(w)sign(w).*projectRandom2C(abs(w),tau);

% Solve with PQN
fprintf('\nComputing optimal Lasso parameters...\n');
wL1 = minConf_PQN(funObj,wL1,funProj);
wL1(abs(wL1) < 1e-4) = 0;

% Check sparsity of solution
wL1'
fprintf('Number of non-zero variables in solution: %d (of %d)\n',nnz(wL1),length(wL1));

figure(f);f=f+1;
subplot(1,2,1);
imagesc(wL1);colormap gray;
title(' Weights');
subplot(1,2,2);
imagesc(wL1~=0);colormap gray;
title('Sparsity of wL1');
pause


%% Lasso with Complex Variables
% We will solve min_w ||Xz-y||^2, s.t. sum_i |z_i| <= tau,
% where z and y are complex, and |z| represents the complex modulus
% 
% Efficient projection onto this complex L1-Ball is described in:
% van den Berg and Friedlander.  <http://www.optimization-online.org/DB_FILE/2008/01/1889.pdf Probing the Pareto Frontier for Basis
% Pursuit Solutions>.  SIAM Journal of Scientific Computing (2008).
%
% The calculation of the projection can be reduced from the O(n log n) 
% required in the above to O(n) by using a linear-time median finding
% algorithm

% Generate Syntehtic Data
nInstances = 500;
nVars = 50;
X = randn(nInstances,nVars);
z = complex(randn(nVars,1),randn(nVars,1)).*(rand(nVars,1) > .5);
y = X*z;

% Initial guess of parameters
zReal = zeros(nVars,1);
zImag = zeros(nVars,1);

% Set up Objective Function
funObj = @(zRealImag)SquaredError(zRealImag,[X zeros(nInstances,nVars);zeros(nInstances,nVars) X],[real(y);imag(y)]);

% Set up Complex L1-Ball Projection
tau = 2;
funProj = @(zRealImag)complexProject(zRealImag,tau);

% Solve with PQN
fprintf('\nComputing optimal Lasso parameters...\n');
zRealImag = minConf_PQN(funObj,[zReal;zImag],funProj);
zReal = zRealImag(1:nVars);
zImag = zRealImag(nVars+1:end);
zL1 = complex(zReal,zImag);
zL1(abs(zL1) < 1e-4) = 0;

figure(f);f=f+1;
subplot(1,3,1);
imagesc(zReal);colormap gray;
title('Real Weights');
subplot(1,3,2);
imagesc(zImag);colormap gray;
title('Imaginary Weights');
subplot(1,3,3);
imagesc(zL1~=0);colormap gray;
title('Sparsity of zL1');

% Check sparsity of solution
zL1'
fprintf('Number of non-zero variables in solution: %d (of %d)\n',nnz(zL1),length(zL1));
pause

%% Group-Sparse Linear Regression with Categorical Features
% We will solve min_w ||Xw-y||^2, s.t. sum_g ||w_g||_inf <= tau,
% where X uses binary indicator variables to represent a set of categorical
% features, and we use the 'groups' g to encourage sparsity in terms of the
% original categorical variables
%
% Using the L_1,inf mixed-norm for group-sparsity is described in:
% Turlach, Venables, and Wright.  <http://pages.cs.wisc.edu/~swright/papers/tvw.pdf Simultaneous Variable Selection>.  Technometrics
% (2005).
%
% Using group sparsity to select for categorical variables encoded with
% indicator variables is described in:
% Yuan and Lin.  <http://www.stat.wisc.edu/Department/techreports/tr1095.pdf Model Selection and Estimation in Regression with Grouped
% Variables>.  JRSSB (2006).
%
% Projection onto the L_1,inf mixed-norm ball can be computed in O(n log n), 
% this is described in:
% Quattoni, Carreras, Collins, and Darell.  <http://www.cs.mcgill.ca/~icml2009/papers/475.pdf An Efficient Projection for
% l_{1,\infty} Regularization>.  ICML (2009).

% Generate categorical features
nInstances = 100;
nStates = [3 3 3 3 5 4 5 5 6 10 3]; % Number of discrete states for each categorical feature
X = zeros(nInstances,length(nStates));
offset = 0;
for i = 1:nInstances
    for s = 1:length(nStates)
        prob_s = rand(nStates(s),1);
        prob_s = prob_s/sum(prob_s);
        X(i,s) = sampleDiscrete(prob_s);
    end
end

% Make indicator variable encoding of categorical features
X_ind = zeros(nInstances,sum(nStates));
clear w
for s = 1:length(nStates)
    for i = 1:nInstances
        X_ind(i,offset+X(i,s)) = 1;
    end
    w(offset+1:offset+nStates(s),1) = (rand > .75)*randn(nStates(s),1);
    offset = offset+nStates(s);
end
y = X_ind*w + randn(nInstances,1);

% Initial guess of parameters
w_ind = zeros(sum(nStates),1);

% Set up Objective Function
funObj = @(w)SquaredError(w,X_ind,y);

% Set up groups
offset = 0;
groups = zeros(size(w_ind));
for s = 1:length(nStates)
    groups(offset+1:offset+nStates(s),1) = s;
    offset = offset+nStates(s);
end

% Set up L_1,inf Projection Function
tau = .05;
funProj = @(w)groupLinfProj(w,tau,groups);

% Solve with PQN
fprintf('\nComputing Group-Sparse Linear Regression with Categorical Features Parameters...\n');
w_ind = minConf_PQN(funObj,w_ind,funProj);
w_ind(abs(w_ind) < 1e-4) = 0;

% Check selected variables
w_ind'
for s = 1:length(nStates)
   fprintf('Number of non-zero variables associated with categorical variable %d: %d (of %d)\n',s,nnz(w_ind(groups==s)),sum(groups==s)); 
end
fprintf('Total number of categorical variables selected: %d (of %d)\n',nnz(accumarray(groups,abs(w_ind))),length(nStates));
pause

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
% of the above paper.

% Generate synthetic data
nInstances = 100;
nVars = 25;
nOutputs = 10;
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
funProj = @(W)auxGroupLinfProject(W,nVars*nOutputs,groupStart,groupPtr);

% Solve with PQN
fprintf('\nComputing group-sparse simultaneous regression parameters...\n');
Walpha = minConf_PQN(penalizedFunObj,[W_groupSparse(:);alpha],funProj);

% Extract parameters from augmented vector
W_groupSparse(:) = Walpha(1:nVars*nOutputs);
W_groupSparse(abs(W_groupSparse) < 1e-4) = 0;

figure(f);f=f+1;
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

%% Group-Sparse Multinomial Logistic Regression
% We will solve min_W nll(W,X,y) + lambda * sum_g ||W_g||_2,
% where nll(W,X,y) is the negative log-likelihood in multinomial logistic
% regression, and
% where we use the 'groups' g to encourage sparsity in terms of the
% original input variables
%
% We solve this non-differentiable problem by transforming it into the
% equivalent problem: 
% min_W nll(W,X,y) + lambda * sum_g alpha_g, s.t. forall_g alpha_g >=
% ||W_g||_2
%
% Note: the bias variables are assigned to group '0', which is not
% penalized
%
% Using the L_1,2 mixed-norm for group-sparsity is described in:
% Bakin.  Adaptive Regression and Model Selection in Data Mining Problems.
% PhD Thesis Australian National University (1999)
%
% Using group-sparsity to select the original input variables in 
% multinomial classification is described in:
% Obozinski, Taskar, and Jordan.  <http://www.stat.berkeley.edu/tech-reports/743.pdf Joint covariate selection for grouped
% classification>.  UC Berkeley TR (2007).
% 
% The auxiliary variable formulation is described in the addendum of:
% Schmidt, Murphy, Fung, and Rosales.  <http://www.cs.ubc.ca/~murphyk/Papers/cvpr08.pdf Structure Learning in Random Field for
% Heart Motion Abnormality Detection>.  CVPR (2008).
%
% Computing the projection in the auxiliary variable formulation can be
% done in O(n), this is Exercise 8.3(c) of:
% Boyd and Vandenberghe.  <http://www.stanford.edu/~boyd/cvxbook/bv_cvxbook.pdf Convex Optimization>.  Cambridge University Press
% (2004).

% Generate synthetic data
nInstances = 100;
nVars = 25;
nClasses = 6;
X = [ones(nInstances,1) randn(nInstances,nVars-1)];
W = diag(rand(nVars,1) > .75)*randn(nVars,nClasses);
[junk y] = max(X*W + randn(nInstances,nClasses),[],2);

% Initial guess of parameters
W_groupSparse = zeros(nVars,nClasses-1);

% Set up Objective Function
funObj = @(W)SoftmaxLoss2(W,X,y,nClasses);

% Set up Groups (don't penalized bias)
groups = [zeros(1,nClasses-1);repmat([1:nVars-1]',1,nClasses-1)];
groups = groups(:);
nGroups = max(groups);

% Initialize auxiliary variables that will bound norm
lambda = 10;
alpha = zeros(nGroups,1);
penalizedFunObj = @(W)auxGroupLoss(W,groups,lambda,funObj);

% Set up L_1,inf Projection Function
[groupStart,groupPtr] = groupl1_makeGroupPointers(groups);
funProj = @(W)auxGroupL2Project(W,nVars*(nClasses-1),groupStart,groupPtr);

% Solve with PQN
fprintf('\nComputing group-sparse multinomial logistic regression parameters...\n');
Walpha = minConf_PQN(penalizedFunObj,[W_groupSparse(:);alpha],funProj);

% Extract parameters from augmented vector
W_groupSparse(:) = Walpha(1:nVars*(nClasses-1));
W_groupSparse(abs(W_groupSparse) < 1e-4) = 0;

figure(f);f=f+1;
subplot(1,2,1);
imagesc(W_groupSparse~=0);colormap gray
title('Sparsity Pattern');
ylabel('variable');
xlabel('class label');
subplot(1,2,2);
imagesc(W_groupSparse);colormap gray
title('Variable weights');
ylabel('variable');
xlabel('class label');

% Check selected variables
fprintf('Number of classes where bias variable was selected: %d (of %d)\n',nnz(W_groupSparse(1,:)),nClasses-1); 
for s = 2:nVars
   fprintf('Number of classes where variable %d was selected: %d (of %d)\n',s,nnz(W_groupSparse(s,:)),nClasses-1); 
end
fprintf('Total number of variables selected: %d (of %d)\n',nnz(sum(W_groupSparse(2:end,:),2)),nVars);
pause

%% Group-Sparse Multi-Task Classification
% We will solve min_W nll(W,X,Y), s.t. sum_g ||W_g||_2 <= tau,
% where nll(W,X,Y) is the negative log-likelihood in a simultaneous binary logistic
% regression model, and
% where we use the 'groups' g to encourage that we select variables that
% are relevant across the binary classification tasks
%
% Note: the bias variables are assigned to group '0', which is not
% penalized
%
% Using group-sparsity to select variables that are relevant across
% classification tasks is described in:
% Obozinski, Taskar, and Jordan.  <http://www.stat.berkeley.edu/tech-reports/743.pdf Joint covariate selection for grouped
% classification>.  UC Berkeley TR (2007).
%
% Projection onto the L_1,2 mixed-norm ball can be computed in O(n), 
% this is described in:
% van den Berg, Schmidt, Friedlander, and Murphy.  <http://www.optimization-online.org/DB_HTML/2008/07/2056.html Group Sparsity via
% Linear-Time Projection>.  UBC TR (2008).

% Generate synthetic data
nInstances = 100;
nVars = 25;
nOutputs = 10;
X = [ones(nInstances,1) randn(nInstances,nVars-1)];
W = diag(rand(nVars,1) > .75)*randn(nVars,nOutputs);
Y = X*W + randn(nInstances,nOutputs);

% Initial guess of parameters
W_groupSparse = zeros(nVars,nOutputs);

% Set up Objective Function
funObj = @(W)SimultaneousLogisticLoss(W,X,Y);

% Set up Groups (don't penalized bias)
groups = [zeros(1,nOutputs);repmat([1:nVars-1]',1,nOutputs)];
groups = groups(:);
nGroups = max(groups);

% Set up L_1,2 Projection Function
tau = .5;
funProj = @(W)groupL2Proj(W,tau,groups);

% Solve with PQN
fprintf('\nComputing Group-Sparse Multi-Task Classification Parameters...\n');
W_groupSparse(:) = minConf_PQN(funObj,W_groupSparse(:),funProj);
W_groupSparse(abs(W_groupSparse) < 1e-4) = 0;

figure(f);f=f+1;
subplot(1,2,1);
imagesc(W_groupSparse~=0);colormap gray
title('Sparsity Pattern');
ylabel('variable');
xlabel('task');
subplot(1,2,2);
imagesc(W_groupSparse);colormap gray
title('Variable weights');
ylabel('variable');
xlabel('task');

% Check selected variables
fprintf('Number of classes where bias variable was selected: %d (of %d)\n',nnz(W_groupSparse(1,:)),nOutputs); 
for s = 2:nVars
   fprintf('Number of tasks where variable %d was selected: %d (of %d)\n',s,nnz(W_groupSparse(s,:)),nOutputs); 
end
fprintf('Total number of variables selected: %d (of %d)\n',nnz(sum(W_groupSparse(2:end,:),2)),nVars);
pause

%% L_1,inf Blockwise-Sparse Graphical Lasso
% We will solve nll(K,S) + sum_b lambda_b||K_b||_inf,
% where nll(K,S) is the Gaussian negative log-likelihood and
% the 'blocks' b encourage blockwise sparsity in the matrix between
% 'groups' g
%
% We solve this non-differentiable problem by solving the convex dual
% problem: min_W -logdet(S + W), s.t. sum_b ||W_b||_inf <= lambda
%
% Using the L_1,inf mixed-norm to encourage blockwise sparsity, and the
% derivation of the convex dual problem are described in:
% Duchi, Gould, and Koller.  <http://www.cs.berkeley.edu/~jduchi/projects/jd_sg_dk_sparsecovar.pdf Projected Subgradient Methods for Learning
% Sparse Gaussians>.  UAI (2008).

% Generate a set of variable groups
nNodes = 100;
nGroups = 10;
groups = repmat(1:nNodes/nGroups,nGroups,1);
groups = groups(:);

% Generate a positive-definite matrix that is sparse within groups, and
% blockwise sparse between groups
betweenSparsity = (rand(nGroups) > .75).*triu(ones(nGroups),1);
adj = triu(randn(nNodes).*(rand(nNodes) > .1),1);
for g1 = 1:nGroups
    for g2 = g1+1:nGroups
        if betweenSparsity(g1,g2) == 0
           adj(groups==g1,groups==g2) = 0; 
        end
    end
end
adj = adj+adj';
tau = 1;
invCov = adj + tau*eye(nNodes);
while ~ispd(invCov)
    tau = tau*2;
    invCov = adj + tau*eye(nNodes);
end
mu = randn(nNodes,1);

% Sample from the GGM
nInstances = 500;
C = inv(invCov);
R = chol(C)';
X = zeros(nInstances,nNodes);
for i = 1:nInstances
   X(i,:) = (mu + R*randn(nNodes,1))'; 
end
    
% Center and Standardize
X = standardizeCols(X);

% Compute empirical covariance
S = cov(X);

% Set up Objective Function
funObj = @(K)logdetFunction(K,S);

% Set up Weights on penalty (multiply lambda by number of elements in
% block)
lambda = 10/nInstances;
for g = 1:nGroups
    nBlockElements(g,1) = sum(groups==g);
end
lambdaBlock = setdiag(lambda * nBlockElements*nBlockElements',lambda);

lambdaBlock = lambdaBlock(:);
funProj = @(K)projectLinf1(K,nNodes,nBlockElements,lambdaBlock);

% Initial guess of parameters
W = lambda*eye(nNodes);

% Solve with PQN
fprintf('\nComputing L_1,inf Blockwise-Sparse Graphical Lasso Parameters...\n');
W(:) = minConf_PQN(funObj,W(:),funProj);
K = inv(S+W);

figure(f);f=f+1;
imagesc(abs(K))
pause

%% L_1,2 Blockwise-Sparse Graphical Lasso
% Same as the above, but we use the L_1,2 group-norm instead of L_1,inf, as
% discussed in the PQN paper.

lambdaBlock = lambdaBlock/5;
funProj = @(K)projectLinf2(K,nNodes,nBlockElements,lambdaBlock);

% Initial guess of parameters
W = lambda*eye(nNodes);

% Solve with PQN
fprintf('\nComputing L_1,2 Blockwise-Sparse Graphical Lasso Parameters...\n');
W(:) = minConf_PQN(funObj,W(:),funProj);
K = inv(S+W);

figure(f);f=f+1;
imagesc(abs(K))
pause

%% Linear Regression with the Over-Lasso
% We will solve the "Over-Lasso" problem:
% min_w ||Xw-Y||^2 + lambda * sum_g ||v_g||, s.t. sum v_i = w_i
% This is similar to the 'group' lasso' problems above, but in this case
% each variable is represented as a linear combination of 'sub' variables 'v',
% and these sub variables can belong to different groups.
% This leads to sparse solutions that tend to be unions of groups
%
% We solve this problem by eliminating w, and using auxiliary variables to
% make the problem differentiable
%
% The "Over-Lasso" regularizer and the method of eliminating w are
% described in:
% Jacob, Obozinski, and Vert.  <http://www.cs.mcgill.ca/~icml2009/papers/471.pdf Group Lasso with Overlap and Graph Lasso>.
% ICML (2009).

% Make variable-group membership matrix
nVars = 100;
nGroups = 10;
varGroupMatrix = zeros(nVars,nGroups);
offset = 0;
for g = 1:nGroups
   varGroupMatrix(offset+1:min(offset+2*nVars/nGroups,nVars),g) = 1;
   offset = offset + nVars/nGroups;
end

% Generate synthetic data
nInstances = 250;
X = randn(nInstances,nVars);
w = zeros(nVars,1);
for g = 1:nGroups
    % Make some groups relevant
    if rand > .66
       w(varGroupMatrix(:,g)==1) = randn(sum(varGroupMatrix(:,g)==1),1);
    end
end
y = X*w + randn(nInstances,1);

% Initial guess of parameters
vInd = find(varGroupMatrix==1);
nSubVars = length(vInd);
v = zeros(nSubVars,1);

% Set up Objective Function
lambda = 2000;
alpha = zeros(nGroups,1);
funObj = @(w)SquaredError(w,X,y);
penalizedFunObj = @(vAlpha)overLassoLoss(vAlpha,varGroupMatrix,lambda,funObj);

% Set up sub-variable groups
subGroups = zeros(nSubVars,1);
offset = 0;
for g = 1:nGroups
    subGroupLength = sum(varGroupMatrix(:,g));
    subGroups(offset+1:offset+subGroupLength) = g;
    offset = offset+subGroupLength;
end

% Set up L_1,inf Projection Function
[groupStart,groupPtr] = groupl1_makeGroupPointers(subGroups);
funProj = @(vAlpha)auxGroupL2Project(vAlpha,nSubVars,groupStart,groupPtr);

% Solve with PQN
fprintf('\nComputing over-lasso regularized linear regression parameters...\n');
vAlpha = minConf_PQN(penalizedFunObj,[v;alpha],funProj);

% Extract parameters from augmented vector
v = vAlpha(1:nSubVars);
v(abs(v) < 1e-4) = 0;

% Form sub-weight matrix vFull, and weight vector w
vFull = zeros(nVars,nGroups);
vFull(vInd) = v;
w = sum(vFull,2);

figure(f);f=f+1;
subplot(1,3,1);
imagesc(varGroupMatrix);
ylabel('variable');
xlabel('group');
title('Over-Lasso Variable-Group matrix');
subplot(1,3,2);
imagesc(vFull);colormap gray
title('Sub-Weights');
subplot(1,3,3);
imagesc(w~=0);
title('Weights Sparsity Pattern');

for g = 1:nGroups
   fprintf('Number of variables selected from group %d: %d (of %d)\n',g,nnz(w(varGroupMatrix(:,g)==1)),sum(varGroupMatrix(:,g))); 
end
fprintf('\n');
for g = 1:nGroups-1
    overlapInd = find(varGroupMatrix(:,g)==1 & varGroupMatrix(:,g+1)==1);
   fprintf('Number of variables selected from group %d-%d overlap: %d (of %d)\n',g,g+1,nnz(w(overlapInd)),length(overlapInd)); 
end
pause

%% Kernelized dual form of support vector machines
% We solve the Wolfe-dual of the hard-margin kernel support vector machine
% training problem:
%   min_alpha -sum_i alpha_i + (1/2)sum_i sum_j alpha_i alpha_j y_i y_j k(x_i,x_j),
%       s.t. alpha_i >= 0, sum_i alpha_i y_i = 0
%
% The dual form of support vector machine is described at:
% <http://en.wikipedia.org/wiki/Support_vector_machine#Dual_form Dual Form
% of SVMs>
% <http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification SVMs for Non-linear Classification>
%
% My implementation of the projection requires O(n^3).  This could clearly
% be reduced to O(n^2), but I haven't yet worked out whether it can be done in
% O(n log n) or O(n).

% Generate synthetic data
nInstances = 50;
nVars = 100;
nExamplePoints = 5; % Set to 1 for linear classifier, higher for more non-linear
nClasses = 2;
% examplePoints = randn(nClasses*nExamplePoints,nVars);
% X = 2*rand(nInstances,nVars)-1;
% y = zeros(nInstances,1);
% for i = 1:nInstances
%     dists = sum((repmat(X(i,:),nClasses*nExamplePoints,1) - examplePoints).^2,2);
%     [minVal minInd] = min(dists);
%     y(i,1) = sign(mod(minInd,nClasses)-.5);
% end
X = randn(nInstances,nVars);
w = randn(nVars,1);
y = sign(X*w + randn(nInstances,1));

% Put positive instances first (used by projection)
[y,sortedInd] = sort(y,'descend');
X = X(sortedInd,:);
nPositive = min(find(y==-1));

% Compute Gram matrix
rbfScale = 1;
K = kernelLinear(X,X);

% Initial guess of parameters
alpha = rand(nInstances,1);

% Set up objective function
funObj = @(alpha)dualSVMLoss(alpha,K,y);

% Set up projection 
%(projection function assumes that positive instances come first)
funProj = @(alpha)dualSVMproject(alpha,nPositive);

% Solve with PQN
fprintf('\nCompute dual SVM parameters...\n');
alpha = minConf_PQN(funObj,alpha,funProj);
fprintf('Number of support vectors: %d\n',sum(alpha > 1e-4));
pause

%% Smooth (Primal) Support Vector Machine with Multiple Kernel Learning
% We will solve min_w hinge(w,X,y).^2, s.t. sum_k ||w_k||_2 <= tau,
%   where X contains the expansions of multiple kernels and we want to
%   encourage selection of a sparse set of kernels.
%
% By squaring the slack variables we get a once differentiable objective
%
% The smooth support vector machine is described in:
% Lee and Mangasarian.  <ftp://ftp.cs.wisc.edu/pub/dmi/tech-reports/99-03.ps SSVM: A Smooth Support Vector Machine>.
% Computational Optimization and Applications (2001).
%
% Using group-sparsity for multiple kernel learning is described in:
% Bach, Lanckriet, and Jordan.  <http://www.di.ens.fr/~fbach/skm_icml.pdf Multiple Kernel Learning, Conic Duality,
% and the SMO Algorithm>.  NIPS (2004).

nInstances = 1000;
nKernels = 25;
kernelSize = ceil(10*rand(nKernels,1));
X = zeros(nInstances,0);
for k = 1:nKernels
   Xk = randn(nInstances,kernelSize(k));
   % Add kernel to 
   X = [X Xk];
end
w = zeros(0,1);
for k = 1:nKernels
    if rand > .9 % Only make ~10% of kernels are relevant
        w = [w;randn(kernelSize(k),1)];
    else
        w = [w;zeros(kernelSize(k),1)];
    end
end
y = sign(X*w + randn(nInstances,1));

% Initial guess of parameters
wMKL = zeros(sum(kernelSize),1);

% Set up objective function
funObj = @(w)SSVMLoss(w,X,y);

% Set up groups
offset = 0;
groups = zeros(size(w));
for k = 1:nKernels
    groups(offset+1:offset+kernelSize(k),1) = k;
    offset = offset+kernelSize(k);
end

% Set up L_1,2 Projection Function
tau = 1;
funProj = @(w)groupL2Proj(w,tau,groups);

% Solve with PQN
fprintf('\nComputing parameters of smooth SVM with multiple kernels...\n');
wMKL = minConf_PQN(funObj,wMKL,funProj);
wMKL(abs(wMKL) < 1e-4) = 0;
wMKL'
fprintf('Number of kernels selected: %d (of %d)\n',sum(accumarray(groups,abs(wMKL)) > 1e-4),nKernels);
pause

%% Approximating node marginals in undirected graphical models with variational mean field
% We want to approximate marginals in a pairwise Markov random field by 
% minimizing the Gibbs free energy under a mean-field (factorized)
% approximation.
% 
% Variational approximations and the mean field free energy are described
% in:
% Yedidia, Freeman, Weiss.  <http://www.merl.com/papers/docs/TR2001-22.pdf Understanding Belief Propagation and Its 
% Generalizations>.  IJCAI (2001).
%
% The projection reduces to a series of independent projections on the simplex.

% Generate potentials a pairiwse graphical model
nNodes = 50;
nStates = 2;
adj = zeros(nNodes);
for n1 = 1:nNodes
    for n2 = n1+1:nNodes
        if rand > .9
           adj(n1,n2) = 1;
           adj(n2,n1) = 1;
        end
    end
end
edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;
edgeEnds = edgeStruct.edgeEnds;
nodePot = rand(nNodes,nStates);
edgePot = rand(nStates,nStates,nEdges);

% Intialize marginals
nodeBel = (1/nStates)*ones(nNodes,nStates);

% Make objective function
funObj = @(nodeBel)MeanFieldGibbsFreeEnergyLoss(nodeBel,nodePot,edgePot,edgeEnds);

% Make projection function
funProj = @(nodeBel)MeanFieldGibbsFreeEnergyProject(nodeBel,nNodes,nStates);

% Solve with PQN
fprintf('\nMinimizing Mean Field Gibbs Free Energy of pairwise undirected graphical model...\n');
nodeBel(:) = minConf_PQN(funObj,nodeBel(:),funProj);

figure(f);f=f+1;
imagesc(nodeBel);colormap gray
title('Approximate node marginals');
ylabel('node');
xlabel('state');
figure(f);f=f+1;
drawGraph(adj);
title('Graph Structure');
pause

%% Multi-State Markov Random Field Structure Learning
% We will solve min_{w,v} nll(w,v,y), s.t. sum_e ||v_e||_2 <= tau,
% where nll(w,v,y) is the negative log-likelihood for a log-linear 
% Markov random field and each 'group' e is the set of parameters
% associated with an edge, leading to sparsity in the graph
%
% Using group-sparsity to select edges in a multi-state Markov random field
% is discussed in:
% Schmidt, Murphy, Fung, and Rosales.  <http://www.cs.ubc.ca/~murphyk/Papers/cvpr08.pdf Structure Learning in Random Field for
% Heart Motion Abnormality Detection>.  CVPR (2008).

% Generate Data
nInstances = 250;
nNodes = 8;
edgeDensity = .33;
nStates = 3;
ising = 0;
tied = 0;
useMex = 1;
y = UGM_generate(nInstances,0,nNodes,edgeDensity,nStates,ising,tied);

% Set up MRF
adj = fullAdjMatrix(nNodes);
edgeStruct = UGM_makeEdgeStruct(adj,nStates,useMex);
infoStruct = UGM_makeMRFInfoStruct(edgeStruct,ising,tied);

% Initialize Variables
[w,v] = UGM_initWeights(infoStruct,@zeros);
wv = [w(:);v(:)];

% Make Groups
nodeGroups = zeros(size(w));
edgeGroups = zeros(size(v));
for e = 1:edgeStruct.nEdges
   edgeGroups(:,:,e) = e; 
end
groups = [nodeGroups(:);edgeGroups(:)];

% Set up Objective Function
funObj = @(wv)UGM_MRFLoss(wv,y,edgeStruct,infoStruct,@UGM_Infer_Exact);
lambdaL2 = 1;
penalizedFunObj = @(wv)penalizedL2(wv,funObj,lambdaL2);

% Set up L_1,2 Projection Function
tau = 5;
funProj = @(wv)groupL2Proj(wv,tau,groups);

% Solve with PQN
fprintf('\nComputing Sparse Markov random field parameters...\n');
wv = minConf_PQN(penalizedFunObj,wv,funProj);
wv(abs(wv) < 1e-4) = 0;
[w,v] = UGM_splitWeights(wv,infoStruct);

% Check selected variables
for e = 1:edgeStruct.nEdges
   fprintf('Number of non-zero variables associated with edge from %d to %d: %d (of %d)\n',edgeStruct.edgeEnds(e,1),edgeStruct.edgeEnds(e,2),nnz(v(:,:,e)),numel(v(:,:,e))); 
end
fprintf('Total number of edges selected: %d (of %d)\n',sum(squeeze(sum(sum(v,1),2))~=0),edgeStruct.nEdges);

% Make final adjacency matrix
adj = zeros(nNodes);
for e = 1:edgeStruct.nEdges
    if any(v(:,:,e)~=0)
        n1 = edgeStruct.edgeEnds(e,1);
        n2 = edgeStruct.edgeEnds(e,2);
        adj(n1,n2) = 1;
        adj(n2,n1) = 1;
    end
end
figure(f);f=f+1;
drawGraph(adj);
title('Learned Sparse MRF Structure');
pause

%% Conditional Random Field Structure Learning with Pseudo-Likelihood
% We will solve min_{w,v} nll(w,v,x,y) + lambda * sum_e ||v_e||_inf,
% where nll(w,v,x,y) is the negative log-likelihood for a log-linear 
% conditional random field and each 'group' e is the set of parameters
% associated with an edge, leading to sparsity in the graph
%
% To solve the problem, we use a pseudo-likelihood approximation of the
% negative log-likelihood, and convert the non-differentiable problem to a
% differentiable one by introducing auxiliary variables
%
% Using group-sparsity to select edges in a conditional random field
% trained with pseudo-likelihood is discussed in:
% Schmidt, Murphy, Fung, and Rosales.  <http://www.cs.ubc.ca/~murphyk/Papers/cvpr08.pdf Structure Learning in Random Field for
% Heart Motion Abnormality Detection>.  CVPR (2008).

% Generate Data
nInstances = 250;
nFeatures = 10;
nNodes = 20;
edgeDensity = .25;
nStates = 2;
ising = 0;
tied = 0;
useMex = 1;
[y,adj,X] = UGM_generate(nInstances,nFeatures,nNodes,edgeDensity,nStates,ising,tied);

% Set up CRF
adj = fullAdjMatrix(nNodes);
edgeStruct = UGM_makeEdgeStruct(adj,nStates,useMex);

% Make edge features
Xedge = UGM_makeEdgeFeatures(X,edgeStruct.edgeEnds);
infoStruct = UGM_makeCRFInfoStruct(X,Xedge,edgeStruct,ising,tied);

% Initialize Variables
[w,v] = UGM_initWeights(infoStruct,@zeros);
wv = [w(:);v(:)];
nVars = length(wv);

% Make Groups
nodeGroups = zeros(size(w));
edgeGroups = zeros(size(v));
for e = 1:edgeStruct.nEdges
   edgeGroups(:,:,e) = e; 
end
groups = [nodeGroups(:);edgeGroups(:)];
nGroups = edgeStruct.nEdges;

% Set up Objective Function
funObj = @(wv)UGM_CRFpseudoLoss(wv,X,Xedge,y,edgeStruct,infoStruct);
lambdaL2 = 1;
penalizedFunObj = @(wv)penalizedL2(wv,funObj,lambdaL2);

% Initialize auxiliary variables that will bound norm
lambda = 500;
alpha = zeros(nGroups,1);
auxFunObj = @(wvAlpha)auxGroupLoss(wvAlpha,groups,lambda,penalizedFunObj);

% Set up L_1,inf Projection Function
[groupStart,groupPtr] = groupl1_makeGroupPointers(groups);
funProj = @(wvAlpha)auxGroupLinfProject(wvAlpha,nVars,groupStart,groupPtr);

% Solve with PQN
fprintf('\nComputing Sparse conditional random field parameters...\n');
wvAlpha = minConf_PQN(auxFunObj,[wv;alpha],funProj);
wv = wvAlpha(1:nVars);
wv(abs(wv) < 1e-4) = 0;
[w,v] = UGM_splitWeights(wv,infoStruct);

% Check selected variables
for e = 1:edgeStruct.nEdges
   fprintf('Number of non-zero variables associated with edge from %d to %d: %d (of %d)\n',edgeStruct.edgeEnds(e,1),edgeStruct.edgeEnds(e,2),nnz(v(:,:,e)),numel(v(:,:,e))); 
end
fprintf('Total number of edges selected: %d (of %d)\n',sum(squeeze(sum(sum(v,1),2))~=0),edgeStruct.nEdges);

% Make final adjacency matrix
adj = zeros(nNodes);
for e = 1:edgeStruct.nEdges
    if any(v(:,:,e)~=0)
        n1 = edgeStruct.edgeEnds(e,1);
        n2 = edgeStruct.edgeEnds(e,2);
        adj(n1,n2) = 1;
        adj(n2,n1) = 1;
    end
end
figure(f);f=f+1;
drawGraph(adj);
title('Learned Sparse CRF Structure (all nodes are connected to X)');