function A = squeezePMTK(A)
%% Same as built in squeeze function except it squeezes even rowvecs
% into colvecs. 
%
%%
A = squeeze(A); 
if isvector(A)
    A = A(:);
end
end