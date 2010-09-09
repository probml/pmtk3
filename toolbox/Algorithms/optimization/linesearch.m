function  [xn,Fn,gn,info,perf] = ...
    linesearch(fun, x,F,g, h, opts, varargin)
%LINESEARCH  Find  am = argmin_a{F(x+a*h)} , where  x  and  h  are
% n-vectors and the scalar function  F and its gradient  g  (with
% elements  g(i) = DF/Dx_i ) must be given by a MATLAB function
% with declaration
%            function  [F, g] = fun(x,p1,p2,...)
% p1,p2,... are parameters of the function.
%
%  Call
%    [xn,Fn,gn,info] = linesearch(fun,x,F,g,h)
%    [xn,Fn,gn,info] = linesearch(fun,x,f,g,h,opts,p1,p2,...)
%    [xn,Fn,gn,info,perf] = linesearch(......)
%
% Input parameters
% fun  :  Handle to the function.
% x    :  Offset x.
% F,g  :  F(x) and g(x).
% h    :  Step vector.
% opts :  Vector with at most 5 elements.
%         opts(1)   :  Choice of method:
%                      opts(1) = 0 : exact line search,
%                      otherwise   : soft line search.  (Default).
%         opts(2:3) :  parameters for the stopping criteria
%                      Default: [1e-3  1e-3]  if opts(1) = 0
%                               [1e-3  0.99]  otherwise.
%         opts(4)   :  Maximum number of function evaluations.
%                      Default: 10.
%         opts(5)   :  Maximal allowable step,  a_max .   Default: 10.
%         If the input opts has less than 5 elements, it is augmented
%         by the default values.
% p1,p2,..  are passed dirctly to the function FUN .
%
% Output parameters
% xn    :  x + am*h
% Fn,gn :  f(xn) and g(xn).
% info  :  Vector with 3 elements
%          info(1) >  0 : am.  Successfull call
%                  =  0 : h is not downhill or it is so large and opts(4)
%                         so small, that a better point was not found.
%                  = -1 : x is not a real valued vector.
%                  = -2 : F is not a real valued scalar.
%                  = -3 : g or h is not a real valued vector.
%                  = -4 : g or h has different length from x.
%          info(2) = slope ratio at xn, see Method below.
%          info(3) = number of function evaluations used.
% perf  :  Array, holding
%          perf(1,:) = values of  a,
%          perf(2,:) = values of  F(x+a*h),
%          perf(3,:) = values of  U'(a) (see Method below).
%
% Method
% http://www2.imm.dtu.dk/~hbn/publ/
% Described in Sections 2.5 - 2.6 of  Frandsen, Jonasson, Nielsen and
% Tingleff: "Unconstrained Optimization".  Let
%     U(a) = F(x + a*h) , implying  U'(a) = h' * grad(x + a*h).
% If the number of function evaluations does not exceed kmax = opts(4),
% and a does not exceed a_max = opts(5), then the computed step
% satisfies the following two conditions:
% if  opts(1) = 0  (exact line search) :
%       |U'(am)| <= opts(2) * |U'(0)|  or  b-a <= opts(3) * b
%   where  [a,b] is the current interval for am.
% Otherwise  (soft line search)  (Default)
%     U(am) <= U(0) + am*opts(2)*U'(0)  and  U'(am) >= opts(3)*U'(0) .
%
% In both cases  info(2) = U'(am)/U'(0) .

% This file is from pmtk3.googlecode.com


%PMTKauthor Hans Bruun Nielsen
%PMTKurl http://www2.imm.dtu.dk/~hbn/immoptibox/

% Version 04.02.02.  hbn(a)imm.dtu.dk

% Initial check
if  nargin < 5,  error('Too few input parameters'), end

% Check OPTS
if  nargin < 6 | isempty(opts),  opts = 1; end
if  opts(1) == 0,  opts = checkopts(opts, [0  1e-3  1e-3  10 10]);
else,              opts = checkopts(opts, [1  1e-3  0.99  10 10]); end

% Default return values and simple checks
xn = x;  Fn = F;   gn = g;  info = [0 1 0];
[stop  n] = check(x,F,g,h);
if  stop,  info(1) = stop;  return, end

