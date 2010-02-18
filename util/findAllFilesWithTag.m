function mfiles = findAllFilesWithTag(tag)
% Find all of the files in the PMTK directory structure that have the specified
% tag. 
    if tag(1) == '%', tag(1) = []; end
    tag = strtrim(tag); 
    cd(pmtk3Root());
    [info,allfiles] = mfilelist();
    mfiles = {};
    for i=1:numel(allfiles)
        fpath = which(allfiles{i});
        if isempty(fpath), continue; end
        if(tagsearch(fpath, tag))
           mfiles = [mfiles,allfiles{i}]; 
        end
    end
    mfiles = mfiles';
    
end