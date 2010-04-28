function fl = flops_inv_digamma(niter)

if nargin < 1
  niter = 5;
end
fl = (1+niter*2)*flops_digamma + 3 + niter*3;
end