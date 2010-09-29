function G = precmatToAdjmat(Lambda, thresh)
% Convert a precision matrix to an adjacency matrix

% This file is from pmtk3.googlecode.com

if nargin < 2, thresh = 1e-9; end
G = Lambda;
G(abs(G) < thresh) = 0;
G = abs(sign(G));
G = setdiag(G,0);

end
