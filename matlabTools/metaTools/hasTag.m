function found = hasTag(filename, tag)
% Return true if the file has the specified tag. 

% This file is from pmtk3.googlecode.com

    found = ismember(tag, tagfinder(filename));
end
