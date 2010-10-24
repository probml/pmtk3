function A = squeezePMTK(A)
%% Same as built in squeeze function except it squeezes even rowvecs
% into colvecs. 
%
%%

% This file is from pmtk3.googlecode.com

A = squeeze(A); 
if isvector(A)
    A = A(:);
end
end
