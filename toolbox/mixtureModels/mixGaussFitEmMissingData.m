function model = mixGaussFitEmMissingData(X, nmix, varargin)
%% Fit a mixture of Gaussians to partially observed data
[maxIter, tol, verbose, doMAP, prior] = process_options(varargin,...
    'maxIter'  , 100    , ...
    'tol'      , 1e-4   , ...
    'verbose'  , true   , ...
    'doMAP'    , false  , ... 
    'prior'    , []     );    % a struct with fields m0, kappa0, nu0, S0
%% Find missing data
missing = isnan(X);
remove  = all(missing, 2); % remove data cases with all NaNs
X(remove, :)       = [];
missing(remove, :) = [];
[N, D] = size(X);
%% Initialize
for i=1:N
    X(i, missing(i, :)) = mean(X(i, ~missing(i, :)));
end
[mu, Sigma, mixweight] = kmeansInitMixGauss(X, nmix);
X = impute(X, mu, Sigma, mixweight, missing);
%% Setup prior
if doMAP || ~isempty(prior);
    if isempty(prior)
        m0     = zeros(D,1);
        kappa0 = 0;
        nu0    = D+2;
        S0     = (1/nmix^(1/D))*var(X(:))*eye(D);
    else
        m0     = prior.m0;
        kappa0 = prior.kappa0;
        nu0    = prior.nu0;
        S0     = prior.S0;
    end
    doMAP = true;
end
%% Setup loop
currentLL = -inf;
iter = 1;
while true
    prevLL = currentLL;
    %% Estep
    model = struct('mu',mu,'Sigma',Sigma,'mixweight',mixweight,'K',nmix);
    [z, post, ll] = mixGaussInfer(model, X);
    w     = sum(post, 1);
    Sk    = zeros(D, D, nmix);
    ybark = zeros(D, nmix);
    for c = 1:nmix
        weights      = repmat(post(:,c), 1, D)';
        Yk           = X' .* weights;
        ybark(:, c)  = sum(Yk/w(c), 2);
        Ykmean       = X' - repmat(ybark(:, c),1,N);
        Sk(:, :, c)  = weights.*Ykmean*Ykmean';
    end
    %% Evaluate objective
    currentLL = sum(ll)/N;
    if doMAP
        logprior = zeros(1, nmix);
        for c = 1:nmix
            Sc   = Sigma(:, :, c);
            ldet = logdet(inv(Sc));
            muc  = mu(:, c);
            logprior(c) = ldet*(nu0+D+2)/2  - ...
                0.5*trace(Sc\S0)  - ...
                kappa0/2*(muc-m0)'*(Sc\(muc-m0));
        end
        currentLL = currentLL + sum(logprior)/N;
    end
    %% Check convergence
    if verbose, fprintf('iteration %d, loglik = %f\n',iter,currentLL);  end
    if iter > maxIter || convergenceTest(currentLL, prevLL, tol); break;end
    iter = iter + 1;
    %% Mstep
    mixweight = normalize(w);
    w = w + (w==0);
    Sigma = zeros(D, D, nmix);
    mu = zeros(D, nmix);
    if doMAP
        for c = 1:nmix
            mu(:, c)       = (w(c)*ybark(:, c)+kappa0*m0)./(w(c)+kappa0);
            a              = (kappa0*w(c))./(kappa0 + w(c));
            b              = nu0 + w(c) + D + 2;
            Sprior         = (ybark(:, c)-m0)*(ybark(:, c)-m0)';
            Sigma(:, :, c) = (S0 + Sk(:, :, c) + a*Sprior)./b;
        end
    else
        for c=1:nmix
            mu(:, c)       = ybark(:, c);
            Sigma(:, :, c) = Sk(:, :, c)/w(c);
        end
    end
    %% Impute
    X = impute(X, mu, Sigma, mixweight, missing);
end
model = struct('mu',mu,'Sigma',Sigma,'mixweight',mixweight,'K', nmix);
end


function X = impute(X, mu, Sigma, mixweight, missing)
X(missing) = NaN;
tmpModel = struct('mu', mu, 'Sigma', Sigma, 'mixweight', mixweight);
X = mixGaussImpute(tmpModel, X);
end
