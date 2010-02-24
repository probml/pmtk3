function x = coordDescent(f, x0, varargin)
% f is the function of the form [fx] = f(x) where gx is a column vector
% outputfn has the form stop = outputfn(x, optimValues, state)
 
[ftol, maxIter, exactLineSearch, outputFn, stepSize] = processArgs(...
  varargin, '-ftol', 1e-3, '-maxIter', 500, '-exactLineSearch', false, ...
  'outputFn', [], 'stepSize', []);
k = 0;
reldiff = inf;
x = x0(:);
ndims = length(x);
stop = false;
[fx] = f(x);
opt = foptions;
while ~stop
  for i=1:ndims
    k = k + 1;
    e = zeros(ndims,1);
    e(i) = 1;
    d = e; % coordinate descent
    if isempty(stepSize) %
      [step] = linemin(f, x, d, fx, opt); % Brent's algorithm
      xnew = x + step*d;
    else
      xnew = x + stepSize*d;
      [fx] = f(xnew);
    end
    x = xnew;
  end
  reldiff = norm(xnew - x)/norm(xnew);
  %stop = (reldiff < ftol) |  (k > maxIter);
  stop = (k > maxIter);
  if ~isempty(outputFn)
    optimValues.iteration = k;
    optimValues.fval = fx;
    optimValues.funcount = k;
    state = 'iter';
    stop = stop | outputFn(x, optimValues, state);
  end
end
