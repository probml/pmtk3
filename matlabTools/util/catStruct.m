function s = catStruct(s1,s2)
% Combine two structs into one with the fields and values from both

% This file is from pmtk3.googlecode.com

if(numel(intersect(fieldnames(s1),fieldnames(s2)))>0)
    error('Names are not unique');
end

s = s1;
newnames = fieldnames(s2);
for i=1:numel(newnames)
    s.(newnames{i}) = s2.(newnames{i});
end


end
