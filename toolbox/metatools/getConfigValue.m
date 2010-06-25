function value = getConfigValue(var, ignoreLocal)
%% Return the value of a configuration variable stored in config.txt
% If a config-local.txt file is found, these value override config.txt's
% values. 
%% Example
% path = getConfigValue('PMTKsupportLink');

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
[tags, lines] = tagfinder(configFile);
S = createStruct(tags, lines);
if isfield(S, var)
    value = strtrim(S.(var));
else
    value = '';
end
%%
if isempty(value) && searchTwice 
    % search config.txt if not found in config-local.txt    
    [tags, lines] = tagfinder(generic);
    S = createStruct(tags, lines);
    if isfield(S, var)
        value = strtrim(S.(var));
    else
        value = '';
    end
end

end