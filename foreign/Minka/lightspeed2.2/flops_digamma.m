function fl = flops_digamma
% FLOPS_DIGAMMA   Flops for gammaln, digamma, and trigamma

% from the implementation of digamma
fl = 12*(4+flops_div)+flops_log+flops_div+13;
