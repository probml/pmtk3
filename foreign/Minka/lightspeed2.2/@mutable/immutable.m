function v = immutable(mut)
%IMMUTABLE     Convert to an ordinary (immutable) object.
% immutable(v) returns an immutable copy of the mutable object v, i.e. 
% converts v into an ordinary Matlab value.
%
% Examples:
%   x = mutable([1 2 3]);
%   sum(x)  % fails
%   sum(immutable(x))  % returns 6

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

v = fromJava(mut.obj);
