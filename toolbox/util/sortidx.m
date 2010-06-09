function [perm,val] = sortidx(varargin)
% Return the index permutation that sorts an array
[val,perm] = sort(varargin{:});
end