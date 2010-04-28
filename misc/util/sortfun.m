function x = sortfun(f,x)
% sort a cell array by some function of its elements, e.g. 
% sortfun(@(x)numel(x),C) sorts C by the number of elements in each cell. 
     x = x(sortidx(cellfun(f,x)));
end