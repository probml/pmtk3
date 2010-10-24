function p = isproperty(class,prop)
% Return true iff a specified class has a specific property
% PMTKneedsMatlab 2008

% This file is from pmtk3.googlecode.com

props = properties(class);
p = ismember(prop,props);
end
