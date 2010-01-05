function mut = mutable(v)
%MUTABLE    Convert to a mutable object.
% mutable(v) returns a mutable copy of v.  
% v can be a numeric array, cell array, or structure (but not a string or 
% user-defined object).
% mutable (with no arguments) is equivalent to mutable(0).
%
% Mutable objects are special because if you change them, the changes are 
% visible to all parts of the program.  Ordinary Matlab values do not
% have this property; changes must be explicitly passed from one routine
% to another.
%
% A mutable object is accessed and modified via subscripted reference, such
% as x.a or x(5).  Mutable structures support getfield, setfield, rmfield,
% isfield, and fieldnames.
%
% The result is mutable all the way down, e.g. if
%   x = mutable(struct('a',[4 5]))
% then x.a and x.a(1) are mutable.
%
% Fields can be added to mutable structures but mutable arrays cannot be 
% resized.  Thus there is little point to mutable([]) or mutable({}).
%
% A mutable object cannot be used as an ordinary Matlab value, e.g. in 
% matrix operations.  Use 'immutable' to convert to a Matlab value.
%
% Mutable objects are less efficient than ordinary matlab values, so
% you should use them sparingly.  Mutable structures are the most efficient,
% followed by cell arrays and then numeric arrays.
%
% Examples:
%   x = mutable;
%   y = x;   % y is a reference, not a copy
%   x(1) = 4;
%   y(1)  % prints 4
%
%   x = mutable(struct);
%   y = x;   % y is a reference, not a copy
%   x.a = 4; % add new field
%   y.a      % prints 4
%
% See also IMMUTABLE.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if nargin < 1
  v = 0;
end
% java object must be a collection
mut.obj = toJava(v,1);
% cache the class name, to save time
mut.cl = class(mut.obj);
mut = class(mut,'mutable');
