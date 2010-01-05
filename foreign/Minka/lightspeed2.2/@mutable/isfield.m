function tf = isfield(s,f)
%ISFIELD True if field is in mutable structure.
% isfield(s,'field') returns true if 'field' is the name of a field in the
% mutable structure s.
%
% See also GETFIELD, SETFIELD, RMFIELD, FIELDNAMES.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

tf = s.obj.containsKey(f);
