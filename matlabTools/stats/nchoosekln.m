function nk = nchoosekln(n, k)
% p(i) = ln nchoosek(n(i), k(i))

% This file is from pmtk3.googlecode.com


% n! = gamma(n+1)
nk = gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1);

if 0 % debug
  for i=1:length(n)
    nk2(i) = log(nchoosek(n(i), k(i)));
  end
  assert(approxeq(nk, nk2))
end         
end
