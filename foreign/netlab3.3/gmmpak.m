function p = gmmpak(mix)
%GMMPAK	Combines all the parameters in a Gaussian mixture model into one vector.
%
%	Description
%	P = GMMPAK(NET) takes a mixture data structure MIX  and combines the
%	component parameter matrices into a single row vector P.
%
%	See also
%	GMM, GMMUNPAK
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(mix, 'gmm');
if ~errstring
  error(errstring);
end

p = [mix.priors, mix.centres(:)', mix.covars(:)'];
if strcmp(mix.covar_type, 'ppca')
  p = [p, mix.lambda(:)', mix.U(:)'];
end