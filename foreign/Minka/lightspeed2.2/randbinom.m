function r = randbinom(p, n)
%RANDBINOM   Sample from a binomial distribution.
% RANDBINOM(P,N) returns a sample from a binomial distribution with 
% parameters P and N (scalars).  Each sample ranges 0 to N.
% It is more efficient than BINORND in the statistics toolbox.

%   References:
%      [1]  L. Devroye, "Non-Uniform Random Variate Generation", 
%      Springer-Verlag, 1986
%
% Also see: Kachitvichyanukul, V., and Schmeiser, B. W. 
% "Binomial Random Variate Generation." Comm. ACM, 31, 2 (Feb. 1988), 216.

% Written by Tom Minka

if isnan(p) | isnan(n)
  r = nan;
  return
end

if n < 15

  % coin flip method
  % this takes O(n) time
  r = 0;
  for i = 1:n
    if rand < p
      r = r + 1;
    end
  end

elseif n*p < 150
  
  % waiting time method
  % this takes O(np) time
  q = -log(1-p);
  r = n;
  e = -log(rand);
  s = e/r;
  while(s <= q)
    r = r - 1;
    if r == 0
      break
    end
    e = -log(rand);
    s = s + e/r;
  end
  r = n - r;
  
else

  % recursive method
  % this makes O(log(log(n))) recursive calls
  i = floor(p*(n+1));
  b = randbeta(i, n+1-i);
  if b <= p
    r = i + randbinom((p-b)/(1-b), n-i);
  else
    r = i - 1 - randbinom((b-p)/b, i-1);
  end
  
end
