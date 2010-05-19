function tf = startswith(str, prefix)
% Return true iff the string starts with the specified prefix
tf = strncmp(str, prefix, length(prefix));
end