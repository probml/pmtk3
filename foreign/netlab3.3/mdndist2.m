function n2 = mdndist2(mixparams, t)
%MDNDIST2 Calculates squared distance between centres of Gaussian kernels and data
%
%	Description
%	N2 = MDNDIST2(MIXPARAMS, T) takes takes the centres of the Gaussian
%	contained in  MIXPARAMS and the target data matrix, T, and computes
%	the squared  Euclidean distance between them.  If T has M rows and N
%	columns, then the CENTRES field in the MIXPARAMS structure should
%	have M rows and N*MIXPARAMS.NCENTRES columns: the centres in each row
%	relate to the corresponding row in T. The result has M rows and
%	MIXPARAMS.NCENTRES columns. The I, Jth entry is the  squared distance
%	from the Ith row of X to the Jth centre in the Ith row of
%	MIXPARAMS.CENTRES.
%
%	See also
%	MDNFWD, MDNPROB
%

%	Copyright (c) Ian T Nabney (1996-2001)
%	David J Evans (1998)

% Check arguments for consistency
errstring = consist(mixparams, 'mdnmixes');
if ~isempty(errstring)
  error(errstring);
end

ncentres   = mixparams.ncentres;
dim_target = mixparams.dim_target;
ntarget    = size(t, 1);
if ntarget ~= size(mixparams.centres, 1)
  error('Number of targets does not match number of mixtures')
end
if size(t, 2) ~= mixparams.dim_target
  error('Target dimension does not match mixture dimension')
end

% Build t that suits parameters, that is repeat t for each centre
t = kron(ones(1, ncentres), t);

% Do subtraction and square
diff2 = (t - mixparams.centres).^2;

% Reshape and sum each component
diff2 = reshape(diff2', dim_target, (ntarget*ncentres))';
n2 = sum(diff2, 2);

% Calculate the sum of distance, and reshape
% so that we have a distance for each centre per target
n2 = reshape(n2, ncentres, ntarget)';

