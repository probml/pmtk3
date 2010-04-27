function [model, loglikTrace] = mixGaussMissingFitEm(data, K, varargin)
% Fit a mixture of Gaussians where the data may have NaN entries
% Set doMAP = 1 to do MAP estimation (default)
% Set diagCov = 1 to use and diagonal covariances (does not currently save
% space)

%PMTKauthor Kevin Murphy
%PMTKmodified Hannes Bretschneider

[maxIter, tol, verbose, muk, Sigmak, mixweight, doMAP, diagCov, initEye] =...
    process_options(varargin, ...
    'maxIter', 100, 'tol', 1e-3, 'verbose', false, ...
    'mu', [], 'Sigma', [], 'mixweight', [], 'doMAP', 1,...
    'diagCov', 0, 'initEye', 0);
%% extract missing data
[n,d] = size(data); N = n;
dataMissing = isnan(data);
missingRows = any(dataMissing,2);
missingRows = find(missingRows == 1);
X = data'; % now the columns of X contain the data

if doMAP
    % set hyper-parameters
    prior.m0 = zeros(d,1);
    prior.kappa0 = 0;
    prior.nu0 = d+2;
    prior.S0 = (1/K^(1/d))*nanvar(data(:))*eye(d);
end


%% initialize params
if isempty(muk) || isempty(Sigmak)
    muk = zeros(d,K);
    Sigmak = zeros(d,d,K);
    for k=1:K
        i=round(n*rand); %pick a random vector
        proto = data(i,:)';
        h = isnan(proto); % hidden values
        proto(h) = nanmean(data(:,h));
        muk(:,k) = proto;
        if ~initEye
            Sigmak(:,:,k) = diag(nanvar(data) + 1e-2);%/(K^d);
        else
            Sigmak(:,:,k) = eye(d);
        end
    end
end
if isempty(mixweight)
    mixweight = normalize(ones(1,K));
end

%% main loop
iter = 1;
done = false;
while ~done
    % we store the old values of mu, Sigma just in case the log likelihood
    % decreased and we need to return the last values before the singularity occurred
    muOld = muk;
    SigmaOld = Sigmak;
    
    % E step for Z - compute responsibilities
    model = struct('K', K, 'mu', muk, 'Sigma', Sigmak, 'mixweight', mixweight);
    [z, rik, ll] = mixGaussInfer(model, data); %#ok
    loglik = sum(ll); %#ok
    
    if doMAP
        % add log prior
        kappa0 = prior.kappa0; m0 = prior.m0;
        nu0 = prior.nu0; S0 = prior.S0;
        logprior = zeros(1,K);
        for c=1:K
            Sinv = inv(Sigmak(:,:,c));
            logprior(c) = logdet(Sinv)*(nu0 + d + 2)/2 - 0.5*trace(Sinv*S0) ...
                -kappa0/2*(muk(:,c)-m0)'*Sinv*(muk(:,c)-m0);
        end
        loglik = loglik + sum(logprior);
    end
    loglikTrace(iter) = loglik;
    
    % E step for missing values of X
    % We accumulated the ESS in place to save memory
    muik = zeros(d,K); % muik(:,k) = sum_i r(i,k) E[xi | zi=k, xiv]
    Vik = zeros(d,d,K); % Vik(:,:,k) = sum_i r(i,k) E[xi xi' | zi=k, xiv]
    expVals = zeros(d,1); expProd = zeros(d,d); % temporary storage
    for k=1:K
        mu=muk(:,k);
        Sigma=Sigmak(:,:,k);
        for i=1:N
            u = dataMissing(i,:); % unobserved entries
            o = ~u; % observed entries
            Sigmai = Sigma(u,u) - Sigma(u,o) /Sigma(o,o)* Sigma(o,u);
            expVals(u) = mu(u) + Sigma(u,o)/Sigma(o,o)*(X(o,i)-mu(o));
            expVals(o) = X(o,i);
            expProd(u,u) = (expVals(u) * expVals(u)' + Sigmai);
            expProd(o,o) = expVals(o) * expVals(o)';
            expProd(o,u) = expVals(o) * expVals(u)';
            expProd(u,o) = expVals(u) * expVals(o)';
            muik(:,k) = muik(:,k) + rik(i,k)*expVals;
            Vik(:,:,k) = Vik(:,:,k) + rik(i,k)*expProd;
        end
    end
    
    %% M step
    rk = sum(rik,1);
    mixweight = normalize(rk);
    %     for k=1:K
    %         muk(:,k) = muik(:,k)/rk(k);
    %         Sigmak(:,:,k) = (Vik(:,:,k) - rk(k)*muk(:,k)*muk(:,k)')/rk(k);
    %     end
    if doMAP
        kappa0 = prior.kappa0; m0 = prior.m0;
        nu0 = prior.nu0; S0 = prior.S0;
        for c=1:K
            muk(:,c) = (muik(:,c)+kappa0*m0)./(rk(c)+kappa0);
            a = (kappa0*rk(c))./(kappa0 + rk(c));
            b = nu0 + rk(c) + d + 2;
            Sprior = (muik(:,c)-m0)*(muik(:,c)-m0)';
            Sk = (Vik(:,:,c) - rk(c)*muk(:,c)*muk(:,c)');
            if diagCov
                Sigmak(:,:,c) = diag(diag((S0 + Sk + a*Sprior)./b));
            else
                Sigmak(:,:,c) = (S0 + Sk + a*Sprior)./b;
            end
        end
    else
        for c=1:K
            muk(:,c) = muik(:,c)/rk(c);
            if diagCov
                Sigmak(:,:,c) = diag(diag((Vik(:,:,c) -...
                    rk(c)*muk(:,c)*muk(:,c)')/rk(c)));
            else
                Sigmak(:,:,c) = (Vik(:,:,c) - rk(c)*muk(:,c)*muk(:,c)')/rk(c);
            end
        end
    end
    
    %% Convergence check
    if verbose, fprintf('%d: LL = %5.3f\n', iter, loglikTrace(iter)); end
    if iter > 1
        converged = convergenceTest(loglikTrace(iter), loglikTrace(iter-1), tol);
    else
        converged = false;
    end
    if iter > 1
        if (loglikTrace(iter) < loglikTrace(iter-1))
            warning('warning: EM did not increase objective.  Exiting with last reasonable parameters')
            muk = muOld;
            Sigmak = SigmaOld;
            break;
        end
    end
    done = converged || iter > maxIter;
    iter = iter + 1;
end
model.mu = muk;
model.Sigma = Sigmak;
model.mixweight= mixweight;
end
