function found = hasTag(filename, tag)
% Return true if the file has the specified tag. 
    found = ismember(tag, tagfinder(filename));
end