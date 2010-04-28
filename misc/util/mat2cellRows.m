function c = mat2cellRows(m)
% Converts an n-by-d numeric matrix 'm', to an n-by-1 cell array 'c', such that 
% c{i} = m(i,:) for all i in 1:size(m,1).
   
    c = mat2cell(m,ones(size(m,1),1));
end