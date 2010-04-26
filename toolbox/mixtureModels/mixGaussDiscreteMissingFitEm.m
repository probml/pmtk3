function [model, loglikTrace] = mixGaussDiscreteMissingFitEm(data, K, types, varargin)
% Class-conditional is propduct of Gaussians and multinoullis
% p(x|z=k) = prod_{j in C} N(x_j|mu_{jk},sigma_{jk}) * ...
%            prod_{j in D} discrete(x_j | beta_{jk})

%PMTKauthor Hannes Bretschneider

[maxIter, tol, verbose, muk, Sigmak, mixweight] =...
    process_options(varargin, ...
    'maxIter', 100, 'tol', 1e-3, 'verbose', false, ...
    'mu', [], 'Sigma', [], 'mixweight', []);

%% extract missing data
[n,d] = size(data); N = n;
iscont = (types=='c');
isdiscr = ~iscont;
dataC = data(:,iscont);
dataD = data(:,isdiscr);
dCont = sum(iscont);
dDiscr = sum(isdiscr);

%% Relabel discrete features
for j=1:dDiscr
    x = dataD(:,j);
    l = unique(x(~isnan(x)));
    x(~isnan(x)) = arrayfun(@(a)find(l==a),x(~isnan(x)));
    dataD(:,j) = x;
    labels{j} = l;
    nStates(j) = length(l);
end

C = max(nStates);

%% initialize params
beta = zeros(C,dDiscr,K);
if isempty(muk) || isempty(Sigmak)
    muk = zeros(dCont,K);
    Sigmak = zeros(dCont,K);
    for k=1:K
        i=ceil(n*rand); %pick a random vector
        proto = dataC(i,:)';
        h = isnan(proto); % hidden values
        proto(h) = nanmean(dataC(:,h));
        muk(:,k) = proto;
        Sigmak(:,k) = nanvar(dataC);
        
        for j=1:dDiscr
            beta(1:nStates(j),j,k) = normalize(rand(nStates(j),1));
        end
    end
end
if isempty(mixweight)
    mixweight = normalize(ones(1,K));
end

%%
dataMissingC = isnan(dataC);
missingRowsC = any(dataMissingC,2);
missingRowsC = find(missingRowsC == 1);

dataMissingD = isnan(dataD);
missingRowsD = any(dataMissingD,2);
missingRowsD = find(missingRowsD == 1);

ndxMiss = find(isnan(dataD));
[iMiss jMiss] = ind2sub(size(dataD), ndxMiss);
dataD(ndxMiss) = 1+round((nStates(jMiss)-1)'.*rand(length(ndxMiss),1));

%% Transpose
XC = dataC';
XD = dataD';

%% main loop
iter = 1;
done = false;
while ~done
%     fprintf('Iteration: %d\n', iter);
    % we store the old values of mu, Sigma just in case the log likelihood
    % decreased and we need to return the last values before the singularity occurred
    muOld = muk;
    SigmaOld = Sigmak;
    
    % E step for Z - compute responsibilities
    rik = zeros(N, K);
    logmix = log(mixweight+eps);
    for k=1:K
        modelGaussK.mu = muk(:,k); modelGaussK.Sigma = diag(Sigmak(:,k)+1e-10);
        modelDiscrK.T = beta(:,:,k); modelDiscrK.K = C;
        modelDiscrK.d = dDiscr; 
        logpGauss = gaussLogprob(modelGaussK, dataC);
        logpDiscr = discreteLogprob(modelDiscrK, dataD);
        logrik(:, k) = logmix(k) + logpGauss  + logpDiscr;
    end
    z = maxidx(logrik, [], 2);
    [logrik, ll] = normalizeLogspace(logrik);
    rik = exp(logrik);
    loglikTrace(iter) = sum(ll);
    
    % E step for missing values of X
    % We accumulated the ESS in place to save memory
    muik = zeros(dCont,K); % muik(:,k) = sum_i r(i,k) E[xi | zi=k, xiv]
    V = zeros(dCont,K);
    expVals = zeros(dCont,1); % temporary storage
    expProd = zeros(dCont,1);
    for k=1:K
        mu=muk(:,k);
        Sigma=Sigmak(:,k);
        for i=1:N
            u = dataMissingC(i,:); % unobserved entries
            o = ~u;
            expVals(u) = mu(u);
            expVals(o) = XC(o,i);
            expProd(u) = expVals(u).^2 + Sigma(u);
            expProd(o) = expVals(o).^2;
            muik(:,k) = muik(:,k) + rik(i,k)*expVals;
            V(:,k) = V(:,k) + rik(i,k)*expProd;
        end
    end
    
    for m=1:length(missingRowsD);
        i = missingRowsD(m);
        u = isnan(dataD(i,:));
        betaW = zeros(C, dDiscr);
        for k=1:K
            betaW = betaW + rik(i,k)*beta(:,:,k);
        end
        expVals = pickModeClass(betaW);
        dataD(i,u) = expVals(u);
    end
    %% M step
    rk = sum(rik,1);
    mixweight = normalize(rk);
    for k=1:K
        muk(:,k) = muik(:,k)/rk(k);
        Sigmak(:,k) = (V(:,k) - rk(k)*muk(:,k).^2)/rk(k);
    end
    Sigmak(Sigmak<1e-15) = 1e-15;
    
    for j=1:dDiscr
        for c=1:C
            for k=1:K
                beta(c,j,k) = sum((rik(:,k).*(dataD(:,j)==c)))/rk(k);
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
model.beta = beta;
model.labels = labels;
model.types = types;
model.mixweight= mixweight;
end

function modeClass = pickModeClass(beta)
beta = beta';
mode = max(beta,[],2);
beta = bsxfun(@minus, beta, mode);
beta = (beta==0);
modeClass = arrayfun(@(i)find(beta(i,:)==1,1),1:size(beta,1));
end