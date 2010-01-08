function tf = issubstring(a,b,ignoreCase)
% return true, iff 'a' is a substring of 'b'
    if nargin < 3, ignoreCase = false; end
    if ignoreCase
        tf =  ~isempty(strfind(lower(b),lower(a)));
    else
        tf = ~isempty(strfind(b,a));
    end
end