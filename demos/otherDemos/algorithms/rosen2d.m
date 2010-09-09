%% 2D Rosenbrock Function
%
%%

% This file is from pmtk3.googlecode.com

function [f g H] = rosen2d(x)

if nargin == 0;
   [f g H] = rosen2d(randn(100, 1));
   return
end

if isvector(x)
  f = 100*(x(2) - x(1)^2)^2 + (1-x(1))^2; % row or column vector
else
  f = 100*(x(:,2) - x(:,1).^2).^2 + (1-x(:,1)).^2; %  each row of x is an input
end
if nargout > 1 % column vector
  g = [-400*(x(2)-x(1)^2)*x(1)-2*(1-x(1));
    200*(x(2)-x(1)^2)];
end
if nargout > 2 % 2x2 matrix
  H = [1200*x(1)^2-400*x(2)+2, -400*x(1);
    -400*x(1), 200];
end

end
