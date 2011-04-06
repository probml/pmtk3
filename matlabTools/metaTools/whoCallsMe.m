function [list, m, g, map] = whoCallsMe(fname, varargin)
% Find out who calls a certain function
% Return a list of all of the mfiles on the current path that call
% the specified fname. This is a simple inverted map of the standard
% dependency report. 
%
%% Inputs
% 
% fname  - the name of the file, (passed to which)
% 
%% Optional named inputs
%
% recache   -  [false] recache the call graph
% recursive -  [false] if true, all files that depend, (even indirectly)
%                      on the specified file are returned. 
% verbose   -  [true]  
%% Outputs
% list      - a list of all of the files that call/depend on fname
% m         - a list of all user mfiles on the matlab path
% g         - an adjacency matrix, s.t. g(i, j) iff m{i} calls m{j}
% map       - map is a struct mapping mfile names to indicies into m and g
%%

% This file is from pmtk3.googlecode.com

[recache, recursive, verbose, skipBuiltin] = process_options(varargin, ...
    'recache'  , false, ...
    'recursive', false, ...
    'verbose',   true, ...
    'skipBuiltin', true);
%%
w = which(fname);

if isempty(w)
    list = []; g = []; map = struct();
    if verbose
        fprintf('%s is not on your path!\n', fname);
    end
    return
end
if skipBuiltin && (startswith(w, matlabroot) || startswith(w, 'built-in ('))
    list = []; m =[]; g = []; map = struct();
    if verbose
        fprintf('%s is a built-in matlab function.\n', fname);
    end
    return
end
fname = argout(2, @fileparts, w); 
savefile = fullfile(tempdir(), 'PMTKcallReport.mat');
savefileR = fullfile(tempdir(), 'PMTKdepReport.mat');
if recursive && exist(savefileR, 'file') && ~recache;
    load(savefileR);
elseif exist(savefile, 'file') && ~recache;
    load(savefile);
else
    if verbose
        fprintf('recaching - this may take a while\n');
    end
    m = cellfuncell(@(s)s(1:end-2), allMfilesOnPath);
    m = filterCell(m, @isvarname); 
    map = enumerate(m);
    g = false(numel(m));
    for i=1:numel(m)
        from = map.(m{i});
        try
            toAll = depfunFast(m{i}, recursive);
        catch %#ok
            toAll = {};
        end
        for j=1:numel(toAll)
            [path, f] = fileparts(toAll{j});
            if isfield(map, f)
                to = map.(f);
                g(from, to) = true;
            end   
        end
    end
    g = setdiag(g, 0);
    if recursive
        save(savefileR, 'g', 'm', 'map');
    else
        save(savefile, 'g', 'm', 'map');
    end
end
try
    list = m(g(:, map.(fname)));
catch ME
    if recache
        rethrow(ME)
    else
        fprintf('The dependency graph is out of date\n\n'); 
        [list, m, g, map] = whoCallsMe(fname, 'recache', true, ...
        'recursive', recursive, 'verbose', verbose, 'skipBuiltin', skipBuiltin);
    end
end


end
