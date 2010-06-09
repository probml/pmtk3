function removePath(p)
% Like builtin rmpath function, but does not issue a warning if p is not on the path.
if ischar(p)
    p = tokenize(p, ';');
end
for i=1:numel(p)
    if onMatlabPath(p{i})
        rmpath(p{i})
    end
end
end