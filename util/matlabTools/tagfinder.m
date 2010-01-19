function [tags,lines] = tagfinder(filename,tagList)
% Find all of the tags in the given file. Tags begin with a # character, contain
% at least one other character, no spaces, and must reside within an m-file
% comment. The file must be on the Matlab path. 
%
% INPUT   
%      filename   - the m-file to search
%      tagList    - optional (limit the search to only these tags)
% 
% OUTPUT
%   tags  - a cell array of all of the tags found
%   lines - the remaining text on the same line as but following each tag in
%           tags.

    text = getText(filename);
    tags = {};
    lines = {};
    for i=1:numel(text)
       line = text{i};
       trimline = strtrim(line);
       if(numel(trimline) == 0)
           continue;
       end
       if(trimline(1) ~= '%')
           continue;
       end
       hashNDX = strfind(line,'#');
       if(hashNDX == numel(line))    
           continue;
       end
       if(isspace(line(hashNDX+1)))
           continue;
       end
       if(~isempty(hashNDX))
           [newtag,remaining] = strtok(line(hashNDX:end),' ');
           if(nargin < 2 || (nargin > 1 && ismember(newtag,tagList)))
                tags = [tags;newtag];
                if(isempty(remaining))
                    remaining = ' ';
                end
                lines = [lines;remaining];
           end
       end
    end

    
    
    
    
end