function m = allMfilesOnPath()
% Return a list of all of the non-built-in .m files on the matlab path
p = mypath();
m = {};
for i=1:numel(p)
    m = [m; mfiles(p{i}, 'topOnly', true)]; %#ok
end
m = unique(m); 

end

