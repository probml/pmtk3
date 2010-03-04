function [a,run] = dirichlet_fit(data,a)
% DIRICHLET_FIT   Maximum-likelihood Dirichlet distribution.
%
% DIRICHLET_FIT(data) returns the MLE (a) for the matrix DATA.
% Each row of DATA is a probability vector.
% DIRICHLET_FIT(data,a) provides an initial guess A to speed up the search.
%
% The Dirichlet distribution is parameterized as
%   p(p) = (Gamma(sum_k a_k)/prod_k Gamma(a_k)) prod_k p_k^(a_k-1)
%
% The algorithm is an alternating optimization for m and for s, described in
% "Estimating a Dirichlet distribution" by T. Minka.

% Written by Tom Minka

bar_p = mean(log(data));
[N,K] = size(data);
addflops(numel(data)*(flops_exp + 1));
if nargin < 2
  a = dirichlet_moment_match(data);
  %s = dirichlet_initial_s(a,bar_p);
  %a = s*a/sum(a);
end

s = sum(a);
if s <= 0
  % bad initial guess; fix it
  disp('fixing initial guess')
  if s == 0
    a = ones(size(a))/length(a);
  else
    a = a/s;
  end
  s = 1;
end
for iter = 1:100
  old_s = s;
  % time for fit_s is negligible compared to fit_m
  a = dirichlet_fit_s(data, a, bar_p);
  s = sum(a);
  a = dirichlet_fit_m(data, a, bar_p, 1);
  m = a/s;
  addflops(2*K-1);
  if nargout > 1
    run.e(iter) = N*dirichlet_logProb_fast(a, bar_p);
    run.flops(iter) = flops;
  end
  if abs(s - old_s) < 1e-4
    break
  end
end
%flops(flops + iter*(2*K-1));
end