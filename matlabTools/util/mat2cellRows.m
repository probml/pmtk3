function c = mat2cellRows(m)
% Place each row of a matrix into its own cell and return the n-by-1 array
% Converts an n-by-d numeric matrix 'm', to an n-by-1 cell array 'c', such
% that c{i} = m(i,:) for all i in 1:size(m,1).

% This file is from pmtk3.googlecode.com

c = mat2cell(m, ones(size(m, 1), 1));
end
