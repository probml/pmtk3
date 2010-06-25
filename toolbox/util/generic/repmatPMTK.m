function T = repmatPMTK(T, sizes)
% Like the built-in repmat, except repmatPMTK(T,n) == repmat(T,[n 1])


if length(sizes)==1
  T = repmat(T, [sizes 1]);
else
  T = repmat(T, sizes(:)');
end

end