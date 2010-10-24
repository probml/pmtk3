function ndx = cellfind(cellarray, value, varargin)
% A find function for cell arrays
%
% example
%
% a = {[], 1, 1:2, 1:3, 1:4, 1:5, 1:6, 1:7, 1:8}
% cellfind(a, 1:3)
% ans = 4

% This file is from pmtk3.googlecode.com

if iscell(value) && ~iscell(cellarray{1}), value = value{:}; end
ndx = find(cellfun(@(x)isequal(x, value), cellarray), varargin{:});
end
