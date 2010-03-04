function p = dirichlet_logProb_fast(a, bar_p)

p = gammaln(sum(a)) - sum(gammaln(a)) + sum((a-1).*bar_p);
K = length(a);
flops(flops + (K+1)*flops_digamma + 3*K);

end