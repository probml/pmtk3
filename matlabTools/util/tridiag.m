function D = tridiag(A, B, C, useSparse)
% Make a tri-diagonal matrix from a matrix or from 3 vectors
% 
% D = tridiag(A) sets all elements of A outside the tridiagonal to 0
% If A is sparse, D will also be sparse.
%
% D = tridiag(main, upper, lower) constructs a matrix with these
% vectors on the diagonal and just above and below.
%
% D = tridiag(main, upper, lower, 1) returns a sparse result.
%
% EXAMPLES
%
%>> tridiag(rand(4,4))
%ans =
%    0.2407    0.1423         0         0
%    0.0178    0.0487    0.7064         0
%         0    0.2273    0.6902    0.1960
%         0         0    0.1284    0.3151
%
%>> tridiag(1:5, 6:9, 10:13)
%ans =
%     1     6     0     0     0
%    10     2     7     0     0
%     0    11     3     8     0
%     0     0    12     4     9
%     0     0     0    13     5
%
%>> tridiag(1:5,6:9,10:13, 1) % sparse
%ans =
%   (1,1)        1,   (2,1)       10,    (1,2)        6 etc
%
% To make a block tridiagonal system with repetitive blocks,
% follow this example
%
%>> kron(eye(2),[4 -1 0; -1 4 0; 0 -1 4])
%ans =
%     4    -1     0     0     0     0
%    -1     4     0     0     0     0
%     0    -1     4     0     0     0
%     0     0     0     4    -1     0
%     0     0     0    -1     4     0
%     0     0     0     0    -1     4
%   
% See also BLKDIAG (built in)
% and BLKTRIDIAG available from
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=10603
%
% Kevin Murphy, 4 June 2006

% This file is from pmtk3.googlecode.com


if nargin == 1
  if issparse(A)
    D = mkFromVectorsSparse(diag(A),diag(A,1),diag(A,-1));
  else
    D = mkFromVectors(diag(A),diag(A,1),diag(A,-1));
  end
else
  if nargin < 4, useSparse = 0; end
  if useSparse
    D = mkFromVectorsSparse(A,B,C);
  else
    D = mkFromVectors(A,B,C);
  end
end
end
%%%%%%%%%%%

function M = mkFromVectorsSparse(main, upper, lower)

n = length(main);
rows = [1:n 2:n 1:n-1];
cols = [1:n 1:n-1 2:n];
s = [main(:)' lower(:)' upper(:)'];
M = sparse(rows, cols, s);
end
%%%%%%%%%%%

function M = mkFromVectors(main, upper, lower)

M = diag(main,0) + diag(upper,1) + diag(lower,-1);


end
