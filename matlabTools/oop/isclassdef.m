function bool = isclassdef(classname)
% Test if a class by the specified name exists on the Matlab path
% PMTKneedsMatlab 2008

% This file is from pmtk3.googlecode.com

if iscellstr(classname)
    bool = cellfun(@isclassdef,classname);
    return;
end
if exist(classname,'file') ~= 2;
    bool = false; return;
end
bool = ~isempty(meta.class.fromName(classname));
end
