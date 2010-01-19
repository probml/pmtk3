function tf = allSameTypes(cellArray)
% Return true if all of the objects in the cellArray are of the same class, i.e.
% all doubles or all MvnDist() objects etc - false otherwise. 
   c = class(cellArray{1});
   tf = cellfun(@(x)isequal(class(x),c),cellArray);
   tf = all(tf(:)); 
end