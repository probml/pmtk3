function s = rmfield(s,field)
%RMFIELD Remove fields from a mutable structure.
% rmfield(s,'field') removes the specified field from the mutable structure s.
% rmfield(s,fields) removes more than one field at a time when FIELDS is a 
% cell array of strings.  
%
% See also SETFIELD, GETFIELD, ISFIELD, FIELDNAMES.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

fields = s.obj.get('_fields');
if iscellstr(field)
  for i = 1:length(field)
    s.obj.remove(field{i});
    fields.removeElement(field{i});
  end
else
  s.obj.remove(field);
  fields.removeElement(field);
end
