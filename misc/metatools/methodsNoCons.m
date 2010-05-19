function m = methodsNoCons(classname)
% Return all of the methods of the class except the constructor
m = methods(classname);
m = setdiff(m,classname);
end