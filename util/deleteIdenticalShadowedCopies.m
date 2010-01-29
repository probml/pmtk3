function deleteIdenticalShadowedCopies()
% Searches through every m-file and deletes exact duplicates.     
    [info,mfiles] = mfilelist(PMTKroot());          %#ok
    
    for i=1:numel(mfiles)
        
       w = which('-all',mfiles{i});
       if(numel(w) == 2 && isequal(getText(w{1}),getText(w{2})))
           
           fprintf('removing...%s\n',w{2});
           delete(w{2});
           
       end
        
    end
    
    
end