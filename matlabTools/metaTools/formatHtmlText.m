function S = formatHtmlText(txt, varargin)
%% Format multiline text for inclusion in an html report
% This is like sprintf, but txt is a cell array. Each entry in the array
% is treated as a separate line with html <br> breaks added to the end of 
% each.
%
% 
%%

% This file is from pmtk3.googlecode.com

S = sprintf(catString(txt, '<br>\n'), varargin{:}); 
end
