function g = mdngrad(net, x, t)
%MDNGRAD Evaluate gradient of error function for Mixture Density Network.
%
%	Description
%	 G = MDNGRAD(NET, X, T) takes a mixture density network data
%	structure NET, a matrix X of input vectors and a matrix T of target
%	vectors, and evaluates the gradient G of the error function with
%	respect to the network weights. The error function is negative log
%	likelihood of the target data.  Each row of X corresponds to one
%	input vector and each row of T corresponds to one target vector.
%
%	See also
%	MDN, MDNFWD, MDNERR, MDNPROB, MLPBKP
%

%	Copyright (c) Ian T Nabney (1996-2001)
%	David J Evans (1998)

% Check arguments for consistency
errstring = consist(net, 'mdn', x, t);
if ~isempty(errstring)
  error(errstring);
end

[mixparams, y, z] = mdnfwd(net, x);

% Compute gradients at MLP outputs: put the answer in deltas
ncentres = net.mdnmixes.ncentres;
dim_target = net.mdnmixes.dim_target;
nmixparams = net.mdnmixes.nparams;
ntarget = size(t, 1);
deltas = zeros(ntarget, net.mlp.nout);
e = ones(ncentres, 1);
f = ones(1, dim_target);

post = mdnpost(mixparams, t);

% Calculate prior derivatives
deltas(:,1:ncentres)  = mixparams.mixcoeffs - post;

% Calculate centre derivatives
long_t = kron(ones(1, ncentres), t);
centre_err = mixparams.centres - long_t;

% Get the post to match each u_jk:
% this array will be (ntarget, (ncentres*dim_target))
long_post = kron(ones(dim_target, 1), post);
long_post = reshape(long_post, ntarget, (ncentres*dim_target));

% Get the variance to match each u_jk:
var = mixparams.covars;
var = kron(ones(dim_target, 1), var);
var = reshape(var, ntarget, (ncentres*dim_target));

% Compute centre deltas
deltas(:, (ncentres+1):(ncentres*(1+dim_target))) = ...
                       (centre_err.*long_post)./var;

% Compute variance deltas
dist2             = mdndist2(mixparams, t);
c                 = dim_target*ones(ntarget, ncentres);
deltas(:, (ncentres*(1+dim_target)+1):nmixparams) = ...
                      post.*((dist2./mixparams.covars)-c)./(-2);

% Now back-propagate deltas through MLP
g = mlpbkp(net.mlp, x, z, deltas);
