function r = pmtk3Root()
% Return directory name where pmtk is stored
[pathstr,name,ext,versn] = fileparts(which('pmtk3Root.m'));
r = pathstr;
end
