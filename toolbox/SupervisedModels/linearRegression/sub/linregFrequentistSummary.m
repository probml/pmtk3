function [w, stderr, pval, R2, sigma2, confint, Zscore] = linregParamsFrequentist(y, XX, names, useLatex)
% Frequentist inference for regression weights in a linear regression model.
% This is similar to  R's lm function or Matlab's regress function.
% Each row ox X is a training case, excluding the first column of 1s

% This file is from pmtk3.googlecode.com

[n d] = size(XX);

if nargin < 3 || isempty(names)
  for i=1:d
    names{i} = sprintf('x%d: ', i);
  end
end
if nargin <4, useLatex = false; end

X = [ones(n,1) XX];
w = X\y; % mle
yhat = X*w;
rss = sum((y - yhat).^2);
R2 = 1-rss/sum((y-mean(y)).^2);
sigma2 = rss/(n-d-1); % unbiased estimate
Sigma = pinv(X'*X)*sigma2; % covariance matrix of w
stderr = sqrt(diag(Sigma));
Zscore = w ./ stderr;
dof = n-d-1;
pval = 1-tcdfPMTK(abs(Zscore),dof) + tcdfPMTK(-abs(Zscore),dof);

alpha = 0.95;
tc = tinvPMTK(1-(1-alpha)/2, dof); 
confint = [w-tc*stderr w+tc*stderr];

names2 = {'intercept', names{:}};
fprintf('\nlinear regression n=%d, d=%d, R-squared=%10.5f\n\n', n, d, R2);


fprintf('%10s %10s %10s %10s %10s %5s\n', ...
	'', 'estimate', 'std err', 't value', 'p(>|t|)', '');

for i=1:d+1
  if pval(i) > 0 & pval(i) < 0.001
    str = '***';
  elseif pval(i) >= 0.001 & pval(i) < 0.01
    str = '**';
  elseif pval(i) >= 0.01 & pval(i) < 0.05
    str = '*';
  elseif pval(i) >= 0.05 & pval(i) < 0.1
    str = '.';
  else str = '';
  end
  if useLatex
    fprintf('%10s & %10.5f & %10.5f & %10.5f & %10.5f %s\\\\\n', ...
      names2{i}, w(i), stderr(i), Zscore(i),  pval(i), str);
  else
    fprintf('%10s %10.5f %10.5f %10.5f %10.5f %s\n', ...
      names2{i}, w(i), stderr(i), Zscore(i),  pval(i), str);
  end
  
end


fprintf('\nSignif. codes: *** [0,0.001), ** [0.001, 0.01), * [0.01,0.05) . [0.05,1)\n');

end
