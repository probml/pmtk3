%% Convergence Rate Demo
%
%%

% This file is from pmtk3.googlecode.com

for ki=1:11
  k = ki-1;
  theta(ki) = 1 + (1/2)^k;
  fprintf('%d | %10.10f\n', k, theta(ki));
end
