function s = setfield(s,field,v)
%SETFIELD Set mutable structure field contents.
% setfield(s,'field',v) sets the contents of the specified field to the 
% value V.  This is equivalent to the syntax S.field = V.
%
% See also GETFIELD, RMFIELD, ISFIELD, FIELDNAMES.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

jv = s.obj;
if ~jv.containsKey(field)
  % add a new field
  jv.get('_fields').addElement(field);
end
jv.put(field,asJava(v));
