function s = nansumPMTK(X, dim)
%% Replacement for the stats toolbox nansum function

X(isnan(X)) = 0; 
if nargin < 2
    s = sum(X);
else
    s = sum(X, dim);
end

end