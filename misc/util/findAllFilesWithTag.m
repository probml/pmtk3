function m = findAllFilesWithTag(tag)
% Find all of the files in the PMTK directory structure that have the specified
% tag. 
    if tag(1) == '%', tag(1) = []; end
    tag = strtrim(tag); 
    cd(pmtk3Root());
    allfiles = mfiles();
    m = {};
    for i=1:numel(allfiles)
        fpath = which(allfiles{i});
        if isempty(fpath), continue; end
        if(hasTag(fpath, tag))
           m = [m,allfiles{i}]; 
        end
    end
    m = m';
    
end