function [model, loglikHist] = mixStudentFitEmOld(data, K, varargin)
% EM for fitting mixture of K Student-t distributions
% data(i,:) is i'th case
% model is a structure containing these fields:
%   mu(:,) is k'th centroid
%   Sigma(:,:,k)
%   mixweight(k)
%   dof(k)
%   K
%   post(k,i)
% loglikHist(t) for plotting


%PMTKauthor Robert Tseng
%PMTKmodified Kevin Murphy

[maxIter, thresh, plotfn, verbose, mu, Sigma, dof, mixweight] = process_options(...
    varargin, 'maxIter', 100, 'thresh', 1e-3, 'plotfn', [], ...
    'verbose', false, 'mu', [], 'Sigma', [], 'dof', 1*ones(1,K), 'mixweight', []);

[N,D] = size(data);

if isempty(mu)
    % initialize with Kmeans
    [mu, assign] = kmeansFit(data, K);
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


iter = 1;
done = false;
X = data; % X(i,:) is i'th case
clear data
while ~done
    % E step
    % Compute responsibilities
    [post, ll] = computePost(X, mu, Sigma, dof, mixweight);
    loglikHist(iter) = sum(ll)/N;
    
    
    % Compute ESS
    u = zeros(N,K);
    for c=1:K
        SigmaInv = inv(Sigma(:,:,c));
        XC = bsxfun(@minus, X, rowvec(mu(:,c)));
        delta = sum(XC * SigmaInv .* XC, 2); %#ok
        u(:,c) = (dof(c) + D) ./ (dof(c) + delta);
    end
    s = log(u) + repmat(psi( (dof+D)./2), N, 1) - repmat( log( (dof+D)./2), N, 1);
    
    % M step
    R = sum(post, 2);
    mixweight = normalize(R);
    for c=1:K
        w = u(:,c);
        Xw = repmat(post(c,:)', 1, D) .* X .* repmat(w(:), 1, D);
        Sw = sum(post(c,:)' .* w);
        SX = sum(Xw, 1)';
        SXX = Xw'*X;
        
        mu(:,c)  = SX/Sw;
        Sigma(:,:,c) = (1/R(c))*(SXX - SX*SX'/Sw);
    end
    
    % estimate dof one component at a time
    for c=1:K
        dof(c) = estimateDofNLL(X, mu,  Sigma, dof,  mixweight, c); % ECME
        %dof(c) = estimateDofQ(post(c,:)', s(:,c), u(:,c)); % EM
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


model.mu  = mu;
model.Sigma = Sigma;
model.mixweight = mixweight;
model.K = K;
model.dof = dof;
model.post = post;
end

function dof = estimateDofQ(z, s, u)
Nk = sum(z);
dofMax = 1000; dofMin = 0.1;
Qfn = @(v) -Nk*gammaln(v/2) + Nk*v*0.5*log(v/2) + 0.5*v*sum(z .* (s-u));
negQfn = @(v) -Qfn(v);
dof = fminbnd(negQfn, dofMin, dofMax);
end

function dof = estimateDofNLL(X, mu, Sigma, dof,  mixweight, currentK)
% optimize neg log likelihood of observed data  using constrained gradient free optimizer.
% (ECME algorithm)
dofMax = 1000; dofMin = 0.1;
nllfn = @(v) NLL(X, mu, Sigma, dof,  mixweight, currentK, v);
dof = fminbnd(nllfn, dofMin, dofMax);
end

function out = NLL(X, mu, Sigma, dof,  mixweight, currentK, v)
N = size(X,1);
ll = zeros(N,1);
dof(currentK) = v;
[post, ll] = computePost(X, mu, Sigma, dof, mixweight);%#ok
out = -sum(ll);
end

function [post, ll] = computePost(X, mu, Sigma, dof, mixweight)
N = size(X,1);
K = length(dof);
logpost = zeros(N,K);
logmixweight = log(mixweight);
for c=1:K
    model.mu = mu(:, c); model.Sigma = Sigma(:, :, c); model.dof = dof(c);
    logpost(:,c) = studentLogprob(model, X) + logmixweight(c);
end
[logpost, ll] = normalizeLogspace(logpost);
post = exp(logpost)'; % post(c, i) = responsibility for cluster c, point i
end

