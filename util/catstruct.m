function s = catstruct(s1,s2)
% combines two structs into one with the fields and values from both.     
    if(numel(intersect(fieldnames(s1),fieldnames(s2)))>0)
       error('Names are not unique'); 
    end
    
    s = s1;
    newnames = fieldnames(s2);
    for i=1:numel(newnames)
       s.(newnames{i}) = s2.(newnames{i});
    end
    
    
end