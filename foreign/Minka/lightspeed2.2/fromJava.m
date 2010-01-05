function v = fromJava(jv)
%fromJava    Convert from Java to Matlab.
% fromJava(jv) converts a Java object back into a matlab object, reversing
% the action of toJava.
%
% See also toJava.

% Written by Thomas Minka
% (c) Microsoft Corporation. All rights reserved.

if ~isjava(jv)
  v = jv;
  return
end
% class(jv) is expensive, so we do it only once
cl = class(jv);
% common cases first
if strncmp(cl,'java.lang.Double',16)
  v = double(jv);
  return
end
if strncmp(cl,'java.lang.String',16)
  v = char(jv);
  return
end
if strncmp(cl,'java.lang.Object[]',18)
  sz = sizeJava(jv);
  v = cell(1,prod(sz));  
  for i = 1:length(v)
    index = substruct('()',num2cell(ind2subv(sz,i)));
    elt = subsref(jv,index);
    v{i} = fromJava(elt);
    % this also works:
    %v = subsasgn(v,index,elt);
  end
  v = reshape(v,sz);
  return
end
if strcmp(cl,'java.util.Hashtable')
  v = struct;
  fields = jv.get('_fields');
  if ~isempty(fields)
    % create the fields in the right order
    ke = fields.elements;
  else
    % create the fields in random order
    ke = jv.keys;
  end
  while ke.hasMoreElements
    f = ke.nextElement;
    v = setfield(v,char(f),fromJava(jv.get(f)));
  end
  c = jv.get('_class');
  if ~isempty(c)
    % call the class constructor with the structure as argument
    % (doesn't work for all classes)
    v = feval(c,v);
  end
  return
end
if strcmp(cl,'java.util.Vector')
  v = [];
  return
end
if strcmp(cl,'java.util.BitSet')
  v = {};
  return
end
% use matlab's builtin converter from java.lang.Object
vec = java.util.Vector;
vec.addElement(jv);
v = vec.elementAt(0);
