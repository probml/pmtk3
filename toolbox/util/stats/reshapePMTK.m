function T = reshapePMTK(T, sizes)
% Like the built-in reshape, except reshapePMTK(T,n) == reshape(T,[n 1])

if isempty(sizes)
    return;
elseif numel(sizes)==1
    T = reshape(T, [sizes 1]);
else
    T = reshape(T, sizes(:)');
end

end