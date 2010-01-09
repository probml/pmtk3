function r = pmtkRoot()
% Return directory name where pmtk is stored
[pathstr,name,ext,versn] = fileparts(which('pmtkRoot.m'));
r = pathstr;
end
