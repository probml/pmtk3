function a = dirichlet_fit_s(data, a, bar_p, niter)
% DIRICHLET_FIT_S   Maximum-likelihood Dirichlet precision.
%
% DIRICHLET_FIT_S(data,a) returns the MLE (a) for the matrix DATA,
% subject to a constraint on A/sum(A).
% Each row of DATA is a probability vector.
% A is a row vector providing the initial guess for the parameters.
%
% A is decomposed into S*M, where M is a vector such that sum(M)=1,
% and only S is changed by this function.  In other words, A/sum(A)
% is unchanged by this function.
%
% The algorithm is a generalized Newton iteration, described in
% "Estimating a Dirichlet distribution" by T. Minka.

% Written by Tom Minka

show_progress = 0;

s = sum(a);
m = a/s;

% sufficient statistics
if nargin < 3
  bar_p = mean(log(data));
  addflops(numel(data)*(flops_exp + 1));
end
bar_p = sum(m.*bar_p);
K = length(bar_p);
addflops(2*K-1);

if nargin < 4
  niter = 100;
end

e = [];
for iter = 1:niter
  old_s = s;
  g = digamma(s) - sum(m.*digamma(s*m)) + bar_p;
  h = trigamma(s) - sum((m.^2).*trigamma(s*m));
  addflops(2*(flops_digamma+K+K*flops_digamma+2*K) +K+1);
  success = 0;
  if ~success & g + s*h < 0
    %s = 1/(1/s-g);
    % this is the fastest
    s = 1/(1/s + g/h/s^2);
    if s > 0
      success = 1;
    else
      s = old_s;
    end
    addflops(10);
  end
  if ~success
    % Newton on log(s)
    s = s*exp(-g/(s*h + g));
    if s > 0
      success = 1;
    else
      s = old_s;
    end
    addflops(5+flops_exp);
  end
  if ~success
    % Newton on 1/s
    s = 1/(1/s + g/(s^2*h + 2*s*g));
    if s > 0
      success = 1;
    else
      s = old_s;
    end
    addflops(10);
  end
  if ~success
    % Newton
    s = s - g/h;
    if s > 0
      success = 1;
    else
      s = old_s;
    end
    addflops(3);
  end
  if ~success
    error('all updates failed')
  end
  a = s*m;
  if show_progress
    e(iter) = sum(dirichlet_logProb(a, data));
  end
  if max(abs(s - old_s)) < 1e-6
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

end