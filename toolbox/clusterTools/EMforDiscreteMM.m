function [p, mixingWeights] = EMforDisceteMM(p, distPrior, mixingWeights, mixPrior, X, varargin)
  X = canonizeLabels(X);
  [verbose, maxItr, tol, nrestarts] = processArgs(varargin, '-verbose', true, '-maxItr', 50, '-tol', 1e-03, '-nrestarts', 1);
  [nStates, d, K] = size(p); nObs = size(X,1);

  % "p" is nStates * nDistributions * nMixingComponents
  % initialize p and mixingWeights
  perm = randperm(nObs);
  batchSize = max(1,floor(nObs/K));
  for k=1:K
    start = (k-1)*batchSize+1;
    initdata = X(perm(start:start+batchSize-1),:);
    for s=1:nStates
      p(:,:,k) = bsxfun(@plus, histc(initdata,1:nStates), distPrior(:,k)) - 1;
    end
    p(:,:,k) = normalize(p(:,:,k), 1);
  end
  mixingWeights = normalize(rand(K,1));

  converged = false; itr = 0;
  currentLL = -inf;
  while(not(converged) && itr < maxItr)
    itr = itr + 1; prevLL = currentLL;
    % E step
    % Infer the latent values
    logpij = zeros(nObs, K);
    for k=1:K
      Lij = zeros(nObs,d);
      for j=1:d
        Lij(:,j) = log(p(X(:,j),j,k));
      end
      L = sum(Lij,2);
      logpij(:,k) = log(mixingWeights(k)) + L;
    end
    [normLogpij, LL] = normalizeLogspace(logpij);
    pij = exp(normLogpij);
    % Get expected sufficient statistics for each component and each dimension
    suffStat = zeros(nStates, d, K);
    for k=1:K
      for s=1:nStates
        for j=1:d
          suffStat(s,j,k) = sum( pij(X(:,j) == s,k) );
        end
      end
    end
    logpriormix = gammaln(sum(mixPrior)) - sum(gammaln(mixPrior)) + sum((mixPrior - 1).*log(mixingWeights));
    logprior = zeros(K,1);
    for k=1:K
      A = repmat(distPrior(:,k) -1, 1, d);
      logprior(k) = sum(gammaln(sum(distPrior(:,k))) - sum(gammaln(distPrior(:,k))) + sum(log(p(:,:,k)).*A,1));
    end


    L = sum(LL); 
    L = L + logpriormix + sum(logprior); 
    currentLL = L / nObs;
    if(currentLL < prevLL), warning('Decreased likelihood'); end;
    if(verbose), fprintf('Iteration %d: Previous LL = %g, Current LL = %g\n', itr, prevLL, currentLL); end;
    converged = convergenceTest(currentLL, prevLL);

    % M step
    for k=1:K
      p(:,:,k) = normalize(bsxfun(@plus, suffStat(:,:,k), distPrior(:,k)) - 1, 1);
    end
    mixingWeights = colvec(normalize( sum(pij,1) + mixPrior' - 1));
  end % while not converged
end