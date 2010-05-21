function [f,g,H] = nonNegGrad(w,lambda,gradFunc,varargin)
% The objective function and derivatives when using a re-formulation
%   into positive and negative parts

p = length(lambda);
wP = w(1:p);
wM = w(p+1:end);
w = wP-wM;

if nargout == 1
    f = gradFunc(w,varargin{:});
elseif nargout == 2
    [f,g] = gradFunc(w,varargin{:});
else
    [f,g,H] = gradFunc(w,varargin{:});
end

f = f + sum(lambda.*wP) + sum(lambda.*wM);

if nargout > 1
    g = [g;-g] + [lambda.*ones(p,1);lambda.*ones(p,1)];
end

if nargout > 2
    H = [H -H;-H H];
end
