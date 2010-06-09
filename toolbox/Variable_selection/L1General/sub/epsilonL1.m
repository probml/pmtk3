function [nll,g,H] = epsilonL1(w,alpha,gradFunc,lambda,varargin);
% Returns the 'epsL1' approximation of the objective:
%   gradFunc(w,varargin{:}) + lambda*sum(abs(w0))

epsilon = 1/alpha;

if nargout == 1
    [nll] = gradFunc(w,varargin{:});
elseif nargout == 2
    [nll,g] = gradFunc(w,varargin{:});
else
    [nll,g,H] = gradFunc(w,varargin{:});
end

nll = nll+sum(lambda.*sqrt(w.^2 + epsilon));

if nargout > 1
    g = g + lambda.*(w./(sqrt(w.^2+epsilon)));
end

if nargout > 2
    H = H + diag(lambda.*((w.^2+epsilon).^(-1/2) - (w.^2).*((w.^2+epsilon).^(-3/2))));
end

