function c = removeEmpty(c)
% Remove all empty cells from a cell array

% This file is from pmtk3.googlecode.com

c = c(~cellfun('isempty', c)); % 'isempty' is faster than @isempty
end
