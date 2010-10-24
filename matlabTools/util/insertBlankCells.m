function CC = insertBlankCells(C, ndx)
%% Insert blank rows of cells into a cell array at indices ndx
% Returns a column cell array 
%%

% This file is from pmtk3.googlecode.com



N = size(C, 1)+numel(ndx);
CC = cell(N, size(C, 2)); 

dndx = setdiffPMTK(1:N, ndx);
CC(dndx, :) = C; 






end
