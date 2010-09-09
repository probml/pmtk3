function[f,g,H] = aokiFn(x)
% A function from Aoki's book

% This file is from pmtk3.googlecode.com


if isvector(x)
  f = 0.5*(x(1).^2 - x(2)).^2 + 0.5*(x(1)-1).^2;
else
  f = 0.5*(x(:,1).^2 - x(:,2)).^2 + 0.5*(x(:,1)-1).^2; % each row is a param vector
end
if nargout >= 2
  g = [2*x(1)*(x(1)^2-x(2)) + x(1)-1; x(2)-x(1)^2];
end
if nargout >= 3
  H = [6*x(1)^2 - 2*x(2) + 1,  -2*x(1);
    -2*x(1), 1];
end
