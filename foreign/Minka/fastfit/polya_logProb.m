function p = polya_logProb(a, data)
% POLYA_LOGPROB   Dirichlet-multinomial (Polya) distribution.
%
% POLYA_LOGPROB(a,data) returns a vector containing the log-probability of 
% each histogram in DATA, under the Polya distribution with parameter A.
% DATA is a matrix of histograms.
% If A is a row vector, then the histograms are the rows, otherwise columns.

if any(a < 0)
  p = -Inf;
  return
end
row = (rows(a) == 1);

s = full(sum(a));
if row
  sdata = row_sum(data);
  p = zeros(rows(data),1);
  for k = 1:cols(data)
    dk = data(:,k);
    p = p + pochhammer(a(k), dk);
  end
  p = p - pochhammer(s, sdata);
else
  sdata = col_sum(data);
  for i = 1:cols(data)
    p(i) = sum(gammaln(data(:,i) + a)) - gammaln(sdata(i) + s);
  end
  p = p + gammaln(s) - sum(gammaln(a));
end
