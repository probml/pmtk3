function value = getConfigValue(var, ignoreLocal)
%% Return the value of a configuration variable stored in config.txt
% If a config-local.txt file is found, its values override config.txt's
% values.
%% Example
% path = getConfigValue('PMTKsupportLink');

% This file is from pmtk3.googlecode.com


if nargin < 2, ignoreLocal = false; end % if true, ignore config-local.txt

local = fullfile(pmtk3Root(), 'config-local.txt');
generic = fullfile(pmtk3Root(), 'config.txt');
if exist(local, 'file') && ~ignoreLocal
    configFile = local;
    searchTwice = true;
else
    configFile = generic;
    searchTwice = false;
end
%%
[tags, lines] = getTags(configFile);
S = struct;
for i=1:numel(tags);
    S.(tags{i}) = lines{i};
end
if isfield(S, var)
    value = strtrim(S.(var));
else
    value = '';
end
%%
if isempty(value) && searchTwice
    % search config.txt if not found in config-local.txt
    [tags, lines] = getTags(generic);
    S = struct;
    for i=1:numel(tags);
        S.(tags{i}) = lines{i};
    end
    if isfield(S, var)
        value = strtrim(S.(var));
    else
        value = '';
    end
end
end

function [tags, lines] = getTags(textFile)
%% get tags and lines from a config file
w = which(textFile);
if w(1) == '.'
    w = fullfile(pwd, w(3:end)); 
end
if ~isempty(w)
    textFile = w;
end
fid = fopen(textFile);
alloc = cell(100, 1);
text  = alloc;
i = 1;
while(true)
    tline = fgetl(fid);
    if ~ischar(tline)
        break;
    end
    text{i} = tline;
    i = i+1;
    if i > numel(text)
        text = [text; alloc]; %#ok
    end
end
text = text(1:i-1);
fclose(fid);
tags = {};
lines = {};
for i=1:numel(text)
    line = text{i};
    trimline = strtrim(line);
    if(numel(trimline) == 0), continue; end
    if(trimline(1) ~= '%'),   continue; end
    hashNDX = strfind(line, 'PMTK');
    if(hashNDX == numel(line)),     continue; end
    if(isspace(line(hashNDX+1))),   continue; end
    if(~isempty(hashNDX))
        prefix = line(1:hashNDX-1);
        prefix(prefix == '%') = [];
        prefix(prefix == ' ') = [];
        if ~isempty(prefix)
            continue;
        end
        [newtag, remaining] = strtok(line(hashNDX:end), ' ');
        if(nargin < 2 || (nargin > 1 && ismember(newtag, tagList)))
            tags = [tags; {newtag}];%#ok
            if(isempty(remaining))
                remaining = ' ';
            end
            lines = [lines; {remaining}]; %#ok
        end
    end
end
%remove = cellfun(@(c)~isvarname(c) || length(c) < 5, tags); 
remove = [];
for i=1:numel(tags)
  c = tags{i};
  if ~isvarname(c) || length(c) < 5
    remove = [remove i];
  end
end
tags(remove) = [];
lines(remove) = []; 
end
