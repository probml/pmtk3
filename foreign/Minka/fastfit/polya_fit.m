function a = polya_fit(data, a)
% POLYA_FIT    Maximum-likelihood Dirichlet-multinomial (Polya) distribution.
%
% POLYA_FIT(data) returns the MLE (a) for the matrix DATA.
% Each row of DATA is a histogram of counts.
% POLYA_FIT(data,a) provides an initial guess A to speed up the search.
%
% The Polya distribution is parameterized as
%  p(x) = (Gamma(sum_k a_k)/prod_k Gamma(a_k)) prod_k Gamma(x_k+a_k)/Gamma(a_k)
%
% The algorithm is Newton iteration, described in
% "Estimating a Dirichlet distribution" by T. Minka.

% Written by Tom Minka

show_progress = 0;

if nargin < 2
  a = polya_moment_match(data);
end
ok = (col_sum(data) > 0);
if ~all(ok)
  a(ok) = polya_fit(data(:,ok), a(ok));
  return
end
sdata = row_sum(data);

% Newton-Raphson
old_e = sum(polya_logProb(a, data));
lambda = 0.1;
e = [];
for iter = 1:100
  if sum(a) == 0
    break
  end
  g = gradient2(a, data, sdata);
  abort = 0;
  % Newton iteration
  % loop until we get a nonsingular hessian matrix
  while(1)
    hg = hessian_times_gradient2(a, data, sdata, g, lambda);
    if all(hg < a)
      e(iter) = sum(polya_logProb(a-hg, data));
      if(e(iter) > old_e)
	old_e = e(iter);
	a = a - hg;
	lambda = lambda/10;
	break
      end
    end
    lambda = lambda*10;
    if lambda > 1e+6
      abort = 1;
      break
    end
  end
  if abort
    %disp('Search aborted')
    e(iter) = old_e;
    break
  end
  a(find(a < eps)) = eps;
  if max(abs(g)) < 1e-16
    break
  end
  if show_progress & rem(iter,5) == 0
    plot(e)
    drawnow
  end
end
if show_progress 
  disp(['gradient at exit = ' num2str(max(abs(g)))])
  plot(e)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function g = gradient(a, data, sdata)

N = rows(data);
g = zeros(size(a));
sa = sum(a);
for i = 1:N
  g = g + digamma(data(i,:) + a);
end
g = g - sum(digamma(sdata + sa));
g = g + N*(digamma(sa) - digamma(a));
% scale for numerical stability
g = g/N;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function g = gradient2(a, data, sdata)
% same as above but handles sparse data

N = rows(data);
g = zeros(size(a));
sa = full(sum(a));
for i = 1:N
  j = (data(i,:) > 0);
  g(j) = g(j) + di_pochhammer(a(j),data(i,j));
end
g = g - sum(di_pochhammer(sa,sdata));
% scale for numerical stability
g = g/N;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hg = hessian_times_gradient(a, data, sdata, g, lambda)

N = rows(data);
sa = full(sum(a));
q = -N*trigamma(a);
for i = 1:N
  q = q + trigamma(data(i,:) + a);
end
q = q/N;
z = trigamma(sa) - mean(trigamma(sdata + sa));
q = q - lambda;
q = 1./q;
b = sum(g .* q)/(1/z + sum(q));
hg = (g - b).*q;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hg = hessian_times_gradient2(a, data, sdata, g, lambda)
% same as above but handles sparse data

N = rows(data);
sa = full(sum(a));
q = zeros(size(a));
for i = 1:N
  j = (data(i,:) > 0);
  q(j) = q(j) + tri_pochhammer(a(j),data(i,j));
end
q = q/N;
z = -mean(tri_pochhammer(sa,sdata));
q = q - lambda;
q = 1./q;
b = sum(g .* q)/(1/z + sum(q));
hg = (g - b).*q;
% apply the constraint a >= 0
%hg(a == 0) = 0;
end