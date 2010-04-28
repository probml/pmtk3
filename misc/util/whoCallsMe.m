function [list, m, g, map] = whoCallsMe(fname)
% Return a list of all of the mfiles on the current path that call
% the specified fname. 
%
% m is a list of all of the (non-built-in) matlab files on your path
% g is an adjacency matrix s.t. g(i, j) = true iff m{i} calls m{j}.
% map is a struct mapping mfile names to indices into m and g. 
%
w = which(fname);
if isempty(w)
    list = []; g = []; map = struct();  
    fprintf('%s is not on your path!\n', fname);
    return
end
if startswith(w, matlabroot)
    list = []; g = []; map = struct();  
    fprintf('%s is a built-in matlab function.\n', fname);
    return 
end

warning off %#ok
if endswith(fname, '.m'), fname = fname(1:end-2); end

m = cellfuncell(@(s)s(1:end-2),allMfilesOnPath);
map = enumerate(m);
g = false(numel(m));

for i=1:numel(m)
    from = map.(m{i});
    toAll = depfunFast(m{i}, false);
    for j=1:numel(toAll)
       [path, f] = fileparts(toAll{j});  
       if isfield(map, f)
            to = map.(f);
            g(from, to) = true; 
       end
       
    end
end
g = setdiag(g, 0); 
list = m(g(:, map.(fname)));
warning on %#ok





end