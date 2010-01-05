function gmmmixes = mdn2gmm(mdnmixes)
%MDN2GMM Converts an MDN mixture data structure to array of GMMs.
%
%	Description
%	GMMMIXES = MDN2GMM(MDNMIXES) takes an MDN mixture data structure
%	MDNMIXES containing three matrices (for priors, centres and
%	variances) where each row represents the corresponding parameter
%	values for a different mixture model  and creates an array of GMMs.
%	These can then be used with the standard Netlab Gaussian mixture
%	model functions.
%
%	See also
%	GMM, MDN, MDNFWD
%

%	Copyright (c) Ian T Nabney (1996-2001)
%	David J Evans (1998)

% Check argument for consistency
errstring = consist(mdnmixes, 'mdnmixes');
if ~isempty(errstring)
  error(errstring);
end

nmixes = size(mdnmixes.centres, 1);
% Construct ndata structures containing the mixture model information.
% First allocate the memory.
tempmix = gmm(mdnmixes.dim_target, mdnmixes.ncentres, 'spherical');
f = fieldnames(tempmix);
gmmmixes = cell(size(f, 1), 1, nmixes);
gmmmixes = cell2struct(gmmmixes, f,1);

% Then fill each structure in turn using gmmunpak.  Assume that spherical
% covariance structure is used.
for i = 1:nmixes
  centres = reshape(mdnmixes.centres(i, :), mdnmixes.dim_target, ...
    mdnmixes.ncentres)';
  gmmmixes(i) = gmmunpak(tempmix, [mdnmixes.mixcoeffs(i,:), ...
      centres(:)', mdnmixes.covars(i,:)]);
end

