function prior = mlpprior(nin, nhidden, nout, aw1, ab1, aw2, ab2)
%MLPPRIOR Create Gaussian prior for mlp.
%
%	Description
%	PRIOR = MLPPRIOR(NIN, NHIDDEN, NOUT, AW1, AB1, AW2, AB2)  generates a
%	data structure PRIOR, with fields PRIOR.ALPHA and PRIOR.INDEX, which
%	specifies a Gaussian prior distribution for the network weights in a
%	two-layer feedforward network. Two different cases are possible. In
%	the first case, AW1, AB1, AW2 and AB2 are all scalars and represent
%	the regularization coefficients for four groups of parameters in the
%	network corresponding to first-layer weights, first-layer biases,
%	second-layer weights, and second-layer biases respectively. Then
%	PRIOR.ALPHA represents a column vector of length 4 containing the
%	parameters, and PRIOR.INDEX is a matrix specifying which weights
%	belong in each group. Each column has one element for each weight in
%	the matrix, using the standard ordering as defined in MLPPAK, and
%	each element is 1 or 0 according to whether the weight is a member of
%	the corresponding group or not.  In the second case the parameter AW1
%	is a vector of length equal to the number of inputs in the network,
%	and the corresponding matrix PRIOR.INDEX now partitions the first-
%	layer weights into groups corresponding to the weights fanning out of
%	each input unit. This  prior is appropriate for the technique of
%	automatic relevance determination.
%
%	See also
%	MLP, MLPERR, MLPGRAD, EVIDENCE
%

%	Copyright (c) Ian T Nabney (1996-2001)

nextra = nhidden + (nhidden + 1)*nout;
nwts = nin*nhidden + nextra;

if size(aw1) == [1,1] 

    indx = [ones(1, nin*nhidden), zeros(1, nextra)]';
  
elseif size(aw1) == [1, nin]
  
    indx = kron(ones(nhidden, 1), eye(nin));
    indx = [indx; zeros(nextra, nin)];

else
  
    error('Parameter aw1 of invalid dimensions');
    
end

extra = zeros(nwts, 3);

mark1 = nin*nhidden;
mark2 = mark1 + nhidden;
extra(mark1 + 1:mark2, 1) = ones(nhidden,1);
mark3 = mark2 + nhidden*nout;
extra(mark2 + 1:mark3, 2) = ones(nhidden*nout,1);
mark4 = mark3 + nout;
extra(mark3 + 1:mark4, 3) = ones(nout,1);

indx = [indx, extra];

prior.index = indx;
prior.alpha = [aw1, ab1, aw2, ab2]';
