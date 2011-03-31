%% Bayesian Exponential Family PCA
% Shakir Mohamed - May 2008
%
% Run Hybrid Monte Carlo using leapfrog discretisation
% This is based on the HMC code outline given in MacKay, chapter 30
% "Efficient Monte Carlo Methods", pg 388.
%
% Input Parameters
    % 
    % numLeaps, numIter
    % numFactors - K parameter in the model
    % X - Data full Matrix - dim NxD
    % m, S, alpha, beta- hyperparameters
    % stepSize - (sometimes called epsilon) 
%
% Function Prototype:
    % out = HMC(simParams, numFactors, lambda, alpha, beta, m, S, X, debug)
    % SimParams is a struct of the settings for the HMC simulation, num
    %      leapfrog steps, number of HMC iterations and the step size at each
    %      iteration. 
    % numFactors - is the dimension of the new feature space.
    % lambda - 1x2 vector with values for lambda1 and lambda2
    % alpha, beta - hyperparameters for the inverse gamma prior on the
    %       covariance
    % m, S - hyperparameters for normal prior on mean
    % X - is the dataset dimensions NxD
    % debug = 1 prints some debug info to the screen.
%

function [out stats] = HMC_missData(simParams, numFactors, lambda, alpha, beta, m, S, X, debug)

numLeaps = simParams.numLeaps; % number of leapfrog steps
numIter = simParams.numIter; % Number of iterations
stepSize = simParams.stepSize; % The stepsize for updates.
K = numFactors; 

[numObs numFeatures] = size(X); % Number of data points & features
saveEvery = 5; count = 1;

%----- Initialise parameters of Model
% init diag elems of cov Sigma with draws from an inverse gamma - dim 1xK
gamSigma = gamrnd(alpha,1/beta,1,numFactors); 
Sigma = 1./gamSigma; 
% init mu, the mean from Gauss mean m, and cov S - dim 1xK
mu = (randnorm(1,m,[],S));
V = randn(numObs,numFactors);
Theta = rand(numFactors, numFeatures);

%----- Convert params from constrained to unconstrained
unconstrSigma = log(Sigma); % unconstrained -> c.f above eq (3.10)
%----- Convert to a single col of all params - application of vec operator
omega = [mu(:); Sigma(:); V(:); Theta(:)]; % Constrained Params
tau = [mu(:); unconstrSigma(:); V(:); Theta(:)]; % Unconstrained Params

% Preallocate some memory for the output
out = zeros(floor(numIter/saveEvery),2+length(omega));

%----- Calc Energy and Gradient
numParams = numel(tau); accCount = 0;
grad = gradE_missData(X, omega, alpha, beta, lambda, S, m, K); % Calc grad
energy = findE_missData(X, omega, alpha, beta, lambda, S, m, K); % Calc Energy

tic
for iter = 1:numIter
    % work with params as a single row vector.
    p = randn(numParams,1); % Initial momentum from N(0,1)
    EkI(iter) = p'*p/2; % Initial Kinetic Energy
    EpI(iter) = energy; % Initial Potential Energy

    H =  EkI(iter) + EpI(iter); % Evaluate Hamiltonian
    
    % Do  xnew = x step HERE
    tauNew = tau; omegaNew = omega; gradNew = grad;

    for t = 1:numLeaps
        p = p - stepSize*gradNew/2; % half step in p
        tauNew = tauNew + stepSize*p; % make a step
        % Convert Sigma back to unconstr space
        omegaNew = tauNew; % copy new values fisrt
        omegaNew(K+1:2*K) = exp(omegaNew(K+1:2*K)); % update relev parts
        gradNew = gradE_missData(X, omegaNew, alpha, beta, lambda, S, m, K); % new grad
        p = p - stepSize*gradNew/2; % half step in p
    end;

    energyNew = findE_missData(X, omegaNew, alpha, beta, lambda, S, m, K); % Find new value for Hamiltonian
    
    EkA(iter) = p' * p/2; % New Kinetic Energy
    EpA(iter) = energyNew; % New potential energy
    Hnew = EkA(iter) + EpA(iter); % New hamiltonian
    
    dH = Hnew - H; % Decide whether to accept
    accVal = rand;
    if (dH < 0)
        accept = 1;
    elseif (accVal < exp(-dH))
        accept = 1;
    else
        accept = 0;
    end;

    if accept
        accCount = accCount + 1;
        grad = gradNew;
        energy = energyNew;
        omega = omegaNew;
        tau = tauNew;
    end;
    
    if (mod(iter,saveEvery) == 0)
        % save entire row vector of simulation for this iteration
        out(count,:) = [energy, accept, omega']; 
        mom(count) = p'*p/2;
        en(count) = energy;
        dhh(count) = dH;
        count = count + 1;
        tt(count) = toc;
    end;
    
    if debug
        fprintf('Iteration: %u \n',iter);
        fprintf('exp(-dh) \t Energy  \n');
        fprintf('%g \t %8.4f \n',exp(-dH), energy);
    end;
end;

stats.momentum = mom;
stats.energy = en;
stats.dh = dhh;
stats.time = tt;
disp('done');
