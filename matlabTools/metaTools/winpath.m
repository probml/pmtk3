function p = winpath()
% Returns the current windows path in a cell array.
% PMTKneedsMatlab

% This file is from pmtk3.googlecode.com

[err,wpath] = system('path');   % grab whole path string
wpath = wpath(6:end);           % first 5 chars are PATH=
p = textscan(wpath,'%s','delimiter',';');
p = p{:};

end
