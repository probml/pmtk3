function r = pmtk3Root()
% Return directory name where pmtk is stored
w = which(mfilename()); 
if w(1) == '.' % for octave compatability
    w = fullfile(pwd, w(3:end)); 
end
r = fileparts(w);
end
