function names = fieldnames(s)
%FIELDNAMES Get mutable structure field names.
% names = fieldnames(s) returns a cell array of strings containing the 
% structure field names associated with the mutable structure s.
%
% See also GETFIELD, SETFIELD, RMFIELD, ISFIELD.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

names = {};
ke = s.obj.get('_fields').elements;
while ke.hasMoreElements
  names{end+1} = ke.nextElement;
end
