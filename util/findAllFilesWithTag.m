function mfiles = findAllFilesWithTag(tag)
% Find all of the files in the PMTK directory structure that have the specified
% tag. 
    cd(PMTKroot());
    [info,allfiles] = mfilelist();
    mfiles = {};
    for i=1:numel(allfiles)
        if(tagsearch(which(allfiles{i}),tag))
           mfiles = [mfiles,allfiles{i}]; 
        end
    end
    
end