function B = uniquePMTK(A)
%% Return the unique positive integers in A faster than the built in unique
%  always returns a row vector
bits = false(max(A), 1); 
bits(A) = true; 
B = find(bits)'; 
end

