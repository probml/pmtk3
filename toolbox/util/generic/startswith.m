function tf = startswith(str, prefix)
% Return true iff the string starts with the specified prefix

if iscell(str)
    tf = cellfuncell(@(s)startswith(s, prefix) , str);
   return 
end


tf = strncmp(str, prefix, length(prefix));
end