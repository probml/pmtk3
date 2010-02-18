function m = allMfilesOnPath()
% Returns a cell array of the names of every (non-matlab) m-file on
% the current path. 
p = mypath();
m = {};
for i=1:numel(p)
    m = [m; mfiles(p{i}, '-topOnly', true)]; %#ok
end
m = unique(m); 

end

