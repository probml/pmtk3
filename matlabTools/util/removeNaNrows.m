function A = removeNaNrows(A)
%% Remove NaN rows from the matrix A
% If A is a cell array, do this for every matrix in the array
%%

% This file is from matlabtools.googlecode.com

if iscell(A)
    A = cellfuncell(@removeNaNrows, A); 
    return
end
A(any(isnan(A), 2), :) = [];
end
