function T = repmatPMTK(T, sizes)
% repmatPMTK Like the built-in repmat, except repmatPMTK(T,n) == repmat(T,[n 1])
% T = repmatPMTK(T, sizes)

if length(sizes)==1
  T = repmat(T, [sizes 1]);
else
  T = repmat(T, sizes(:)');
end
