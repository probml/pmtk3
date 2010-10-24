function m = methodsNoCons(classname)
% Return all of the methods of the class except the constructor
% PMTKneedsMatlab 2008

% This file is from pmtk3.googlecode.com

m = methods(classname);
m = setdiff(m,classname);
end
