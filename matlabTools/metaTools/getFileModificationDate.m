function [datestr, time] = getFileModificationDate(file)
% Return the file modification date for the specified file.
%
%% Example 

% This file is from pmtk3.googlecode.com


d = dir(file); 
toks = tokenize(d.date, ' '); 
[datestr, time] = toks{:};
%{
[err, raw] = system(sprintf('dir /TC %s', file)); 
raw = cellfuncell(@strtrim,  tokenize(raw, '\n'));
raw = filterCell(raw, @(c)~isempty(c)); 
raw = raw{cellfun(@(c)~isempty(c), (regexp(raw, '\d\d\/\d\d/\d\d\d\d')))};
toks = tokenize(raw, ' '); 
datestr = catString(toks(1:3), ' '); 
if nargout > 1
    toks = tokenize(raw, '/ ');
    day = str2num(toks{1}); 
    month   = str2num(toks{2}); 
    year  = str2num(toks{3}); 
    time  = catString(toks(4:5), ' '); 
end
%}
end
