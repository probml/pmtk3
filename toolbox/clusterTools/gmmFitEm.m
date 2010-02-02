function [model, loglikHist] = gmmFitEm(data, K, varargin)
% EM for fitting mixture of K gaussians
% data(i,:) is i'th case
% model is a structure containing these fields:
%   mu(:,) is k'th centroid
%   Sigma(:,:,k)
%   mixweight(k)
%
% loglikHist(t) for plotting


[maxIter, thresh, plotfn, verbose, mu, Sigma, mixweight] = process_options(...
    varargin, 'maxIter', 100, 'thresh', 1e-3, 'plotfn', [], ...
    'verbose', false, 'mu', [], 'Sigma', [], 'mixweight', []);
 
[N,D] = size(data);

if isempty(mu)
   % initialize with Kmeans
   [mu, assign] = kmeansSimple(data, K);
   % Now fit Gaussians using hard assignments
   Sigma = zeros(D,D,K);
   counts = zeros(1,K);
   for c=1:K
      ndx = find(assign==c);
      counts(c) = length(ndx);
      Sigma(:,:,c) = cov(data(ndx,:));
   end
   mixweight = normalize(counts);
end
if ~isempty(plotfn), feval(plotfn, data,  mu, Sigma, mixweight, [], -inf, 0); end
 
iter = 1;
done = false;
Y = data'; % Y(:,i) is i'th case
while ~done
  % E step - compute responsibilities
  logpost = zeros(N,K);
  logprior = log(mixweight);
  for c=1:K
    model.mu = mu(:, c); model.Sigma = Sigma(:, :, C);
    logpost(:,c) = gaussLogprob(model, data) + logprior(c);
  end
  [logpost, ll] = normalizeLogspace(logpost);
  loglikHist(iter) = sum(ll)/N;
  post = exp(logpost)'; % post(c, i) = responsibility for cluster c, point i
 
  % compute expected sufficient statistics
  w = sum(post,2);  % w(c) = sum_i post(c,i)
  WYY = zeros(D, D, K);  % WYY(:,:,c) = sum_i post(c,i) Y(:,i) Y(:,i)'
  WY = zeros(D, K);  % WY(:,c) = sum_i post(c,i) Y(:,i)
  for c=1:K
    weights = repmat(post(c,:), D, 1); % weights(:,i) = post(c,i)
    WYbig = Y .* weights; % WYbig(:,i) = post(c,i) * Y(:,i)
    WYY(:,:,c) = WYbig * Y';
    WY(:,c) = sum(WYbig, 2); 
    
    %{
    % debug
    tmp = zeros(D,1);
    tmp2 = zeros(D,D);
    for i=1:N
       tmp = tmp + post(c,i)*Y(:,i);
       tmp2 = tmp2 + post(c,i)*Y(:,i)*Y(:,i)';
    end
    assert(approxeq(tmp, WY(:,c)));
    assert(approxeq(tmp2, WYY(:,:,c)));
    %} 
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


