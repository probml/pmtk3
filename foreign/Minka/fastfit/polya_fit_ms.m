function a = polya_fit_ms(data, a, weight)
% POLYA_FIT_MS   Maximum-likelihood Polya distribution.
%
% Same as POLYA_FIT but uses alternating optimization for M and S.
% DATA is a matrix of histograms, oriented the same way as A.

% Written by Tom Minka

if nargin < 2
  a = polya_moment_match(data);
end

% alternate between polya_fit_m and polya_fit_s
use_weight = (nargin >= 3);
row = (rows(a) == 1);
if row
  N = rows(data);
  if ~use_weight
    weight = ones(N,1);
  end
else
  N = cols(data);
  if ~use_weight
    weight = ones(1,N);
  end
end
s = sum(a);
for iter = 1:10
  old_s = s;
  a = polya_fit_m(data, a, weight);
  m = a/s;
  a = polya_fit_s(data, a, weight);
  s = sum(a);
  if ~finite(s)
    s = 1e7;
    obj.a = s*m;
  end
  if abs(s - old_s) < 1e-4
    break
  end
end
