function p = normpdfln(x, m, S, V)
% NORMPDFLN    log of multivariate normal density.
%   See NORMPDF for argument description.

log2pi = 1.83787706640935;
[d, n] = size(x);
if nargin == 1
  dx = x;
elseif isempty(m)
  dx = x;
else
  % m specified
  sz = size(m);
  if sz(1) ~= d
    error('rows(m) ~= rows(x)')
  end
  nm = sz(2);
  if nm == 1
    dx = x - repmat(m,1,n);
  elseif n == 1
    dx = repmat(x,1,nm) - m;
  elseif nm == n
    dx = x - m;
  else
    error('incompatible number of columns in x and m')
  end
end
if nargin < 3
  % unit variance
  p = -0.5*(d*log2pi + col_sum(dx.*dx));
  return
end
have_inv = 0;
if nargin == 3
  % standard deviation given
  if d == 1
    dx = dx./S;
    p = (-log(S) -0.5*log2pi) - 0.5*(dx.*dx);
    return;
  end
  if S(2,1) ~= 0
    error('S is not upper triangular')
  end
  if any(size(S) ~= [d d])
    error('S is not the right size')
  end
else
  if ischar(V)
    if strcmp(V,'inv')
      % inverse stddev given
      iS = S;
      have_inv = 1;
    else
      error('unknown directive')
    end
  elseif ischar(S) 
    if strcmp(S,'inv')
      % inverse variance given
      if d == 1
	iS = sqrt(V);
      else
	iS = chol(V);
      end
      have_inv = 1;
    else
      error('unknown directive')
    end
  else
    % variance given
    if d == 1
      S = sqrt(V);
    else
      S = chol(V);
    end
  end
end
if have_inv
  if d == 1
    dx = iS .* dx;
    logdetiS = log(iS);
  else
    dx = iS*dx;
    logdetiS = sum(log(diag(iS)));
  end
else
  if d == 1
    dx = dx./S;
    logdetiS = -log(S);
  else
    dx = solve_tril(S',dx);
    %dx = S'\dx;
    logdetiS = -sum(log(diag(S)));
  end
end
p = (logdetiS -0.5*d*log2pi) -0.5*col_sum(dx.*dx);
