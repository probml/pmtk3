function C = cellfunNonEmpty(fn, C)
%% Apply a function to the non-empty elements of C
% always returns a cell array

% This file is from matlabtools.googlecode.com


ndx = ~cellfun('isempty', C); 

C(ndx) = cellfuncell(fn, C(ndx)); 
end
