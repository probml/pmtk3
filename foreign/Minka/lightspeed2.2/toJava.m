function jv = toJava(v,collection)
%toJava       Convert to Java representation.
% toJava(v) returns a Java object representing the matlab value v.
% toJava(v,1) requires the result to be a collection, not a simple object
% such as java.lang.Double.
%
% Conversions:
% scalar           -> java.lang.Double
% numeric array    -> javaArray of Double
% character array  -> java.lang.String or array of same
% empty array      -> java.util.Vector
% cell array       -> javaArray of Objects
% empty cell array -> java.util.BitSet
% structure        -> java.util.HashTable
% class            -> struct with '_class' property
%
% See also fromJava.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if nargin < 2
  collection = 0;
end
% in case v already is a Java object
jv = v;
if isnumeric(v)
  if isempty(v)
    jv = java.util.Vector;
  elseif length(v) == 1
    if collection
      jv = javaArray('java.lang.Double',1);
      jv(1) = java.lang.Double(v);
    else
      jv = java.lang.Double(v);
    end
  else
    sz = size(v);
    jv = javaArray('java.lang.Double',sz);
    v = v(:);
    for i = 1:prod(sz)
      index = substruct('()',num2cell(ind2subv(sz,i)));
      subsasgn(jv,index,toJava(v(i)));
    end
  end
  return
end
if ischar(v)
  n = rows(v);
  if n == 1 & ~collection
    jv = java.lang.String(v);
  else
    jv = javaArray('java.lang.String',n);
    for i = 1:n
      jv(i) = java.lang.String(deblank(v(i,:)));
    end
  end
end
if iscell(v)
  if isempty(v)
    jv = java.util.BitSet;
  else
    sz = size(v);
    jv = javaArray('java.lang.Object',sz);
    v = v(:);
    for i = 1:prod(sz)
      index = substruct('()',num2cell(ind2subv(sz,i)));
      subsasgn(jv,index,toJava(v{i}));
    end
  end
  return
end
if isobject(v) | isstruct(v)
  jv = java.util.Hashtable;
  if isobject(v)
    jv.put('_class',class(v));
    v = struct(v);
  end
  % record the order of the fieldnames
  fields = java.util.Vector;
  for f = fieldnames(v)'
    fields.addElement(char(f));
    jv.put(char(f),toJava(getfield(v,char(f))));
  end
  jv.put('_fields',fields);
  return
end
