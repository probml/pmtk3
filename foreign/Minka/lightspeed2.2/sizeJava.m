function sz = sizeJava(jv)
% sizeJava(jv) returns the size of a java array, in a manner corresponding
% to 'size' on matlab arrays.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

sz(1) = size(jv,1);
sz(2) = size(jv(1,:),1);
if sz(2) == 0
  % workaround matlab's bug
  sz(2) = 1;
end