x = x(:);   h = h(:);  % both are treated as column vectors
Trace = nargout > 4;
if  Trace,  perf = [[0 Fn dF0]' zeros(3,kmax)]; end

% Check descent condition
dF0 = dot(h,gn);   kmax = opts(4);
if  dF0 >= -10*eps*norm(h)*norm(gn)  % not significantly downhill
    if  Trace,  perf = perf(:,1); end
    return
end

% Finish initialization
F0 = F;  soft = opts(1) ~= 0;
if  soft
    slope0 = opts(2)*dF0;   slopethr = opts(3)*dF0;
else
    slope0 = 0;   slopethr = opts(2)*abs(dF0);
end

% Get an initial interval for am
a = 0;  Fa = Fn;  dFa = dF0;  amax = opts(5);  stop = 0;
b = min(1, opts(5));
while  ~stop
    [stop Fb g] = checkfg(fun,x+b*h,varargin{:});   info(3) = info(3)+1;
    if  stop,  info(1) = stop;
    else
        dFb = dot(g,h);
        if  Trace,  perf(:,info(3)+1) = [b; Fb; dFb]; end
        if  Fb < F0 + slope0*b  % new lower bound
            info(1:2) = [b dFb/dF0];
            if  soft,  a = b;  Fa = Fb;  dFa = dFb; end
            xn = x + b*h;  Fn = Fb;  gn = g;
            if  (dFb < min(slopethr,0)) & (info(3) < kmax) & (b < amax)
                % Augment right hand end
                if  ~soft,  a = b;  Fa = Fb;  dFa = dFb; end
                if  2.5*b >= amax,b = amax;  else,  b = 2*b; end
            else,  stop = 1; end
        else,  stop = 1; end
    end
end % phase 1: expand interval

if  stop >= 0  % OK so far.  Check stopping criteria
    stop = (info(3) >= kmax) | (b >= amax & dFb < slopethr)...  % Cannot improve
        | (soft & (a > 0 & dFb >= slopethr));  % OK
end
if  stop
    if  Trace,  perf = perf(:,1:info(3)+1); end
    return
end

% Refine interval.  Use auxiliary array  xfd
xfd = [a b b; Fa Fb Fb; dFa dFb dFb];
while  ~stop
    c = interpolate(xfd,n);
    [stop Fc g] = checkfg(fun,x+c*h,varargin{:});   info(3) = info(3)+1;
    if  stop,  info(1) = stop;
    else
        xfd(:,3) = [c; Fc; dot(g,h)];
        if  Trace,  perf(:,info(3)+1) = xfd(:,3); end
        if  soft
            if  Fc < F0 + slope0*c  % new lower bound
                info(1:2) = [c xfd(3,3)/dF0];
                xn = x + c*h;  Fn = Fc;  gn = g;
                xfd(:,1) = xfd(:,3);
                stop = xfd(3,3) > slopethr;
            else  % new upper bound
                xfd(:,2) = xfd(:,3);
            end
        else  % exact line search
            if  Fc < Fn  % better approximant
                info(1:2) = [c xfd(3,3)/dF0];
                xn = x + c*h;  Fn = Fc;  gn = g;
            end
            if  xfd(3,3) < 0,  xfd(:,1) = xfd(:,3);  % new lower bound
            else,         xfd(:,2) = xfd(:,3);  end  % new upper bound
            stop = abs(xfd(3,3)) <= slopethr...
                | diff(xfd(1,1:2)) < opts(3)*xfd(1,2);
        end
    end
    stop = stop | info(3) >= kmax;
end % refine

% Return values
if  Trace,   perf = perf(:,1:info(3)+1); end
end
%============  Auxiliary functions  ========================

function  t = interpolate(xfd,n);
% Minimizer of parabola given by  xfd = [a b; F(a) F(b); F'(a) dummy]
a = xfd(1,1);   b = xfd(1,2);   d = b - a;   dF = xfd(3,1);
C = diff(xfd(2,1:2)) - d*dF;
if C >= 5*n*eps*b    % Minimizer exists
    A = a - .5*dF*(d^2/C);  d = 0.1*d;
    t = min(max(a+d, A), b-d);  % Ensure significant resuction
else
    t = (a+b)/2;
end
end

function  [err, n] = check(x,f,g,h)
% Check  x
err = 0;  sx = size(x);   n = max(sx);
if  (min(sx) ~= 1) | ~isreal(x) | any(isnan(x(:))) | isinf(norm(x(:)))
    err = -1;
else
    % Check  f
    sf = size(f);
    if  any(sf ~= 1) | ~isreal(f) | any(isnan(f(:))) | any(isinf(f(:)))
        err = -2;
    else
        err = checkvec(g, n);
        if  ~err,  err = checkvec(h, n); end
    end
end
end

function  err = checkvec(v,n)
sv = size(v);
if  (min(sv) ~= 1) | ~isreal(v) | any(isnan(v(:))) | isinf(norm(v(:)))
    err = -3;
elseif  max(sv) ~= n,  err = -4;
else,                  err = 0; end


end

function  opts = checkopts(opts, default)
%CHECKOPTS  Replace illegal values by default values.

% Version 04.01.25.  hbn@imm.dtu.dk

a = default;  la = length(a);  lo = length(opts);
for  i = 1 : min(la,lo)
    oi = opts(i);
    if  isreal(oi) & ~isinf(oi) & ~isnan(oi) & oi > 0
        a(i) = opts(i);
    end
end
if  lo > la,  a = [a 1]; end % for linesearch purpose
opts = a;
end


function  [err, f,g] = checkfg(fun,x,varargin)
%CHECKFG  Check Matlab function which is called by a
% general optimization function

% Version 04.01.26.  hbn@imm.dtu.dk

err = 0;
[f g] = feval(fun,x,varargin{:});
sf = size(f);   sg = size(g);
if  any(sf ~= 1) | ~isreal(f) | any(isnan(f(:))) | any(isinf(f(:)))
    err = -2;  return, end
if  ~isreal(g) | any(isnan(g(:))) | any(isinf(g(:)))
    err = -3;  return, end
if  min(sg) ~= 1 | max(sg) ~= length(x)
    err = -4;  return, end
end
