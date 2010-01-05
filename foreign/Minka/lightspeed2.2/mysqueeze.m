function x = mysqueeze(x)
% Like squeeze(x), but row vectors become columns.

% Written by Thomas P Minka

s = size(x);
dim = find(s==1);
if ~isempty(dim)
  s(dim) = [];
  % [1 1] handles special cases
  x = reshape(x,[s 1 1]);
end
