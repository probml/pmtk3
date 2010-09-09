function [Rhat, m, s] = epsr(samples)
% EPSR "estimated potential scale reduction" statistic due to Gelman and Rubin.
%
% Inputs
% samples(i,j) for sample i, chain j
%
% Outputs
% Rhat = measure of scale reduction - value below 1.1 means converged:
% m = mean(samples)
% s = std(samples)

% This file is from pmtk3.googlecode.com


[n m] = size(samples);
meanPerChain = mean(samples,1); % each column of samples is a chain
meanOverall = mean(meanPerChain);

% Rhat only works if more than one chain is specified.
if m > 1
  % between sequence variace
  B = (n/(m-1))*sum( (meanPerChain-meanOverall).^2);

  % within sequence variance
  varPerChain = var(samples);
  W = (1/m)*sum(varPerChain);

  vhat = ((n-1)/n)*W + (1/n)*B;
  Rhat = sqrt(vhat/(W+eps));
else
  Rhat = nan;
end
m = meanOverall;
s = std(samples(:));

end
