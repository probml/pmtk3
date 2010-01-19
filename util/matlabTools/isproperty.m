function p = isproperty(class,prop)
   props = properties(class);
   p = ismember(prop,props);
end