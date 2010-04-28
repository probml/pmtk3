function [a,run] = dirichlet_fit_newton(data,a)
% DIRICHLET_FIT_NEWTON   Maximum-likelihood Dirichlet distribution.
%
% Same as DIRICHLET_FIT but uses the Newton iteration described in
% "Estimating a Dirichlet distribution" by T. Minka. 

% Written by Tom Minka

show_progress = (nargout > 1);

bar_p = mean(log(data));
[N,K] = size(data);
addflops(numel(data)*(flops_exp + 1));
if nargin < 2
  a = dirichlet_moment_match(data);
  %s = dirichlet_initial_s(a,bar_p);
  %a = s*a/sum(a);
end

old_e = N*dirichlet_logProb_fast(a, bar_p);
lambda = 0.1;
run.e = [];
for iter = 1:100
  old_a = a;
  if sum(a) == 0
    break
  end
  g = digamma(sum(a)) - digamma(a) + bar_p;
  addflops(K-1+(K+1)*flops_digamma + 2*K);
  abort = 0;
  % Newton iteration
  % loop until we get a nonsingular hessian matrix
  while(1)
    hg = hessian_times_gradient(a, g, lambda);
    addflops(2*K);
    if all(hg < a)
      run.e(iter) = N*dirichlet_logProb_fast(a-hg, bar_p);
      addflops(2);
      if(run.e(iter) > old_e)
	old_e = run.e(iter);
	a = a - hg;
	lambda = lambda/10;
	addflops(K+1);
	break
      end
    end
    lambda = lambda*10;
    addflops(3);
    if lambda > 1e+6
      abort = 1;
      break
    end
  end
  if nargout > 1
    run.flops(iter) = flops;
  end
  if abort
    %disp('Search aborted')
    run.e(iter) = old_e;
    break
  end
  a(find(a < eps)) = eps;
  if max(abs(a - old_a)) < 1e-10
    %max(abs(g)) < 1e-16
    break
  end
  if show_progress & rem(iter,5) == 0
    plot(run.e)
    drawnow
  end
end
if show_progress 
  %disp(['gradient at exit = ' num2str(max(abs(g)))])
  plot(run.e)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hg = hessian_times_gradient(a, g, lambda)

sa = sum(a);
q = -trigamma(a);
z = trigamma(sa);
q = q - lambda;
q = 1./q;
b = sum(g .* q)/(1/z + sum(q));
hg = (g - b).*q;

K = length(a);
addflops(K-1 + (K+1)*flops_digamma + 1 + 7*K);
end