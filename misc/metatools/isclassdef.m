function bool = isclassdef(classname)
% Test is a class by the specified name exists on the Matlab path
if iscellstr(classname)
    bool = cellfun(@isclassdef,classname);
    return;
end
if exist(classname,'file') ~= 2;
    bool = false; return;
end
bool = ~isempty(meta.class.fromName(classname));
end