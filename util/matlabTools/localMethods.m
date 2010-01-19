function local = localMethods(classname,allowAbstract)
%LOCALMETHODS Return the local methods of a class - see islocal() for a
%description of what 'local' means.

    if nargin < 2, allowAbstract = false; end
    m = methods(classname); if isempty(m), local = {}; return; end
    local = filterCell(methods(classname),@(m)islocal(m,classname,allowAbstract));
 
end