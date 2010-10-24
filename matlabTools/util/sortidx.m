function [perm,val] = sortidx(varargin)
% Return the index permutation that sorts an array

% This file is from pmtk3.googlecode.com

[val,perm] = sort(varargin{:});
end
