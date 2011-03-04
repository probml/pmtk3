function H = entropyPmtk(v)
% Entropy of a discrete distribution, log base 2

% This file is from pmtk3.googlecode.com

v = v(:);
v = v + (v==0);
H = -1 * sum(v .* log2(v), 1); 

end
