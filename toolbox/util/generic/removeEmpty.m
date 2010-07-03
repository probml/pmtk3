function c = removeEmpty(c)
% Remove all empty cells from a cell array
c = c(~cellfun('isempty', c)); % 'isempty' is faster than @isempty
end