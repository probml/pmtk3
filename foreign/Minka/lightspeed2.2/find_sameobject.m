function i = find_sameobject(x,v)
% Returns the index of the first element of x which is the same object as v.
% x is a cell array.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

for i = 1:length(x)
  if sameobject(x{i},v)
    return
  end
end
i = length(x)+1;
