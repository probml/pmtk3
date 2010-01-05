
%%%%%%%%%%%%%%%%%%%%%% Set-up Problem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load Binary Classification Data
data = load('uci.ionosphere.data');

% Last attribute is the class label
y = data(:,end);

% Scale feature to be N(0,1)
X = standardizeCols(data(:,1:end-1));
[nInstances,nVariables] = size(X);

% Add bias
X = [ones(nInstances,1) X];
nVariables = nVariables + 1;

% Use Logistic Regression loss function
loss = @LogisticLoss;

% Arguments for Logistic Regression are X and y
lossArgs = {X,y};

% Set all variables to be initially 0
w_init = zeros(nVariables,1);

% Set lambda (higher values yield more regularization/sparsity)
lambda = 50;

% Penalize all variables except bias
lambdaVect = [0;lambda*ones(nVariables-1,1)];

% Use default options
% (some options get changed to invoke individual methods)
global_options = [];

% To get more accurate timing, you can turn off verbosity:
%global_options.verbose = 0;

%%%%%%%%%%%%%%%%%%%%%% Run Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nNext Algorithm: Gauss-Seidel...\n');
pause(0.5);
optimFunc = @L1GeneralCoordinateDescent;
options = global_options;
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;

fprintf('\nNext Algorithm: Shooting...\n');
pause(0.5);
optimFunc = @L1GeneralCoordinateDescent;
options = global_options;
options.mode = 1; % Turns on Shooting instead of Gauss-Seidel
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;

fprintf('\nNext Algorithm: Grafting...\n');
pause(0.5);
optimFunc = @L1GeneralGrafting;
options = global_options;
options.mode = 1;
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;

fprintf('\nNext Algorithm: SubGradient...\n');
pause(0.5);
optimFunc = @L1GeneralSubGradient;
options = global_options;
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;

fprintf('\nNext Algorithm: epsL1...\n');
pause(0.5);
optimFunc = @L1GeneralUnconstrainedApx;
options = global_options;
options.mode = 1; % Turns on epsL1 instead of smoothL1
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;

fprintf('\nNext Algorithm: Log-Barrier...\n');
pause(0.5);
optimFunc = @L1GeneralUnconstrainedApx;
options = global_options;
options.mode = 3; % Turns on using non-negative Log-Barrier instead of SmoothL1
options.solver = -2; % Turns on approximately solving for a sequence of parameters
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;

fprintf('\nNext Algorithm: SmoothL1...\n');
pause(0.5);
optimFunc = @L1GeneralUnconstrainedApx;
options = global_options;
options.solver = -2; % Turns on approximately solving for a sequence of parameters
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;

fprintf('\nNext Algorithm: EM...\n');
pause(0.5);
optimFunc = @L1GeneralIteratedRidge;
options = global_options;
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;

if exist('quadprog') == 2
    fprintf('\nNext Algorithm: SQP...\n');
    pause(0.5);
    optimFunc = @L1GeneralSequentialQuadraticProgramming;
    options = global_options;
    tic
    w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
    toc
    pause;
else
    fprintf('\nquadprog not found, skipping SQP\n');
end

fprintf('\nNext Algorithm: ProjectionL1...\n');
pause(0.5);
optimFunc = @L1GeneralProjection;
options = global_options;
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;

fprintf('\nNext Algorithm: InteriorPoint...\n');
pause(0.5);
optimFunc = @L1GeneralPrimalDualLogBarrier;
options = global_options;
tic
w = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
pause;