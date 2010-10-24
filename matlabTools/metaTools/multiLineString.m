function S = multiLineString(varargin)
%% Parses the multiline comment just below where it is called
%
% 
%
%% Example
%
%
% function foo
%     
% S = multiLineString('test', 3);
% %{
% The text here will be converted to a string using sprintf like syntax
% so that this %s is converted to 'test' and this %d is converted to 3.
% New lines are inserted for every new line of this comment, and the
% multiline string ends when I end the block comment.
%
% %}
%  
% S now stores the text above with the '%' leading symbols removed.
%
%
%
%%

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
S = sprintf(catString(T, '\n'), varargin{:}); 
end
