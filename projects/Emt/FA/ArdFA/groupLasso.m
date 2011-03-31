function [Z,u,gamma] = groupLasso(Y, u0, Z0, params)

  [D, Dz] = size(params.beta);
  [N] = size(Y,2);

  Y = bsxfun(@minus, Y, params.mean);

  lambda = 2*sqrt(u0 + params.theta^2);

  % Initial guess of parameters
  W_groupSparse = Z0;%zeros(Dz,N);

  % Set up Objective Function
  funObj = @(W)SimultaneousSquaredError(W,params.beta,Y);

  % Set up Groups
  groups = repmat([1:Dz]',1,N);
  groups = groups(:);
  nGroups = max(groups);
  % Initialize auxiliary variables that will bound norm
  alpha = zeros(nGroups,1);
  penalizedFunObj = @(W)auxGroupLoss(W,groups,lambda,funObj);

  % Set up L_1,inf Projection Function
  [groupStart,groupPtr] = groupl1_makeGroupPointers(groups);
  funProj = @(W)auxGroupL2Project(W,Dz*N,groupStart,groupPtr);
  % Solve with PQN
  fprintf('\nComputing group-sparse simultaneous regression parameters...\n');
  Walpha = minConF_SPG(penalizedFunObj,[W_groupSparse(:);alpha],funProj, struct('verbose',1));
  % Extract parameters from augmented vector
  W_groupSparse(:) = Walpha(1:Dz*N);
  W_groupSparse(abs(W_groupSparse) < 1e-4) = 0;
  Z = W_groupSparse;

  % compute gamma
  gamma = sqrt(sum(Z.^2,2))./lambda;

  % compute u
  C = params.beta*diag(gamma)*params.beta' + params.noiseCovMat;
  u = N*diag(params.beta'*inv(C)*params.beta) + (2 -params.lambda)./(max(gamma + eps));

