function [A, b, c] = quadBoundBinary(name, psi, bias)
% returns A, b, c for a quadratic upper bound to log(1+exp(x + bias))
  switch name
  case 'bohning'
    A = 1/4;
    b = psi/4 - sigmoid(psi);
    c = 0.5*psi^2/4 - sigmoid(psi)*psi + log(1+exp(psi));
  case 'jaakkola'
    xi = psi;
    lambda = (sigmoid(xi) - 0.5)/(2*sign(xi)*max(abs(xi),eps));
    A = 2*lambda;
    b = -0.5;
    c = -lambda*xi^2 - 0.5*xi +log(1+exp(xi)); 
  otherwise
    error('no such bound');
  end
  % add bias correction
  c = c - b*bias + 0.5*A*bias^2;
  b = b - A*bias;


