function [f,g,H] = logBarrierNonNeg(w,alpha,gradFunc,lambda,varargin);
% Returns the log-barrier approximation of the objective:
%   gradFunc(w,varargin{:}) + lambda*sum(abs(w0))
%
% here, w is split into positive and negative parts

mu = 2/alpha;

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

f = f + sum(lambda.*wP) + sum(lambda.*wM) - mu*sum(log(wP)) - mu*sum(log(wM));

if nargout > 1
    g = [g;-g] + [lambda.*ones(p,1);lambda.*ones(p,1)] - mu*([wP;wM].^-1);
end

if nargout > 2
   H = [H -H;-H H] + mu*(diag([wP;wM].^-2));
end

