function [net, options, errlog, pointlog] = olgd(net, options, x, t)
%OLGD	On-line gradient descent optimization.
%
%	Description
%	[NET, OPTIONS, ERRLOG, POINTLOG] = OLGD(NET, OPTIONS, X, T) uses  on-
%	line gradient descent to find a local minimum of the error function
%	for the network NET computed on the input data X and target values T.
%	A log of the error values after each cycle is (optionally) returned
%	in ERRLOG, and a log of the points visited is (optionally) returned
%	in POINTLOG. Because the gradient is computed on-line (i.e. after
%	each pattern) this can be quite inefficient in Matlab.
%
%	The error function value at final weight vector is returned in
%	OPTIONS(8).
%
%	The optional parameters have the following interpretations.
%
%	OPTIONS(1) is set to 1 to display error values; also logs error
%	values in the return argument ERRLOG, and the points visited in the
%	return argument POINTSLOG.  If OPTIONS(1) is set to 0, then only
%	warning messages are displayed.  If OPTIONS(1) is -1, then nothing is
%	displayed.
%
%	OPTIONS(2) is the precision required for the value of X at the
%	solution. If the absolute difference between the values of X between
%	two successive steps is less than OPTIONS(2), then this condition is
%	satisfied.
%
%	OPTIONS(3) is the precision required of the objective function at the
%	solution.  If the absolute difference between the error functions
%	between two successive steps is less than OPTIONS(3), then this
%	condition is satisfied. Both this and the previous condition must be
%	satisfied for termination. Note that testing the function value at
%	each iteration roughly halves the speed of the algorithm.
%
%	OPTIONS(5) determines whether the patterns are sampled randomly with
%	replacement. If it is 0 (the default), then patterns are sampled in
%	order.
%
%	OPTIONS(6) determines if the learning rate decays.  If it is 1 then
%	the learning rate decays at a rate of 1/T.  If it is 0 (the default)
%	then the learning rate is constant.
%
%	OPTIONS(9) should be set to 1 to check the user defined gradient
%	function.
%
%	OPTIONS(10) returns the total number of function evaluations
%	(including those in any line searches).
%
%	OPTIONS(11) returns the total number of gradient evaluations.
%
%	OPTIONS(14) is the maximum number of iterations (passes through the
%	complete pattern set); default 100.
%
%	OPTIONS(17) is the momentum; default 0.5.
%
%	OPTIONS(18) is the learning rate; default 0.01.
%
%	See also
%	GRADDESC
%

%	Copyright (c) Ian T Nabney (1996-2001)

%  Set up the options.
if length(options) < 18
  error('Options vector too short')
end

if (options(14))
  niters = options(14);
else
  niters = 100;
end

% Learning rate: must be positive
if (options(18) > 0)
  eta = options(18);
else
  eta = 0.01;
end
% Save initial learning rate for annealing
lr = eta;
% Momentum term: allow zero momentum
if (options(17) >= 0)
  mu = options(17);
else
  mu = 0.5;
end

pakstr = [net.type, 'pak'];
unpakstr = [net.type, 'unpak'];

% Extract initial weights from the network
w = feval(pakstr, net);

display = options(1);

% Work out if we need to compute f at each iteration.
% Needed if display results or if termination
% criterion requires it.
fcneval = (display | options(3));

%  Check gradients
if (options(9))
  feval('gradchek', w, 'neterr', 'netgrad', net, x, t);
end

dwold = zeros(1, length(w));
fold = 0; % Must be initialised so that termination test can be performed
ndata = size(x, 1);

if fcneval
  fnew = neterr(w, net, x, t);
  options(10) = options(10) + 1;
  fold = fnew;
end

j = 1;
if nargout >= 3
  errlog(j, :) = fnew;
  if nargout == 4
    pointlog(j, :) = w;
  end
end

%  Main optimization loop.
while j <= niters
  wold = w;
  if options(5)
    % Randomise order of pattern presentation: with replacement
    pnum = ceil(rand(ndata, 1).*ndata);
  else
    pnum = 1:ndata;
  end
  for k = 1:ndata
    grad = netgrad(w, net, x(pnum(k),:), t(pnum(k),:));
    if options(6)
      % Let learning rate decrease as 1/t
      lr = eta/((j-1)*ndata + k);
    end
    dw = mu*dwold - lr*grad;
    w =  w + dw;
    dwold = dw;
  end
  options(11) = options(11) + 1;  % Increment gradient evaluation count
  if fcneval
    fold = fnew;
    fnew = neterr(w, net, x, t);
    options(10) = options(10) + 1;
  end
  if display
    fprintf(1, 'Iteration  %5d  Error %11.8f\n', j, fnew);
  end
  j = j + 1;
  if nargout >= 3
    errlog(j) = fnew;
    if nargout == 4
      pointlog(j, :) = w;
    end
  end
  if (max(abs(w - wold)) < options(2) & abs(fnew - fold) < options(3))
    % Termination criteria are met
    options(8) = fnew;
    net = feval(unpakstr, net, w);
    return;
  end
end

if fcneval
  options(8) = fnew;
else
  % Return error on entire dataset
  options(8) = neterr(w, net, x, t);
  options(10) = options(10) + 1;
end
if (options(1) >= 0)
  disp(maxitmess);
end

net = feval(unpakstr, net, w);