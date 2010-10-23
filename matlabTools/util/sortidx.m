function [perm,val] = sortidx(varargin)
% Return the index permutation that sorts an array

% This file is from matlabtools.googlecode.com

[val,perm] = sort(varargin{:});
end
