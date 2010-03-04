function a = polya_fit_m(data, a, weight)
% POLYA_FIT_M   Maximum-likelihood Dirichlet-multinomial (Polya) mean.
%
% POLYA_FIT_M(data,a) returns the MLE (a) for the matrix DATA,
% subject to a constraint on sum(A).
% Each row of DATA is a histogram of counts.
% A is a row vector providing the initial guess for the parameters.
%
% POLYA_FIT_M(data,a,weight) returns the MLE where each histogram is weighted.
% WEIGHT is a column vector of numbers in [0,1] (default all ones).
%
% A is decomposed into S*M, where M is a vector such that sum(M)=1,
% and only M is changed by this function.  In other words, sum(A)
% is unchanged by this function.
%
% The algorithm is a generalized Newton iteration, described in
% "Estimating a Dirichlet distribution" by T. Minka.

% Written by Tom Minka


s = sum(a);
m = a/s;
[N,K] = size(data);

use_weight = (nargin > 2);
row = (rows(a) == 1);

for iter = 1:20
  old_m = m;
  if row
    a = s*m;
    for k = 1:length(m)
      dk = data(:,k);
      vdk = a(k)*di_pochhammer(a(k), dk);
      if use_weight
	vdk = vdk .* weight;
      end
      m(k) = sum(vdk);
    end
  else
    a = repmat(s*m, 1, N);
    vdata = a.*di_pochhammer(a, data);
    if use_weight
      vdata = vdata .* repmat(weight, rows(vdata), 1);
    end
    m = row_sum(vdata);
  end
  m = m ./ sum(m);
  if max(abs(m - old_m)) < 1e-4
    break
  end
end
a = s*m;

end