function models = linregMultitaskMixPriorFitEm(X, Y, K, varargin)
% multitask regression using a mixture of Gaussian prior
% Returns a cell of model where models{t} is the linear regression model of task t
% X is N*D, Y is N*T, K is num. mixture components

% This file is from pmtk3.googlecode.com


%PMTKauthor Robert Tseng

[maxIter] = process_options(varargin, 'maxIter', 20)
%% Initialization
% Book keeping variables
T = size(Y,2);
models = cell(1,T);
[N, D] = size(X);
tol = 1e-4;
maxIter = 100;
iter = 1;
converged = false;

% Model parameter variables
sigma2 = zeros(T,1);
expWeight = zeros(D,T);
expWeightSq = zeros(D,D,T);
b = zeros(T,1);
mu = zeros(D, K);
Sigma = zeros(D,D,K);

% Initialize the parameters
mixweight = normalize(ones(K,1));
perm = randperm(K);
for t = 1:T
    lambda = 0.001;
    models{t} = linregFit(X, Y(:,t), 'regtype', 'L2', 'lambda', lambda, ...
        'preproc', struct('standardizeX', false));
    b(t) = models{t}.w(1);
    sigma2(t) = models{t}.sigma2;
end
for k = 1:K
    cur = mod(perm(k),T) + 1;
    mu(:,k) = models{cur}.w(:) + rand(D,1);
    Sigma(:,:,k) = diag(var(Y(:,cur)) + rand(D,1));
end

%% Main Loop of EM
while (iter <= maxIter && ~converged)
    %% E step - compute r_tk = P(z_t = k | D, theta)
    logr = zeros(T, K);
    logmix = log(mixweight);
    for t = 1:T
        for k = 1:K
            curModel.mu = b(t) + X*mu(:,k);
            curModel.Sigma = diag(diag(sigma2(t) + X*Sigma(:,:,k)*X'));
            logr(t,k) = logmix(k) + sum(gaussLogprob(curModel, Y(:,t)));
        end
    end
    [logr, ll] = normalizeLogspace(logr);
    loglikhist(iter) = sum(ll)/T;
    rtk = exp(logr); % rtk(t,k) = p(z_t = k)
    rk = sum(rtk, 1); % rk(k) = sum_t r_tk
    
    %% E step - compute E[w_t] and E[w_t w_t']
    expWeight = zeros(D,T);
    expWeightSq = zeros(D,D,T);
    for t = 1:T
        cury = Y(:,t);
        for k = 1:K
            curSigma = inv(inv(Sigma(:,:,k)) + 1/sigma2(t) * (X' * X));
            curmu = curSigma * (X' * (cury - b(t)) / sigma2(t) + inv(Sigma(:,:,k)) * mu(:,k));
            expWeight(:,t) = expWeight(:,t) + rtk(t,k) * curmu;
            expWeightSq(:,:,t) = expWeightSq(:,:,t) + rtk(t,k) * (curSigma + curmu * curmu');
        end
    end
    
    %% M step - compute mixweight, mu(:,k), and Sigma(:,:,k)
    mixweight = normalize(rk);
    mu = zeros(D,K); Sigma = zeros(D,D,K);
    for k = 1:K
        for t = 1:T
                 Sigma(:,:,k) = Sigma(:,:,k) + rtk(t,k) * expWeightSq(:,:,t);
        end
        mu(:,k) = sum(repmat(rowvec(rtk(:,k)), [D 1]) .* expWeight, 2) / rk(k);
        Sigma(:,:,k) = Sigma(:,:,k) / rk(k) - mu(:,k) * rowvec(mu(:,k));
    end
    
    %% M step - compute b and sigma2
    for t = 1:T
        diff = Y(:,t) - X * expWeight(:,t);
        diffSq = zeros(N,1);
        for i = 1:N
            diffSq(i) = Y(i,t)^2 - 2*Y(i,t)*X(i,:)*expWeight(:,t) + trace(expWeightSq(:,:,t) * colvec(X(i,:)) * X(i,:));
        end
        b(t) = mean(diff);
         sigma2(t) = 1/N * sum(diffSq) - b(t)^2;
    end
    
    
    %% Check convergence
    if (iter > 1)
        diff = loglikhist(iter) - loglikhist(iter-1);
        if (diff < -tol)
            fprintf('Iteration %d: Log likelihood decreased to %.5f from %.5f\n', ...
                iter, loglikhist(iter), loglikhist(iter-1));
        elseif (abs(diff) < tol)
            converged = true;
        end
    end
    iter = iter + 1;
end

for t=1:T
    models{t}.w = expWeight(:,t);
    models{t}.w0  = b(t);
end
end
