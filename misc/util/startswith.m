function tf = startswith(str, prefix)

    tf = strncmp(str, prefix, length(prefix));
end