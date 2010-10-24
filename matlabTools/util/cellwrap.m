function c = cellwrap(c)
% Ensure that the input is a cell array

% This file is from pmtk3.googlecode.com

if ~iscell(c),c = {c}; end
end
