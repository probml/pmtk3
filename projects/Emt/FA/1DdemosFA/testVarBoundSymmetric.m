function [margLik1, margLik2]  = testVarBoundSymmetric()
% Test if varbound gives the same results for various parameter settings which
% give same likelihood.
% e.g. parameter set (beta, bias, mu, sigma2) gives same likelihood as
% (beta*sqrt(sigma2)), bias + beta*mu, 0, 1)
% In this code, we plot the marglik for various settings of variational
% parameter, and show that both give the same marglik
% Written by Emtiyaz
% Nov. 22, 2010

  vals = [-10:.1:10];

  beta = 1;
  bias = 1;
  sigma2 = 2^2;
  mu = 2;
  for i = 1:length(vals)
    margLik1(i) = margLik(vals(i), beta, bias, mu, sigma2);
  end

  beta = 2;
  bias = 1 + 2;
  sigma2 = 1;
  mu = 0;
  for i = 1:length(vals)
    margLik2(i) = margLik(vals(i), beta, bias, mu, sigma2);
  end

  plot(vals, margLik1, 'bx','linewidth',2);
  hold on
  plot(vals, margLik2, 'r','linewidth',2);
  xlabel('psi');
  ylabel('p(y=1|theta)');
  legend('bias=0, mu = 1','bias=1, mu = 0');

function logLik = margLik(psi, beta, bias, mu, sigma2)

    [A,b,c] = quadBoundBinary('bohning',psi, bias);
    V = inv(A*beta^2 + 1/sigma2);
    m = V*((b+1)*beta + mu/sigma2);
    logLik = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + bias - mu^2/(2*sigma2));
