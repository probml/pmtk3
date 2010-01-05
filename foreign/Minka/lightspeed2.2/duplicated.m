function d = duplicated(x)
%DUPLICATED   Find duplicated rows.
% DUPLICATED(x) returns a vector d such that d(i) = 1 if x(i,:) is a 
% duplicate of an earlier row.
%
% Examples:
% duplicated([2 7 8 7 1 2 8]') = [0 0 0 1 0 1 1]'
% duplicated([0 0 1 1 0; 0 1 0 1 1]') = [0 0 0 0 1]'
% duplicated(eye(100))
% duplicated(kron((1:3)',ones(3)))
%
% You can simulate unique(x) or unique(x,'rows') by x(~duplicated(x)).
% The difference is that the latter form will not sort the contents of x, 
% as unique will.
%
% See also UNIQUE.

% (c) Microsoft Corporation. All rights reserved.

% This function is not well optimized.  
% In particular, it is slower than unique.

[nr,nc] = size(x);
if nc == 1
  d = duplicated1(x);
  return;
end
if nr == 1
  d = 0;
  return;
end
hash = x*rand(nc,1);
[dummy,ord] = sort(hash);
xo = x(ord,:);
%d = [0 all(diff(xo)==0,2)'];
d = [0 all(xo(1:end-1,:)==xo(2:end,:),2)'];
dd = diff([d 0]);
dstart = find(dd > 0);
dend = find(dd < 0);
% loop each run of duplicated columns
for i = 1:length(dstart)
  % place the zero at the first element in the original order
  d(dstart(i)) = 1;
  d(dstart(i)-1 + argmin(ord(dstart(i):dend(i)))) = 0;
end
d(ord) = d;
d = d';
%d = duplicated1(hash);

function d = duplicated1(x)
% special case where x is a column vector.

[s,ord] = sort(x);
d = zeros(size(x));
d(ord) = [0; s(1:end-1)==s(2:end)];
%d(ord) = [0; diff(s)==0];
