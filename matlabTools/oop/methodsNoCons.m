function m = methodsNoCons(classname)
% Return all of the methods of the class except the constructor
% PMTKneedsMatlab 2008

% This file is from matlabtools.googlecode.com

m = methods(classname);
m = setdiff(m,classname);
end
