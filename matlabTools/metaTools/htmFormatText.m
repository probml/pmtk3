function S = htmFormatText(varargin)
%% Format a multiline comment for html 
% This is just like multiLineString except it adds html breaks <br> to the
% end of each line. 

% This file is from pmtk3.googlecode.com

stack = dbstack('-completenames');
if numel(stack) < 2
    error('This function cannot be called from the command prompt');
end
T = getText(stack(2).file);
T = T((stack(2).line):end);

start = cellfind(T, '%{', 1, 'first');
endl  = cellfind(T, '%}', 1, 'first'); 
T = strtrim(T(start+1:endl-1)); 
S = sprintf(catString(T, '<br>\n'), varargin{:}); 

end
