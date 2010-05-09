function C = msxfun(fn, varargin)
%% Just like bsxfun, except this takes in more than two matrices.
% (Performs binary reduction, just like python's reduce fuction)
% For three matrices, the following two code snippets are equivalent
% msxfun(fn, X1, X2, X3)
% bsxfun(fn, bsxfun(fn, X1, X2), X3)
%% Example
% msxfun(@times, rand(100, 1), rand(100, 100), rand(1, 100))
n = nargin - 1;
C = bsxfun(fn, varargin{1}, varargin{2});
for i=3:n
    C = bsxfun(fn, C, varargin{i});
end
end