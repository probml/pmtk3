function A = squeezeFirst(A)
%% Squeeze only the first dimension

if size(A, 1) > 1
    return;
end
sz = [size(A), 1]; 
A = reshape(A, sz(2:end)); 


end