function moveFiles(listFile)
    
    fid = fopen(listFile);
    list = textscan(fid,'%s');
    fclose(fid);
    list = list{:};
    
    list = cellfun(@(str)parse(str),list,'UniformOutput',false);
   !mkdir filesFromList
    for i=1:numel(list)
        system(['move ', list{i}, ' .\filesFromList\',list{i}]);
    end
    
    
    
    
    function filename = parse(str)
       [junk, remaining] = strtok(str,'{');
       filename = strtok(remaining,'}');
       filename = filename(2:end);
    end
   
end