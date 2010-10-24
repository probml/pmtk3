function name = funcName(fn)
% Just like built in func2str except it removes @() prefixes and ()
% suffixes. 

% This file is from pmtk3.googlecode.com


s = func2str(fn); 
if startswith(s, '@')
    toks = tokenize(s, '()');
    name = toks{3};
else
    name = s;
end



end
