function a = dirichlet_fit_m(data, a, bar_p, niter)
% DIRICHLET_FIT_M   Maximum-likelihood Dirichlet mean.
%
% DIRICHLET_FIT_M(data,a) returns the MLE (a) for the matrix DATA,
% subject to a constraint on sum(A).
% Each row of DATA is a probability vector.
% A is a row vector providing the initial guess for the parameters.
% A is decomposed into S*M, where M is a vector such that sum(M)=1,
% and only M is changed by this function.  In other words, sum(A)
% is unchanged by this function.
%
% The algorithm is a generalized Newton iteration, described in
% "Estimating a Dirichlet distribution" by T. Minka.

% Written by Tom Minka

show_progress = 0;
diter = 4;

% sufficient statistics
if nargin < 3
  bar_p = mean(log(data));
  addflops(numel(data)*(flops_exp + 1));
end
%slr = bar_p - sum(bar_p)/length(a);
if nargin < 4
  niter = 1000;
end

e = [];
for iter = 1:niter
  sa = sum(a);
  old_a = a;
  if 1
    % convergence is guaranteed for any w, but this one is fastest
    w = a/sa;
    g = sum(w.*(digamma(a)-bar_p)) + bar_p;
    %g = sum(digamma(a))/length(a) + slr;
    a = inv_digamma(g,diter);
    % project back onto the constraint
    a = a/sum(a)*sa;
    
    K = length(a);
    addflops(K+K*(flops_digamma+4)+ K*flops_inv_digamma(diter) +2*K+1);
  else
    % gradient descent
    g = bar_p - digamma(a);
    if 0
      % symmetric normalization
      g = g - sum(g)/length(g);
    else
      % asymmetric normalization
      g = g - g(length(g));
      g(length(g)) = -sum(g);
    end
    a = a + g*0.1;
  end
  if show_progress
    e(iter) = sum(dirichlet_logProb(a, data));
  end
  if max(abs(a - old_a)) < 1e-6
    break
  end
  if show_progress & rem(iter,20) == 0
    figure(2)
    plot(e)
    drawnow
  end
end
if show_progress
  figure(2)
  plot(e)
end
