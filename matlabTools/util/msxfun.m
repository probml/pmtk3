function C = msxfun(fn, varargin)
%% Perform binary reduction on multiple arrays using bsxfun
% (similar to python's reduce fuction)
% For three matrices, the following two code snippets are equivalent
% msxfun(fn, X1, X2, X3)
% bsxfun(fn, bsxfun(fn, X1, X2), X3)
%% Example
% msxfun(@times, rand(100, 1), rand(100, 100), rand(1, 100))

% This file is from pmtk3.googlecode.com

n = nargin - 1;
C = bsxfun(fn, varargin{1}, varargin{2});
for i=3:n
    C = bsxfun(fn, C, varargin{i});
end
end
