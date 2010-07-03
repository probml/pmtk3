function T = repmatPMTK(T, sizes)
% Like the built-in repmat, except repmatPMTK(T,n) == repmat(T,[n 1])


if length(sizes)==1
    T = repmatC(T, [sizes 1]);
else
    T = repmatC(T, sizes(:)');
end

end