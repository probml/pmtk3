function f = findIdenticalShadowedCopies()
% Searches through every m-file and deletes exact duplicates.     
    [info,mfiles] = mfilelist(pmtk3Root());          %#ok
    f = {}; 
    for i=1:numel(mfiles)
       w = which('-all',mfiles{i});
       if(numel(w) == 2 && isequal(getText(w{1}),getText(w{2})))
           f = [f, w{2}]; %#ok
       end
        
    end
    f = f';
    
end