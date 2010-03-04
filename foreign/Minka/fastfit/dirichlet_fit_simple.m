function [a,run] = dirichlet_fit_simple(data,a)
% DIRICHLET_FIT_SIMPLE   Maximum-likelihood Dirichlet distribution.
%
% Same as DIRICHLET_FIT but uses the simple fixed-point iteration described in
% "Estimating a Dirichlet distribution" by T. Minka. 

show_progress = 0; %(nargout > 1);
if nargin < 2
  a = dirichlet_moment_match(data);
end
bar_p = mean(log(data));
[N,K] = size(data);
flops(flops + prod(size(data))*(flops_exp + 1));

% fixed-pt iteration
for iter = 1:1000
  old_a = a;
  sa = sum(a);
  g = digamma(sa) + bar_p;
  a = inv_digamma(g);
  flops(flops + K-1+flops_digamma+K + K*flops_inv_digamma);
  if nargout > 1
    run.e(iter) = sum(dirichlet_logProb(a, data));
    run.flops(iter) = flops;
  end
  if max(abs(a - old_a)) < 1e-6
    break
  end
  if show_progress & rem(iter,20) == 0
    plot(run.e)
    drawnow
  end
end
if show_progress
  plot(run.e)
end

end