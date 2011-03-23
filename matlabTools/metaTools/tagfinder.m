function [tags, lines, codeLength, text] = tagfinder(filename, tagList)
% Find all of the tags in the given file
% Tags begin with PMTK, contain at least one other character, no spaces,
% and must reside within an m-file comment. The file must be on the Matlab
% path, and the tag must be a valid variable name, i.e. cannot contain
% characters like ':', etc. 
%
% e.g., 
% %PMTKurl home/kpmurphy/pmtksupport/meta/foo
%
% INPUT
%      filename   - the file to search
%      tagList    - optional (limit the search to only these tags)
%
% OUTPUT
%   tags  - a cell array of all of the tags found
%   lines - the remaining text on the same line
%   codeLength - the number of lines of code & comments in the file, (but
%                not blank spaces)
%   text  - the full text of the file
%%

% This file is from pmtk3.googlecode.com

text = getText(filename);
codeLength = numel(filterCell(cellfuncell(@(s)strtrim(s), text), @(s)~isempty(s)));
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
    hashNDX = strfind(line, 'PMTK');
    if(hashNDX == numel(line))
        continue;
    end
    if(isspace(line(hashNDX+1)))
        continue;
    end
    if(~isempty(hashNDX))
        prefix = line(1:hashNDX-1);
        prefix(prefix == '%') = [];
        prefix(prefix == ' ') = [];
        if ~isempty(prefix)
            continue;
        end
        [newtag, remaining] = strtok(line(hashNDX:end), ' ');
        if(nargin < 2 || (nargin > 1 && ismember(newtag, tagList)))
            tags = [tags; {newtag}];
            if(isempty(remaining))
                remaining = ' ';
            end
            lines = [lines; {remaining}];
        end
    end
end

remove = cellfun(@(c)~isvarname(c) || length(c) < 5, tags); 
tags(remove) = [];
lines(remove) = []; 



end
