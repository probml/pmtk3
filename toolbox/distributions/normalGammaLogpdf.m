function out= normalGammaLogpdf(x,delta,c)
% int gauss(x|0,sigma2) Ga(sigma2|delta, c)

gamma = sqrt(2*c);
warning off
out = (delta+0.5)*log(gamma) - 0.5*log(pi) + (0.5-delta)*log(2) -gammaln(delta) ...
 + (delta-0.5)*log(abs(x)) + log(besselk(delta-0.5, gamma*abs(x)));
warning on
