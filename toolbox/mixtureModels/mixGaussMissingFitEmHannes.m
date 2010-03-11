function [model, loglikHist] = mixGaussMissingFitEmHannes(data, K, varargin)
% EM for fitting mixture of K gaussians with missing data
% data(i,:) is i'th case
% model is a structure containing these fields:
%   mu(:,) is k'th centroid
%   Sigma(:,:,k)
%   mixweight(k)
% loglikHist(t) for plotting
%PMTKauthor Hannes Bretschneider

[maxIter, thresh, plotfn, verbose, mu, Sigma, mixweight, rcondMin, regul] =...
  process_options(...
    varargin, 'maxIter', 100, 'thresh', 1e-3, 'plotfn', [], ...
    'verbose', false, 'mu', [], 'Sigma', [], 'mixweight', [],...
    'rcondMin', 1e-10, 'regularize', 1e-5);

[N,D] = size(data);

% to initialize fill the missing data with random data
hidNodes = find(isnan(data));
dataMean = nanmean(data);
dataStd = nanstd(data);
r = randn(N,D);
fill = bsxfun(@plus, bsxfun(@times, r, dataStd), dataMean);
Xc = data;
Xc(hidNodes) = fill(hidNodes);

if isempty(mu)
    % initialize randomly
    % This is done because kmeans classification resulted in singular
    % covariance matrices
    assign = randi(K, N, 1);
    % Now fit Gaussians using hard assignments
    Sigma = zeros(D,D,K);
    counts = zeros(1,K);
    for c=1:K
        ndx = find(assign==c);
        counts(c) = length(ndx);
        mu(:,c) = mean(Xc(ndx,:));
        Sigma(:,:,c) = cov(Xc(ndx,:));
    end
    mixweight = normalize(counts);
end



%%
iter = 1;
done = false;
while ~done
    % E step - compute responsibilities
    logpost = zeros(N,K);
    logprior = log(mixweight);
    for c=1:K
        model.mu = mu(:, c); model.Sigma = Sigma(:, :, c);
        logpost(:,c) = gaussLogprob(model, Xc) + logprior(c);
    end
    [logpost, ll] = normalizeLogspace(logpost);
    loglikHist(iter) = sum(ll)/N;
    post = exp(logpost)'; % post(c, i) = responsibility for cluster c, point i
    
    % Impute missing values
    WYY = zeros(D,D,K);
    for i=1:N
        hidNodes = find(isnan(data(i,:)));
        m = length(hidNodes);
        if isempty(hidNodes), continue, end;
        visNodes = find(~isnan(data(i,:)));
        visValues = data(i,visNodes);
        Exxi = NaN(D,D);
        muX = zeros(m,1);
        V = zeros(m,m);
        for k=1:K
            modelK.mu = mu(:,k); modelK.Sigma = Sigma(:,:,k);
            modelTmp = gaussCondition(modelK, visNodes, visValues);
            muX = muX + post(k,i) * modelTmp.mu';
            V = V + post(k,i) * modelTmp.Sigma;
        end
        Xc(i, hidNodes) =  muX;
        Exxi(hidNodes,hidNodes) = muX * muX' + V;
        Exxi(visNodes,visNodes) = Xc(i, visNodes)' * Xc(i, visNodes);
        Exxi(hidNodes,visNodes) = muX * Xc(i, visNodes);
        Exxi(visNodes,hidNodes) = Xc(i, visNodes)' * muX';
        for c=1:K
            WYY(:,:,c) = WYY(:,:,c) + post(c,i) * Exxi;
        end
    end
    Y = Xc'; % Y(:,i) is i'th case
    
    % compute expected sufficient statistics
    w = sum(post,2);  % w(c) = sum_i post(c,i)
    WY = zeros(D, K);  % WY(:,c) = sum_i post(c,i) Y(:,i)
    for c=1:K
        weights = repmat(post(c,:), D, 1); % weights(:,i) = post(c,i)
        WYbig = Y .* weights; % WYbig(:,i) = post(c,i) * Y(:,i)
        WY(:,c) = sum(WYbig, 2);
    end
    
    % M step
    mixweight = normalize(w);
    % Set any zero weights to one before dividing
    % This is valid because w(c)=0 => WY(:,c)=0, and 0/0=0
    w = w + (w==0);
    mu = WY ./ repmat(w(:)', [D 1]);
    Sigma = zeros(D,D,K);
    for c=1:K
        Sigma(:,:,c) = WYY(:,:,c)/w(c)  - mu(:,c)*mu(:,c)';
    end
    
    % Converged?
    if iter == 1
        converged = false;
    else
        converged =  convergenceTest(loglikHist(iter), loglikHist(iter-1), thresh);
    end
    if ~isempty(plotfn), feval(plotfn, data,  mu, Sigma, mixweight, post, loglikHist(iter), iter); end
    done = converged || (iter > maxIter);
    if verbose, fprintf(1, 'iteration %d, loglik = %f\n', iter, loglikHist(iter)); end
    iter = iter + 1;
end


model.mu  = mu; model.Sigma = Sigma; model.mixweight = mixweight; model.K = K;
%model.post = post;
end