function net = somtrain(net, options, x)
%SOMTRAIN Kohonen training algorithm for SOM.
%
%	Description
%	NET = SOMTRAIN{NET, OPTIONS, X) uses Kohonen's algorithm to train a
%	SOM.  Both on-line and batch algorithms are implemented. The learning
%	rate (for on-line) and neighbourhood size decay linearly. There is no
%	error function minimised during training (so there is no termination
%	criterion other than the number of epochs), but the  sum-of-squares
%	is computed and returned in OPTIONS(8).
%
%	The optional parameters have the following interpretations.
%
%	OPTIONS(1) is set to 1 to display error values; also logs learning
%	rate ALPHA and neighbourhood size NSIZE. Otherwise nothing is
%	displayed.
%
%	OPTIONS(5) determines whether the patterns are sampled randomly with
%	replacement. If it is 0 (the default), then patterns are sampled in
%	order.  This is only relevant to the on-line algorithm.
%
%	OPTIONS(6) determines if the on-line or batch algorithm is used. If
%	it is 1 then the batch algorithm is used.  If it is 0 (the default)
%	then the on-line algorithm is used.
%
%	OPTIONS(14) is the maximum number of iterations (passes through the
%	complete pattern set); default 100.
%
%	OPTIONS(15) is the final neighbourhood size; default value is the
%	same as the initial neighbourhood size.
%
%	OPTIONS(16) is the final learning rate; default value is the same as
%	the initial learning rate.
%
%	OPTIONS(17) is the initial neighbourhood size; default 0.5*maximum
%	map size.
%
%	OPTIONS(18) is the initial learning rate; default 0.9.  This
%	parameter must be positive.
%
%	See also
%	KMEANS, SOM, SOMFWD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'som', x);
if ~isempty(errstring)
    error(errstring);
end

% Set number of iterations in convergence phase
if (~options(14))
    options(14) = 100;
end
niters = options(14);

% Learning rate must be positive
if (options(18) > 0)
    alpha_first = options(18);
else
    alpha_first = 0.9;
end
% Final learning rate must be no greater than initial learning rate
if (options(16) > alpha_first | options(16) < 0)
    alpha_last = alpha_first;
else
    alpha_last = options(16);
end

% Neighbourhood size
if (options(17) >= 0)
    nsize_first = options(17);
else
    nsize_first = max(net.map_dim)/2;
end
% Final neighbourhood size must be no greater than initial size
if (options(15) > nsize_first | options(15) < 0)
    nsize_last = nsize_first;
else
    nsize_last = options(15);
end

ndata = size(x, 1);

if options(6)
    % Batch algorithm
    H = zeros(ndata, net.num_nodes);
end
% Put weights into matrix form
tempw = sompak(net);

% Then carry out training
j = 1;
while j <= niters
    if options(6)
	% Batch version of algorithm
	alpha = 0.0;
	frac_done = (niters - j)/niters;
	% Compute neighbourhood
	nsize = round((nsize_first - nsize_last)*frac_done + nsize_last);
	
	% Find winning node: put weights back into net so that we can
	% call somunpak
	net = somunpak(net, tempw);
	[temp, bnode] = somfwd(net, x);
	for k = 1:ndata
	    H(k, :) = reshape(net.inode_dist(:, :, bnode(k))<=nsize, ...
		1, net.num_nodes);
	end
	s = sum(H, 1);
	for k = 1:net.num_nodes
	    if s(k) > 0
		tempw(k, :) = sum((H(:, k)*ones(1, net.nin)).*x, 1)/ ...
		    s(k);
	    end
	end
    else
	% On-line version of algorithm
	if options(5)
	    % Randomise order of pattern presentation: with replacement
	    pnum = ceil(rand(ndata, 1).*ndata);
	else
	    pnum = 1:ndata;
	end
	% Cycle through dataset
	for k = 1:ndata
	    % Fraction done
	    frac_done = (((niters+1)*ndata)-(j*ndata + k))/((niters+1)*ndata);
	    % Compute learning rate
	    alpha = (alpha_first - alpha_last)*frac_done + alpha_last;
	    % Compute neighbourhood
	    nsize = round((nsize_first - nsize_last)*frac_done + nsize_last);
	    % Find best node
	    pat_diff = ones(net.num_nodes, 1)*x(pnum(k), :) - tempw;
	    [temp, bnode] = min(sum(abs(pat_diff), 2));
	
	    % Now update neighbourhood
	    neighbourhood = (net.inode_dist(:, :, bnode) <= nsize);
	    tempw = tempw + ...
		((alpha*(neighbourhood(:)))*ones(1, net.nin)).*pat_diff;
	end
    end
    if options(1)
	% Print iteration information
	fprintf(1, 'Iteration %d; alpha = %f, nsize = %f. ', j, alpha, ...
	nsize);
	% Print sum squared error to nearest node
	d2 = dist2(tempw, x);
	fprintf(1, 'Error = %f\n', sum(min(d2)));
    end
    j = j + 1;
end

net = somunpak(net, tempw);
options(8) = sum(min(dist2(tempw, x)));