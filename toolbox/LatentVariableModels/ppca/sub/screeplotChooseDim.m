function [best, ll] = screeplotChooseDim(evals)
% Use the profile likelihood method of Zhu and Ghodsi (2006) to pick L

% This file is from pmtk3.googlecode.com


Lmax = numel(evals);
ndx = 1:Lmax;
for q=1:Lmax-1
  group1 = find(ndx <= q);
  group2 = find(ndx > q);
  mu1 = mean(evals(group1));
  v1 = var(evals(group1),1);
  len1 = numel(group1);
  mu2 = mean(evals(group2));
  v2 = var(evals(group2),1);
  len2 = numel(group2);
  v = (len1*v1 + len2*v2)/Lmax; 
  ll(q) = sum(gaussLogprob(mu1, v, evals(group1))) + ...
    sum(gaussLogprob(mu2, v, evals(group2)));
end
[junk, best] = max(ll);
end

