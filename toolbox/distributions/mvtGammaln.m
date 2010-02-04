function [ln_mvt_gamma]=mvtGammaln(n, alpha)
% returns the log of multivariate gamma(n, alpha) value.
% necessary for avoiding underflow/overflow problems
% alpha > (n-1)/2
% from Muirhead pp 61-62.
%sum_terms=0;
%for i=1:n
%  term_i=gammaln(alpha-.5*(i-1));
%  sum_terms=sum_terms+term_i;
%end
ln_mvt_gamma=((n*(n-1))/4)*log(pi)+sum(gammaln(alpha-0.5*([1:n] - 1)));
%assert(approxeq(ln_mvt_gamma, ((n*(n-1))/4)*log(pi)+sum_terms));
%ln_mvt_gamma = ((n*(n-1))/4)*log(pi)+sum_terms;