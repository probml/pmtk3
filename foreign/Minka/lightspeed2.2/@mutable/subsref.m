function v = subsref(mut,index)

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

v = subsrefJava(mut.obj,index,mut.cl);

function v = subsrefJava(jv,index,cl)

if nargin < 3
  % class(jv) is expensive, so we do it only once
  cl = class(jv);
end
wantcell = 0;
if strcmp(cl,'java.util.Hashtable')
  % don't bother checking the type
  %if strcmp(index(1).type,'.')
  f = index(1).subs;
  v = jv.get(f);
  if isempty(v)
    error(sprintf('Reference to non-existent field ''%s''.',f));
  end
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
    else
      % type is '()' for a cell array
      wantcell = 1;
      % if the subscript has more than one element, the result will already 
      % be a cell array
      for i = index(1).subs
	if length(i{1}) > 1
	  wantcell = 0;
	  break
	end
      end
    end
  end
  v = subsref(jv,index(1));
elseif strcmp(cl,'java.util.Vector') | strcmp(cl,'java.util.BitSet')
  % empty array
  error('Index exceeds matrix dimensions.');
else
  % use built-in subsref
  v = subsref(jv,index(1));
end
if length(index) > 1
  % recurse on remaining subscripts
  v = subsrefJava(v,index(2:end));
else
  v = fromJava(v);
  if wantcell
    v = {v};
  end
end

