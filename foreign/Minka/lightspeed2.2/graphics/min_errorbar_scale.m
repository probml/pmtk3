function c = min_errorbar_scale(stderrs,significance)
% c = min_errorbar_scale(stderrs,significance) 
% returns the minimum scale factor c such that any pair of non-overlapping
% error bars represents statistical significance exceeding the given level.
% stderrs is a vector.
% significance is a scalar.
%
% See "Judging significance from error bars" by Tom Minka (2002) 
% http://research.microsoft.com/~minka/papers/minka-errorbars.pdf
%
% Examples:
%   min_errorbar_scale(ones(10,1))  % returns 1.16
%   min_errorbar_scale(0:10)        % returns 1.64

% Written by Tom Minka

% Algorithm:
% We want c*(stderr(i)+stderr(j)) >= z*sqrt(stderr(i)^2+stderr(j)^2)
% for all pairs (i,j).  Therefore
% c = max_(i,j)  z*sqrt(stderr(i)^2+stderr(j)^2)/(stderr(i) + stderr(j));

if nargin < 2
  significance = 0.95;
end

z = erfinv(2*significance - 1)*sqrt(2);

n = length(stderrs);
ratio = zeros(n,1);
for i = 1:length(stderrs)
  exact = sqrt(stderrs(i).^2 + stderrs.^2);
  approx = stderrs(i) + stderrs;
  ratio(i) = max(exact./approx);
end
c = z*max(ratio);
