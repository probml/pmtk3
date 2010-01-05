function v = getfield(s,field)
%GETFIELD Get mutable structure field contents.
% f = getfield(s,'field') returns the contents of the specified field.  
% This is equivalent to the syntax f = s.field.
%
% See also SETFIELD, RMFIELD, ISFIELD, FIELDNAMES.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

v = s.obj.get(field);
if isempty(v)
  error(sprintf('Reference to non-existent field ''%s''.',field));
end
v = fromJava(v);
