function [model, logev] = linregNetlabFit(X, y, alpha)
% PMTK interface to netlab
% X is n*d, y is d*1
% Do not add a column of 1s
% alpha is fixed, beta is optimized
% Computes log marginal likelihood with Gaussian prior

% This file is from pmtk3.googlecode.com


x = X; targets = y; 
% Compute posterior p(w|D,alpha) and estimate beta
[n,d] = size(x);
nin = d;
nout = 1;
beta_init = 1;
net = glm(nin, nout, 'linear', alpha, beta_init);
% MAP estimate of w
net = glmtrain(net, foptions(), x, targets); %#ok
% estimate beta and logev, do not change alpha
[net, gamma, logev] = evidenceFixedAlpha(net, x, targets);
model.netlab = net;
model.effnparams = gamma;
      
% Need to compute inverse hessian so we can get error bars
w = netpak(model.netlab);
hess = nethess(w, model.netlab, X, y);
invhess = inv(hess);
model.wMu = w;
model.wCov = invhess;
model.sigma2 = 1/model.netlab.beta;
end

%%

function [net, gamma, logev] = evidenceFixedAlpha(net, x, t)
% evidenceFixedAlpha: compute max_beta log p(y|X,alpha, beta)
% This is the same as the evidence functoion except alpha is fixed, not
% estimated. Currently only works for scalar alpha.

errstring = consist(net, '', x, t);
if ~isempty(errstring)
  error(errstring);
end


ndata = size(x, 1);
if nargin == 3
  num = 1;
end

% Extract weights from network
w = netpak(net);

% Evaluate data-dependent contribution to the Hessian matrix.
[h, dh] = nethess(w, net, x, t); 
clear h;  % To save memory when Hessian is large
if (~isfield(net, 'beta'))
  local_beta = 1;
end

[evec, evl] = eig(dh);
% Now set the negative eigenvalues to zero.
evl = evl.*(evl > 0);
% safe_evl is used to avoid taking log of zero
safe_evl = evl + eps.*(evl <= 0);

[e, edata, eprior] = neterr(w, net, x, t);


if size(net.alpha) == [1 1]
  % Form vector of eigenvalues
  evl = diag(evl);
  safe_evl = diag(safe_evl);
else
  ngroups = size(net.alpha, 1);
  gams = zeros(1, ngroups);
  logas = zeros(1, ngroups);
  % Reconstruct data hessian with negative eigenvalues set to zero.
  dh = evec*evl*evec';
end

num = 1; % KPM - no need to iterate
for k = 1 : num
  if size(net.alpha) == [1 1]
    % Evaluate number of well-determined parameters.
    L = evl;
    if isfield(net, 'beta')
      L = net.beta*L;
    end
    gamma = sum(L./(L + net.alpha));
    % net.alpha = 0.5*gamma/eprior; % do not update alpha KPM
    % Partially evaluate log evidence: only include unmasked weights
    logev = 0.5*length(w)*log(net.alpha);
  else
    hinv = inv(hbayes(net, dh));
    for m = 1 : ngroups
      group_nweights = sum(net.index(:, m));
      gams(m) = group_nweights - ...
	        net.alpha(m)*sum(diag(hinv).*net.index(:,m));
      net.alpha(m) = real(gams(m)/(2*eprior(m)));
      % Weight alphas by number of weights in group
      logas(m) = 0.5*group_nweights*log(net.alpha(m));
    end 
    gamma = sum(gams, 2);
    logev = sum(logas);
  end
  % Re-estimate beta.
  if isfield(net, 'beta')
      net.beta = 0.5*(net.nout*ndata - gamma)/edata;
      logev = logev + 0.5*ndata*log(net.beta) - 0.5*ndata*log(2*pi);
      local_beta = net.beta;
  end
  
  % Evaluate new log evidence
  e = errbayes(net, edata);
  if size(net.alpha) == [1 1]
    logev = logev - e - 0.5*sum(log(local_beta*safe_evl+net.alpha));
  else
    for m = 1:ngroups  
      logev = logev - e - ...
	  0.5*sum(log(local_beta*(safe_evl*net.index(:, m))+...
	  net.alpha(m)));
    end
  end
end
end

