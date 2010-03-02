function [model, loglikHist] = mixGaussFitEm(data, K, varargin)
% EM for fitting mixture of K gaussians
% data(i,:) is i'th case
% To perform MAP estimation using a vague conjugate prior, use
%  model = mixGaussFitEm(data, K, 'doMAP', 1)
%
% You can optionally call a plotting funciton at each iteration
% to visualize progress. The function should have this itnerface
%   plotfn(data,  mu, Sigma, mixweight, post, loglik, iter)
% where post is N*K. 
%
% Return arguments:
% model is a structure containing these fields:
%   mu(:,) is k'th centroid
%   Sigma(:,:,k)
%   mixweight(k)
%   post(k,i)
%   K
%
% loglikHist is the history of log-likelihood (plus log-prior) vs iteration


[maxIter, thresh, plotfn, verbose, mu, Sigma, mixweight, doMAP] = process_options(...
    varargin, 'maxIter', 100, 'thresh', 1e-3, 'plotfn', [], ...
    'verbose', false, 'mu', [], 'Sigma', [], 'mixweight', [], 'doMAP', 0);
 
[N,D] = size(data);
if doMAP
  % set hyper-parameters
  prior.m0 = zeros(D,1);
  prior.kappa0 = 0;
  prior.nu0 = D+2;
  prior.S0 = (1/K^(1/D))*var(data(:))*eye(D);
end


if isempty(mu)
  [mu, Sigma, mixweight] = kmeansInitMixGauss(data, K);
end
 
 
if ~isempty(plotfn)
    % do an initial E step to visualize initial params 
    model.mu  = mu; model.Sigma = Sigma; model.mixweight = mixweight; model.K = K;
    [z, post, ll] = mixGaussInfer(model, data); %#ok
    plotfn(data,  mu, Sigma, mixweight, post, -inf, 0); 
end


iter = 1;
done = false;
Y = data'; % Y(:,i) is i'th case
while ~done
  % E step - compute responsibilities
   model.mu  = mu; model.Sigma = Sigma; model.mixweight = mixweight; model.K = K;
  [z, post, ll] = mixGaussInfer(model, data); %#ok
  % post(i,c) = responsibility for cluster c, point i
  
  % Evaluate objective funciton
  loglik = sum(ll)/N;
  if doMAP
    % add log prior
    kappa0 = prior.kappa0; m0 = prior.m0;
    nu0 = prior.nu0; S0 = prior.S0;
    logprior = zeros(1,K);
    for c=1:K
      Sinv = inv(Sigma(:,:,c));
      logprior(c) = logdet(Sinv)*(nu0 + D + 2)/2 - 0.5*trace(Sinv*S0) ...
        -kappa0/2*(mu(:,c)-m0)'*Sinv*(mu(:,c)-m0);
    end
    loglik = loglik + sum(logprior)/N;
  end
  loglikHist(iter) = loglik;
  
 
  % compute expected sufficient statistics
  w = sum(post,1);  % w(c) = sum_i post(c,i)
  Sk = zeros(D,D,K);
  ybark = zeros(D,K);
  for c=1:K
    weights = repmat(post(:,c), 1, D)'; % weights(:,i) = post(i,c)
    Yk = Y .* weights; % Yk(:,i) = post(c,i) * Y(:,i)
    ybark(:,c) = sum(Yk/w(c),2);
    Ykmean = Y - repmat(ybark(:,c),1,N);
    Sk(:,:,c) = weights.*Ykmean*Ykmean';
  end
  
 
  % M step
  mixweight = normalize(w);
  % Set any zero weights to one before dividing
  % This is valid because w(c)=0 => WY(:,c)=0, and 0/0=0
  w = w + (w==0);
  Sigma = zeros(D,D,K);
  mu = zeros(D,K);
  if doMAP
    kappa0 = prior.kappa0; m0 = prior.m0;
    nu0 = prior.nu0; S0 = prior.S0;
    for c=1:K
      mu(:,c) = (w(c)*ybark(:,c)+kappa0*m0)./(w(c)+kappa0);
      a = (kappa0*w(c))./(kappa0 + w(c));
      b = nu0 + w(c) + D + 2;
      Sprior = (ybark(:,c)-m0)*(ybark(:,c)-m0)';
      Sigma(:,:,c) = (S0 + Sk(:,:,c) + a*Sprior)./b;
    end
  else
    for c=1:K
      mu(:,c) = ybark(:,c);
      Sigma(:,:,c) = Sk(:,:,c)/w(c);
    end
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


