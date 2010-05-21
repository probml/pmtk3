
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
%global_options.adjustStep = 2;
global_options.order = 2;

% To get more accurate timing, you can turn off verbosity:
%global_options.verbose = 0;

%% %%%%%%%%%%%%%%%%%%%% Run Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nNext Algorithm: Gauss-Seidel...\n');
pause(0.5);
optimFunc = @L1GeneralCoordinateDescent;
options = global_options;
tic
wGS = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: Shooting...\n');
pause(0.5);
optimFunc = @L1GeneralCoordinateDescent;
options = global_options;
options.mode = 1; % Turns on Shooting instead of Gauss-Seidel
tic
wShoot = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: Gauss-Southwell...\n');
pause(0.5);
optimFunc = @L1GeneralCoordinateDescent;
options = global_options;
options.mode = 2; % Use Gauss-Southwell
tic
wShoot = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: Grafting...\n');
pause(0.5);
optimFunc = @L1GeneralGrafting;
options = global_options;
options.mode = 1;
tic
wGraft = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: SubGradient...\n');
pause(0.5);
optimFunc = @L1GeneralSubGradient;
options = global_options;
tic
wSubGrad = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: Max-K SubGradient...\n');
pause(0.5);
optimFunc = @L1GeneralSubGradient;
options = global_options;
options.k = 1;
tic
wMaxK = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: epsL1...\n');
pause(0.5);
optimFunc = @L1GeneralUnconstrainedApx;
options = global_options;
options.mode = 1; % Turns on epsL1 instead of smoothL1
options.cont = 0; % Turn off continuation
tic
wEpsL1 = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

if global_options.order == 2
fprintf('\nNext Algorithm: Log-Barrier...\n');
pause(0.5);
optimFunc = @L1GeneralUnconstrainedApx;
options = global_options;
options.mode = 3; % Turns on using non-negative Log-Barrier instead of SmoothL1
tic
wLogBarrier = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;
end

fprintf('\nNext Algorithm: SmoothL1 (short-cut)...\n');
pause(0.5);
optimFunc = @L1GeneralUnconstrainedApx;
options = global_options;
options.cont = 0; % Turn off continuation
tic
wSmoothL1sc = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: SmoothL1 (continuation)...\n');
pause(0.5);
optimFunc = @L1GeneralUnconstrainedApx;
options = global_options;
tic
wSmoothL1ct = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: EM...\n');
pause(0.5);
optimFunc = @L1GeneralIteratedRidge;
options = global_options;
tic
wEM = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

if exist('quadprog') == 2
    fprintf('\nNext Algorithm: SQP...\n');
    pause(0.5);
    optimFunc = @L1GeneralSequentialQuadraticProgramming;
    options = global_options;
    tic
    wSQP = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
    toc
    fprintf('\n(paused, press any key to start next algorithm)\n');
    pause;
else
    fprintf('\nquadprog not found, skipping SQP\n');
end

fprintf('\nNext Algorithm: ProjectionL1...\n');
pause(0.5);
optimFunc = @L1GeneralProjection;
options = global_options;
tic
wProj = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: InteriorPoint...\n');
pause(0.5);
optimFunc = @L1GeneralPrimalDualLogBarrier;
options = global_options;
tic
wIP = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

fprintf('\nNext Algorithm: Orthant-Wise...\n');
pause(0.5);
optimFunc = @L1GeneralOrthantWise;
options = global_options;
tic
wOrthant = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

if global_options.order == 2
fprintf('\nNext Algorithm: Pattern-Search...\n');
pause(0.5);
optimFunc = @L1GeneralPatternSearch;
options = global_options;
tic
wPS = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;
end

fprintf('\nNext Algorithm: Projected SubGradient...\n');
pause(0.5);
optimFunc = @L1GeneralProjectedSubGradient;
options = global_options;
tic
wPSG = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;

if global_options.order == 1
fprintf('\nNext Algorithm: Projected SubGradient BB...\n');
pause(0.5);
optimFunc = @L1GeneralProjectedSubGradientBB;
options = global_options;
tic
wPSG = optimFunc(loss,w_init,lambdaVect,options,lossArgs{:});
toc
fprintf('\n(paused, press any key to start next algorithm)\n');
pause;
end
