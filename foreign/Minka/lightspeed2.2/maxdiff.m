function e = maxdiff(a,b,rel)
% MAXDIFF(A,B) returns the maximum difference in any field or element.
% Matching infinities or NaNs do not count.
%
% MAXDIFF(A,B,REL) measures the per-element relative difference (A-B)/(REL + A)
%
% Examples:
%   maxdiff([1 2 3 nan inf -inf],[1 2 4 nan inf -inf]) % = 1

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if nargin < 3
  rel = [];
end

e = 0;
if ~isequal(class(a), class(b))
  fprintf('maxdiff: incompatible types\n');
  e = Inf;
  return
end
if isa(a,'struct')
  for f = fieldnames(a)'
    field = char(f);
    if ~isfield(b,field)
      fprintf('maxdiff: second argument lacks field %s\n', field);
      e = Inf;
      return
    end
    e = max(e,maxdiff(a.(field), b.(field), rel));
  end
  return
end
if ~isequal(size(a),size(b))
  fprintf('maxdiff: size mismatch\n');
  e = Inf;
  return
end
a = a(:);
b = b(:);
if iscell(a)
  for i = 1:numel(a)
    e = max(e,maxdiff(a{i},b{i}));
  end
  return
end
i = isnan(a);
if any(i ~= isnan(b))
  % mismatched NaNs
  e = Inf;
  return
elseif sum(i) > 0
  a = a(~i);
  b = b(~i);
end
i = ~isfinite(a);
if any(i ~= ~isfinite(b))
  % mismatched infs
  e = Inf;
  return
elseif ~isequal(a(i),b(i))
  e = Inf;
  return
else
  a = a(~i);
  b = b(~i);
end
if isempty(a)
  e = 0;
  return
end
e = abs(a(:) - b(:));
if ~isempty(rel)
  e = e ./ (rel + abs(a(:)));
end
e = max(e);
