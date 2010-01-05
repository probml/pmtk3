function [net, options] = rbftrain(net, options, x, t)
%RBFTRAIN Two stage training of RBF network.
%
%	Description
%	NET = RBFTRAIN(NET, OPTIONS, X, T) uses a  two stage training
%	algorithm to set the weights in the RBF model structure NET. Each row
%	of X corresponds to one input vector and each row of T contains the
%	corresponding target vector. The centres are determined by fitting a
%	Gaussian mixture model with circular covariances using the EM
%	algorithm through a call to RBFSETBF.  (The mixture model is
%	initialised using a small number of iterations of the K-means
%	algorithm.) If the activation functions are Gaussians, then the basis
%	function widths are then set to the maximum inter-centre squared
%	distance.
%
%	For linear outputs,  the hidden to output weights that give rise to
%	the least squares solution can then be determined using the pseudo-
%	inverse. For neuroscale outputs, the hidden to output weights are
%	determined using the iterative shadow targets algorithm.  Although
%	this two stage procedure may not give solutions with as low an error
%	as using general  purpose non-linear optimisers, it is much faster.
%
%	The options vector may have two rows: if this is the case, then the
%	second row is passed to RBFSETBF, which allows the user to specify a
%	different number iterations for RBF and GMM training. The optional
%	parameters to RBFTRAIN have the following interpretations.
%
%	OPTIONS(1) is set to 1 to display error values during EM training.
%
%	OPTIONS(2) is a measure of the precision required for the value of
%	the weights W at the solution.
%
%	OPTIONS(3) is a measure of the precision required of the objective
%	function at the solution.  Both this and the previous condition must
%	be satisfied for termination.
%
%	OPTIONS(5) is set to 1 if the basis functions parameters should
%	remain unchanged; default 0.
%
%	OPTIONS(6) is set to 1 if the output layer weights should be should
%	set using PCA. This is only relevant for Neuroscale outputs; default
%	0.
%
%	OPTIONS(14) is the maximum number of iterations for the shadow
%	targets algorithm;  default 100.
%
%	See also
%	RBF, RBFERR, RBFFWD, RBFGRAD, RBFPAK, RBFUNPAK, RBFSETBF
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
switch net.outfn
case 'linear'
  errstring = consist(net, 'rbf', x, t);
case 'neuroscale'
  errstring = consist(net, 'rbf', x);
otherwise
 error(['Unknown output function ', net.outfn]);
end
if ~isempty(errstring)
  error(errstring);
end

% Allow options to have two rows: if this is the case, then the second row
% is passed to rbfsetbf
if size(options, 1) == 2
  setbfoptions = options(2, :);
  options = options(1, :);
else
  setbfoptions = options;
end

if(~options(14))
  options(14) = 100;
end
% Do we need to test for termination?
test = (options(2) | options(3));

% Set up the basis function parameters to model the input data density
% unless options(5) is set.
if ~(logical(options(5)))
  net = rbfsetbf(net, setbfoptions, x);
end

% Compute the design (or activations) matrix
[y, act] = rbffwd(net, x);
ndata = size(x, 1);

if strcmp(net.outfn, 'neuroscale') & options(6)
  % Initialise output layer weights by projecting data with PCA
  mu = mean(x);
  [pcvals, pcvecs] = pca(x, net.nout);
  xproj = (x - ones(ndata, 1)*mu)*pcvecs;
  % Now use projected data as targets to compute output layer weights
  temp = pinv([act ones(ndata, 1)]) * xproj;
  net.w2 = temp(1:net.nhidden, :);
  net.b2 = temp(net.nhidden+1, :);
  % Propagate again to compute revised outputs
  [y, act] = rbffwd(net, x);
end

switch net.outfn
case 'linear'
  % Sum of squares error function in regression model
  % Solve for the weights and biases using pseudo-inverse from activations
  Phi = [act ones(ndata, 1)];
  if ~isfield(net, 'alpha')
    % Solve for the weights and biases using left matrix divide
    temp = pinv(Phi)*t;
  elseif size(net.alpha == [1 1])
    % Use normal form equation
    hessian = Phi'*Phi + net.alpha*eye(net.nhidden+1);
    temp = pinv(hessian)*(Phi'*t);  
  else
    error('Only scalar alpha allowed');
  end
  net.w2 = temp(1:net.nhidden, :);
  net.b2 = temp(net.nhidden+1, :);

case 'neuroscale'
  % Use the shadow targets training algorithm
  if nargin < 4
    % If optional input distances not passed in, then use
    % Euclidean distance
    x_dist = sqrt(dist2(x, x));
  else
    x_dist = t;
  end
  Phi = [act, ones(ndata, 1)];
  % Compute the pseudo-inverse of Phi
  PhiDag = pinv(Phi);
  % Compute y_dist, distances between image points
  y_dist = sqrt(dist2(y, y));

  % Save old weights so that we can check the termination criterion
  wold = netpak(net);
  % Compute initial error (stress) value
  errold = 0.5*(sum(sum((x_dist - y_dist).^2)));

  % Initial value for eta
  eta = 0.1;
  k_up = 1.2;
  k_down = 0.1;
  success = 1;  % Force initial gradient calculation

  for j = 1:options(14)
    if success
      % Compute the negative error gradient with respect to network outputs
      D = (x_dist - y_dist)./(y_dist+(y_dist==0));
      temp = y';
      neg_gradient = -2.*sum(kron(D, ones(1, net.nout)) .* ...
	(repmat(y, 1, ndata) - repmat((temp(:))', ndata, 1)), 1);
      neg_gradient = (reshape(neg_gradient, net.nout, ndata))';
    end
    % Compute the shadow targets
    t = y + eta*neg_gradient;
    % Solve for the weights and biases
    temp = PhiDag * t;
    net.w2 = temp(1:net.nhidden, :);
    net.b2 = temp(net.nhidden+1, :);
   
    % Do housekeeping and test for convergence
    ynew = rbffwd(net, x);
    y_distnew = sqrt(dist2(ynew, ynew));
    err = 0.5.*(sum(sum((x_dist-y_distnew).^2)));
    if err > errold
      success = 0;
      % Restore previous weights
      net = netunpak(net, wold);
      err = errold;
      eta = eta * k_down;
    else
      success = 1;
      eta = eta * k_up;
      errold = err;
      y = ynew;
      y_dist = y_distnew;
      if test & j > 1
	w = netpak(net);
	if (max(abs(w - wold)) < options(2) & abs(err-errold) < options(3))
	  options(8) = err;
	  return;
	end
      end
      wold = netpak(net);
    end
    if options(1)
      fprintf(1, 'Cycle %4d Error %11.6f\n', j, err)
    end
    if nargout >= 3
      errlog(j) = err;
    end
  end
  options(8) = errold;
  if (options(1) >= 0)
    disp('Warning: Maximum number of iterations has been exceeded');
  end
otherwise
   error(['Unknown output function ', net.outfn]);

end
