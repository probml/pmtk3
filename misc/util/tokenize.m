function tokens = tokenize(str, delimiter)
% tokenize a string
% If delmiter is more than one character, it is assumed that you want
% to tokenize based on multiple delimiters - if not use regexp instead.
%
% Empty cells are removed
%% Example
% str = 'a;man;a;,plan;a ,,,canal;panama! '
% delimiters = ';, '; % split at ;, or space
% tokenize(str, delimiters)
% ans =
%     'a'
%     'man'
%     'a'
%     'plan'
%     'a'
%     'canal'
%     'panama!'
%
% Note, Matlab's regexp does a lot of this work automatically if you use
% 'split' mode, but Octave does not support this, hence the following code.

if(nargin < 2)
    delimiter = ' ' ;
end
try 
    tokens = textscan(str,'%s','delimiter',delimiter, 'bufsize', 100000);
    tokens = tokens{:};
catch %#ok
    delimiter = ['[',delimiter, ']'];
    [start, finish] = regexp(str, delimiter);
    if isempty(start)
        tokens = {str};
        return
    end
    tokens = cell(numel(start+1), 1);
    tokens{1} = str(1:start(1)-1);
    start = [start, length(str)+1];
    for i=1:numel(finish)
        tokens{i+1} = str(finish(i)+1:start(i+1)-1);
    end
    tokens = filterCell(tokens, @(c)~isempty(strtrim(c)));
end