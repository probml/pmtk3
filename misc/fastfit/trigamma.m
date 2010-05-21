function y = trigamma(x)
%TRIGAMMA   Trigamma function.
% TRIGAMMA(X) returns trigamma(x) = d**2 log(gamma(x)) / dx**2
% If X is a matrix, returns the trigamma function evaluated at each element.

% Reference:
%
%    B Schneider,
%    Trigamma Function,
%    Algorithm AS 121,
%    Applied Statistics, 
%    Volume 27, Number 1, page 97-99, 1978.
%
% From http://www.psc.edu/~burkardt/src/dirichlet/dirichlet.f

small = 1e-4;
large = 8;
c = pi^2/6;
c1 = -2.404113806319188570799476;
b2 =  1/6;
b4 = -1/30;
b6 =  1/42;
b8 = -1/30;
b10 = 5/66;

% Initialize
y = zeros(size(x));

% illegal values
i = find(isnan(x) | (x == -inf));
if ~isempty(i)
  y(i) = nan;
end

% zero or negative integer
i = find((x <= 0) & (floor(x)==x));
if ~isempty(i)
  y(i) = Inf;
end

% Negative non-integer
i = find((x < 0) & (floor(x) ~= x));
if ~isempty(i)
  % Use the derivative of the digamma reflection formula:
  % -trigamma(-x) = trigamma(x+1) - (pi*csc(pi*x))^2
  y(i) = -trigamma(-x(i)+1) + (pi*csc(-pi*x(i))).^2;
end
  
% Small value approximation
i = find(x > 0 & x <= small);
if ~isempty(i)
  y(i) = 1./(x(i).*x(i)) + c + c1*x(i);
end

% Reduce to trigamma(x+n) where ( X + N ) >= large.
while(1)
  i = find(x > small & x < large);
  if isempty(i)
    break
  end
  y(i) = y(i) + 1./(x(i).*x(i));
  x(i) = x(i) + 1;
end

% Apply asymptotic formula when X >= large
i = find(x >= large);
if ~isempty(i)
  z = 1./(x(i).*x(i));
  y(i) = y(i) + 0.5*z + (1.0 + z.*(b2 + z.*(b4 + z.*(b6 + z.*(b8 + z.*b10))))) ./ x(i);
end
