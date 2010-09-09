function [mbest, mu, sigma] = exhaustiveSearch(models, scoreFn, varargin)
% Exhaustively search for best model: mbest = arg max_i scoreFn(models{i})
% If useStdErrorRule=1, we pick the simplest which is within
% 1 std error of the best

% This file is from pmtk3.googlecode.com


N = length(models);
mu = zeros(1,N); sigma = zeros(1,N);
[maximize, useStdErrorRule, complexity, computeStdErr] = process_options(...
  varargin, 'maximize', true, 'useStdErrorRule', false, ...
  'complexity', 1:N, 'computeStdErr', true);

for i=1:N
  if computeStdErr
    [mu(i), sigma(i)] = scoreFn(models{i});
  else
     mu(i) = scoreFn(models{i});
  end
end

if maximize
  mu = -mu; % min_i -score(i) = max_i score(i)
end
if useStdErrorRule
  ndx = oneStndErrorRule(mu, stderr, complexity);
else
  ndx = argmin(mu);
end

mbest = models{ndx};

end
