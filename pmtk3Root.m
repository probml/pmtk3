function r = pmtk3Root()
% Return directory name where pmtk is stored

% This file is from pmtk3.googlecode.com

w = which(mfilename()); 
if w(1) == '.' % for octave compatability
    w = fullfile(pwd, w(3:end)); 
end
r = fileparts(w);
end
