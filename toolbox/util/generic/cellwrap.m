function c = cellwrap(c)
% Ensure that the input is a cell array
if ~iscell(c),c = {c}; end
end