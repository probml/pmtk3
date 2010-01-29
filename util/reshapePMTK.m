function T = reshapePMTK(T, sizes)
% reshapePMTK Like the built-in reshape, except reshapePMTK(T,n) == reshape(T,[n 1])
% T = reshapePMTK(T, sizes)

if isempty(sizes)
  return;
elseif numel(sizes)==1
  T = reshape(T, [sizes 1]);
else
  T = reshape(T, sizes(:)');
end
