function [net, options, errlog] = gtmem(net, t, options)
%GTMEM	EM algorithm for Generative Topographic Mapping.
%
%	Description
%	[NET, OPTIONS, ERRLOG] = GTMEM(NET, T, OPTIONS) uses the Expectation
%	Maximization algorithm to estimate the parameters of a GTM defined by
%	a data structure NET. The matrix T represents the data whose
%	expectation is maximized, with each row corresponding to a vector.
%	It is assumed that the latent data NET.X has been set following a
%	call to GTMINIT, for example.    The optional parameters have the
%	following interpretations.
%
%	OPTIONS(1) is set to 1 to display error values; also logs error
%	values in the return argument ERRLOG. If OPTIONS(1) is set to 0, then
%	only warning messages are displayed.  If OPTIONS(1) is -1, then
%	nothing is displayed.
%
%	OPTIONS(3) is a measure of the absolute precision required of the
%	error function at the solution. If the change in log likelihood
%	between two steps of the EM algorithm is less than this value, then
%	the function terminates.
%
%	OPTIONS(14) is the maximum number of iterations; default 100.
%
%	The optional return value OPTIONS contains the final error value
%	(i.e. data log likelihood) in OPTIONS(8).
%
%	See also
%	GTM, GTMINIT
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check that inputs are consistent
errstring = consist(net, 'gtm', t);
if ~isempty(errstring)
  error(errstring);
end

% Sort out the options
if (options(14))
  niters = options(14);
else
  niters = 100;
end

display = options(1);
store = 0;
if (nargout > 2)
  store = 1;	% Store the error values to return them
  errlog = zeros(1, niters);
end
test = 0;
if options(3) > 0.0
  test = 1;	% Test log likelihood for termination
end

% Calculate various quantities that remain constant during training
[ndata, tdim] = size(t);
ND = ndata*tdim;
[net.gmmnet.centres, Phi] = rbffwd(net.rbfnet, net.X);
Phi = [Phi ones(size(net.X, 1), 1)];
PhiT = Phi';
[K, Mplus1] = size(Phi);

A = zeros(Mplus1, Mplus1);
cholDcmp = zeros(Mplus1, Mplus1);
% Use a sparse representation for the weight regularizing matrix.
if (net.rbfnet.alpha > 0)
  Alpha = net.rbfnet.alpha*speye(Mplus1);
  Alpha(Mplus1, Mplus1) = 0;
end 

for n = 1:niters
   % Calculate responsibilities
   [R, act] = gtmpost(net, t);
     % Calculate error value if needed
   if (display | store | test)
      prob = act*(net.gmmnet.priors)';
      % Error value is negative log likelihood of data
      e = - sum(log(max(prob,eps)));
      if store
         errlog(n) = e;
      end
      if display > 0
         fprintf(1, 'Cycle %4d  Error %11.6f\n', n, e);
      end
      if test
         if (n > 1 & abs(e - eold) < options(3))
            options(8) = e;
            return;
         else
            eold = e;
         end
      end
   end

   % Calculate matrix be inverted (Phi'*G*Phi + alpha*I in the papers).
   % Sparse representation of G normally executes faster and saves
   % memory
   if (net.rbfnet.alpha > 0)
      A = full(PhiT*spdiags(sum(R)', 0, K, K)*Phi + ...
         (Alpha.*net.gmmnet.covars(1)));
   else
      A = full(PhiT*spdiags(sum(R)', 0, K, K)*Phi);
   end
   % A is a symmetric matrix likely to be positive definite, so try
   % fast Cholesky decomposition to calculate W, otherwise use SVD.
   % (PhiT*(R*t)) is computed right-to-left, as R
   % and t are normally (much) larger than PhiT.
   [cholDcmp singular] = chol(A);
   if (singular)
      if (display)
         fprintf(1, ...
            'gtmem: Warning -- M-Step matrix singular, using pinv.\n');
      end
      W = pinv(A)*(PhiT*(R'*t));
   else
      W = cholDcmp \ (cholDcmp' \ (PhiT*(R'*t)));
   end
   % Put new weights into network to calculate responsibilities
   % net.rbfnet = netunpak(net.rbfnet, W);
   net.rbfnet.w2 = W(1:net.rbfnet.nhidden, :);
   net.rbfnet.b2 = W(net.rbfnet.nhidden+1, :);
   % Calculate new distances
   d = dist2(t, Phi*W);
   
   % Calculate new value for beta
   net.gmmnet.covars = ones(1, net.gmmnet.ncentres)*(sum(sum(d.*R))/ND);
end

options(8) = -sum(log(gtmprob(net, t)));
if (display >= 0)
  disp(maxitmess);
end
