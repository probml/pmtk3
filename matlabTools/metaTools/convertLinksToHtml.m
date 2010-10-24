function [text, ismodified] = convertLinksToHtml(text, name)
%% Convert any web links in the text to html by adding <a href> tags
% If any <a href ... tags already exist, nothing is done

% This file is from pmtk3.googlecode.com


if iscell(text)
    [text, ismodified] = cellfunc(@(text)convertLinksToHtml(text, name), text, 'UniformOutput', false);
    return;
end

if isSubstring('<a href', text); 
    ismodified = false;
    return; 
end

t = tokenize(strtrim(text), ' ');

www = find(cellfun(@(c)startswith(c, 'www.'), t));
for i=1:numel(www)
   if nargin < 2, name = t{www(i)}; end
   t{www(i)} = sprintf('<a href="http://%s">%s</a>', t{www(i)}, name);  
end
http = find(cellfun(@(c)startswith(c, 'http://'), t));
for i=1:numel(http)
    if nargin < 2, name = t{http(i)}; end
    t{http(i)} = sprintf('<a href="%s">%s</a>', t{http(i)}, name);  
end

ismodified = ~isempty(http) || ~isempty(www); 

text = catString(t, ' '); 

end
