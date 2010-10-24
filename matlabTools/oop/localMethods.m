function local = localMethods(classname,allowAbstract)
% Return the local methods of a class
% - see islocal() for a description of what 'local' means.
% PMTKneedsMatlab 2008

% This file is from pmtk3.googlecode.com

if nargin < 2, allowAbstract = false; end
m = methods(classname); if isempty(m), local = {}; return; end
local = filterCell(methods(classname),@(m)islocal(m,classname,allowAbstract));

end
