function p = isproperty(class,prop)
% Return true iff a specified class has a specific property
% PMTKneedsMatlab 2008
props = properties(class);
p = ismember(prop,props);
end