function y = digamma(x)
% Digamma function: d/dx log gamma(x)
% DIGAMMA(X) returns digamma(x) = d log(gamma(x)) / dx
% If X is a matrix, returns the digamma function evaluated at each element.

y = psi(x); % built-in mex function
end



    