function c = removeEmpty(c)
% Remove all empty cells from a cell array
c = c(cellfun(@(a)~isempty(a),c));
end