function BF = bayesianTtest(x1, x2, mu_delta, sigma2_delta)
% Bayes factor for H0 (mu1=mu2) vs H1 (mu1 ~= mu2)
% where p(delta/sigma | H1, sigma2) = gauss(lambda, sigma2_delta)
% delta = mu1-mu2, and sigma2 is the common variance.
% See The Bayesian Two-Sample t Test , M. Gönen and W. Johnson and Y. Lu and P. Westfall,
% The American Statistician, 59(3), 252:257, 2005
% PMTKneedsStatsToolbox noncentraltpdf
%%

% This file is from pmtk3.googlecode.com

m1 = mean(x1); n1 = length(x1); ss1 = sum((x1-m1).^2);
m2 = mean(x2); n2 = length(x2); ss2 = sum((x2-m2).^2);
nd = 1/((1/n1) + (1/n2));
t = (m1-m2)/sqrt( (1/nd)*(ss1 + ss2)/(n1+n2-2) );

if nargin < 3
  % default hyper-params set according to p10 of their paper
  %mu_delta = 2.80/sqrt(nd);
  %sigma2_delta = (2.19/sqrt(nd))^2;
  % more agnostic version - see p12
  mu_delta = 0;
  %sigma2_delta = (1/3)^2;
  sigma2_delta = 100;
end

dof = n1+n2-2;
BF = noncentraltpdf(t, dof, 0, 1)/...
     noncentraltpdf(t, dof, sqrt(nd)*mu_delta, 1+nd*sigma2_delta);

