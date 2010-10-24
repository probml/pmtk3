function s = nansumPMTK(X, dim)
%% Replacement for the stats toolbox nansum function

% This file is from pmtk3.googlecode.com


X(isnan(X)) = 0; 
if nargin < 2
    s = sum(X);
else
    s = sum(X, dim);
end

end
