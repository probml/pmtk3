function a = polya_fit_simple(data,a)
% POLYA_FIT_SIMPLE   Maximum-likelihood Polya distribution.
%
% Same as POLYA_FIT but uses the simple fixed-point iteration described in
% "Estimating a Dirichlet distribution" by T. Minka. 

show_progress = 0;

if nargin < 2
  a = polya_moment_match(data);
end
sdata = sum(data, 2);

% fixed-point iteration
[N,K] = size(data);
for iter = 1:1000
  old_a = a;
  sa = sum(a);
  if 0
    g = col_sum(digamma(data + repmat(a, N, 1))) - N*digamma(a);
    h = sum(digamma(sdata + sa)) - N*digamma(sa);
  else
    g = col_sum(di_pochhammer(repmat(a, N, 1), data));
    h = sum(di_pochhammer(sa, sdata));
  end
  a = a .* g ./ h;
  if show_progress
    e(iter) = sum(polya_logProb(a, data));
  end
  if max(abs(a - old_a)) < 1e-6
    break
  end
  if show_progress & rem(iter,10) == 0
    plot(e)
    drawnow
  end
end  
if show_progress
  plot(e)
end

end