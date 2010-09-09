function x = steepestDescent(f, x0, varargin)
% f is the function of the form [fx, gx] = f(x) where gx is a column vector
% outputfn has the form stop = outputfn(x, optimValues, state)

% This file is from pmtk3.googlecode.com


[ftol, maxIter, exactLineSearch, outputFn, stepSize] = process_options(...
    varargin, 'ftol', 1e-3, 'maxIter', 500, 'exactLineSearch', true, ...
    'outputFn', [], 'stepSize', []);
k = 1;
reldiff = inf;
x = x0(:);
stop = false;
[fx, gx] = f(x);
while ~stop
    k = k + 1;
    d = -gx; % steepest descent direction
    if isempty(stepSize)
        [xnew,fx,gx] = linesearch(f,x,fx,gx,d,~exactLineSearch);
    else
        xnew = x + stepSize*d;
        [fx, gx] = f(xnew);
    end
    %reldiff = norm(xnew - x)/norm(xnew);
    %stop = (reldiff < ftol) |  (k > maxIter);
    stop = norm(gx) < ftol |  (k > maxIter);
    if ~isempty(outputFn)
        optimValues.iteration = k;
        optimValues.fval = fx;
        optimValues.funccount = k;
        state = 'iter';
        stop = stop | outputFn(x, optimValues, state);
    end
    x = xnew;
end

end
