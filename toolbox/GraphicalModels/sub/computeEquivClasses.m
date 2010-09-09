function eqc = computeEquivClasses(pointers)
%% Return a cell array of equivalence classes corresponding to pointers
% 
%% Example
%
% computeEquivClasses([1 2 3 3 3 3 3 3 3 3])
%
% ans = {[1], [2], [3:10]}
%%

% This file is from pmtk3.googlecode.com

classes = 1:max(pointers); 
nclasses = numel(classes); 
eqc = cell(nclasses, 1); 
for i=1:nclasses
    eqc{i} = find(pointers == classes(i)); 
end


end

