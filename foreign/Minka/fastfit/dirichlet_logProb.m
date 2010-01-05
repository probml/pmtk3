function p = dirichlet_logProb(a, data)
% DIRICHLET_LOGPROB  Evaluate a Dirichlet distribution.
%
% DIRICHLET_LOGPROB(a,data) returns a vector containing the log-probability
% of each vector in DATA, under the Dirichlet distribution with parameter A.
% DATA is a matrix of probability vectors.
% If A is a row vector, then the vectors are the rows, otherwise columns.

row = (rows(a) == 1);

% add a dummy row or col
if row
  if cols(data) == length(a)-1
    data = [data 1-row_sum(data)];
  end
else
  if rows(data) == length(a)-1
    data = [data; 1-col_sum(data)];
  end
end

w = warning;
warning off
if row
  p = log(data) * (a-1)';
else
  p = (a-1)' * log(data);
end
p = p + gammaln(sum(a)) - sum(gammaln(a));
warning(w)

if row
  [N,K] = size(data);
else
  [K,N] = size(data);
end
