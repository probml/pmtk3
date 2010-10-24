function out = crossProduct(varargin)
%% Return the cartesian product, (all combinations) of the input lists
% out = crossProduct(A, B, C, ...) each row of outcontain all combinations
% of A, B, C, ... Example
% C = crossProduct(1:2, 2:4, 3:4)
%     1     2     3
%     2     2     3
%     1     3     3
%     2     3     3
%     1     4     3
%     2     4     3
%     1     2     4
%     2     2     4
%     1     3     4
%     2     3     4
%     1     4     4
%     2     4     4

% This file is from pmtk3.googlecode.com


out = gridSpace(varargin{:});  % works for any number of dimensions. 
%{
switch nargin
 case 2
  [C1, C2] = meshgrid(A, B);
  out = [C1(:) C2(:)];
 case 3
  [C1, C2, C3] = ndgrid(A, B,C );
  out = [C1(:) C2(:) C3(:)];
 otherwise
  error('not supported')
end

end
%}

end
