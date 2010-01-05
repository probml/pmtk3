function mut = subsasgn(mut,index,v)

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

subsasgnJava(mut.obj,index,v,mut.cl);

function subsasgnJava(jv,index,v,cl)

if nargin < 4
  % class(jv) is expensive, so we do it only once
  cl = class(jv);
end
if strcmp(cl,'java.util.Hashtable')
  % don't bother checking the type
  %if strcmp(index(1).type,'.')
  f = index(1).subs;
  if length(index) > 1
    jv = jv.get(f);
    if isempty(jv)
      error(sprintf('Reference to non-existent field ''%s''.',f));
    end
    % recurse on remaining subscripts
    subsasgnJava(jv,index(2:end),v);
  else
    if ~jv.containsKey(f)
      % add a new field
      jv.get('_fields').addElement(f);
    end
    jv.put(f,toJava(v));
  end
  return
elseif strcmp(cl,'java.lang.Double[][]') | strcmp(cl,'java.lang.Object[][]')
  if length(index(1).subs) == 1
    % convert single index to a full index
    i = index(1).subs{1};
    if length(i) > 1
      error('a single array of indices is not supported');
    end
    s = sizeJava(jv);
    index(1).subs = num2cell(ind2subv(s,i),1);
  end
  if strcmp(cl,'java.lang.Object[][]')
    % cell array
    if strcmp(index(1).type,'{}')
      index(1).type = '()';
    end
  end
  % fall through
elseif strcmp(cl,'java.util.Vector') | strcmp(cl,'java.util.BitSet')
  % empty array
  error('Index exceeds matrix dimensions.');
end
% use built-in subsasgn
subsasgn(jv,index,toJava(v));
