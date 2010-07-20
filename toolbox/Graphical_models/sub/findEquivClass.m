function eqc = findEquivClass(pointers, i)
%% Return the equivalence class for representative i
eqc = find(pointers == i);
end