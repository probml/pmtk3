function lines = readlines(filename,maxlinelen)
% Returns a cell array with the lines of the file converted to numbers (streams)

% This file is from pmtk3.googlecode.com


if nargin<2, maxlinelen=10000; end;
lines = textread(filename,'%s','whitespace','\n','bufsize',maxlinelen);

% remove all characters except a-z and space
Nlines = length(lines);
for i=1:Nlines
  [stream, lines{i}] =  text2stream(lines{i});
end
 
