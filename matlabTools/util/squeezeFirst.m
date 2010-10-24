function A = squeezeFirst(A)
%% Squeeze only the first dimension

% This file is from pmtk3.googlecode.com


if size(A, 1) > 1
    return;
end
sz = [size(A), 1]; 
A = reshape(A, sz(2:end)); 


end
