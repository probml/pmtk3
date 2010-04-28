function [model, loglikHist] = mixStudentFitEm(data, K, varargin)
% EM for fitting mixture of K Student-t distributions
% data(i,:) is i'th case
% model is a structure containing these fields:
%   mu(:,) is k'th centroid
%   Sigma(:,:,k)
%   mixweight(k)
%   dof(k)
%   K
% loglikHist(t) for plotting


%PMTKauthor Robert Tseng
%PMTKmodified Kevin Murphy

[maxIter, thresh, plotfn, verbose, mu, Sigma, dof, mixweight] = process_options(...
    varargin, 'maxIter', 100, 'thresh', 1e-3, 'plotfn', [], ...
    'verbose', false, 'mu', [], 'Sigma', [], 'dof', 4*ones(1,K), 'mixweight', []);
  
%if isempty(dof), dof = 10 * rand(K,1); end % start with large dof near Gaussian
  
[N,D] = size(data);

if isempty(mu)
  [mu, Sigma, mixweight] = kmeansInitMixGauss(data, K);
end
  
iter = 1;
done = false;
X = data; % X(i,:) is i'th case 
clear data
while ~done
  % E step 
  % Compute responsibilities
  model.mu  = mu; model.Sigma = Sigma; model.mixweight = mixweight;
  model.K = K; model.dof = dof;
  [z, post, ll] = mixStudentInfer(model, X); %#ok
  loglikHist(iter) = sum(ll)/N; %#ok
  R = sum(post, 1); % R(c) = sum_i post(c,i)

  u = zeros(N, K); % E[tau(i) | Zi=k]
  for c=1:K
    % E step - compute E[tau(i)]
    SigmaInv = inv(Sigma(:,:,c));
    XC = bsxfun(@minus,X,rowvec(mu(:,c)));
    delta = sum(XC*SigmaInv.*XC,2); %#ok
    u(:,c) = (dof(c)+D) ./ (dof(c)+delta); % E[tau(i)]
  end
    
  % M step
  mixweight = normalize(R);
  for c=1:K
    % ESS
    w = u(:,c);
    Xw = repmat(post(:,c), 1, D) .* X .* repmat(w(:), 1, D);
    Sw = sum(post(:,c) .* w);
    SX = sum(Xw, 1)'; % sum_i r_ik u(i) xi, column vector
    SXX = Xw'*X; % sum_i r_ik u(i) xi xi'
    
    % M step
    mu(:,c) = SX / Sw;
    Sigma(:,:,c) = (1/R(c))*(SXX - SX*SX'/Sw);
  end
  
   % estimate dof one component at a time
   for c=1:K
      model.mu  = mu; model.Sigma = Sigma; model.mixweight = mixweight;
      model.K = K; model.dof = dof;
     dof(c) = estimateDofNLL(X, model, c); % ECME
   end
   
  % Converged?
  if iter == 1
     done = false;
  elseif iter >= maxIter
    done = true;
  else
     done =  convergenceTest(loglikHist(iter), loglikHist(iter-1), thresh);
  end
  if verbose, fprintf(1, 'iteration %d, loglik = %f\n', iter, loglikHist(iter)); end
  iter = iter + 1;
end 


model.mu  = mu; model.Sigma = Sigma; model.mixweight = mixweight;
model.K = K; model.dof = dof;
end

function dof = estimateDofNLL(X, model, curK)
% optimize neg log likelihood of observed data
% using gradient free optimizer.
nllfn = @(v) NLL(X, model, curK, v);
dofMax = 1000; dofMin = 0.1;
dof = fminbnd(nllfn, dofMin, dofMax);
end

function out= NLL(X, model, curK, v)
model.dof(curK) = v;
out = -sum(mixStudentLogprob(model, X));
end

