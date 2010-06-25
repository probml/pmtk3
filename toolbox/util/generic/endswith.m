function tf = endswith(str, suffix)
% Return true if the string ends in the specified suffix

n = length(suffix);
if length(str) < n
    tf =  false;
else
    tf = strcmp(str(end-n+1:end), suffix);
end

end