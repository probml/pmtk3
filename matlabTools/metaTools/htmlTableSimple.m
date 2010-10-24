function  htmlTableSimple(varargin)
% Display a Matlab cell array or numeric matrix as an html table
% Similar to htmlTable, but the resulting generated html
% text is very bare bones, and hence easier to edit
% and include in published documents
%
% format can be 'int', 'float' or 'str'
% If str, we assume data{i,j} is a string
% 
% We write to a file called fname (default pmtk3Root/data/tmp.html)
%
%
% Examples
%{

% This file is from pmtk3.googlecode.com

X = rand(2,3); colNames = {'a','b','ccc'}; rowNames={'r1','row 2'};
htmlTableSimple('data', X, 'colNames', colNames, 'rowNames', rowNames)

Y = {'apples', 'bananas'; 'dogs', 'cats'};
htmlTableSimple('data', Y, 'format', 'str', 'title', 'fruits and animals')
%}

folder = fullfile(pmtk3Root(), 'data');
[data, colNames, rowNames, format, fname, ttl] = process_options(varargin, ...
  'data', [], 'colNames', [], 'rowNames', [], 'format', 'float', ...
  'fname', fullfile(folder, 'tmp.html'), 'title', '');

fid = fopen(fname, 'w');
% nested subfunction
  function print(str)
    fprintf(fid, '%s\n', str);
  end

[nrows, ncols] = size(data);
ncolsTbl = ncols;
if ~isempty(rowNames)
  colNames = {'', colNames{:}}; % empty colname for row headers
  ncolsTbl = ncols+1;
end
print('<html>');
print('<TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >');
if ~isempty(ttl)
  %print(sprintf('%s<br><br>\n', ttl));
  print(sprintf('<TR><TH COLSPAN=%g ALIGN=center> %s </font></TH></TR>', ncolsTbl, ttl));
end
print('<TR ALIGN=left>');
for i=1:length(colNames)
  print(sprintf('<TH BGCOLOR=#00CCFF><FONT COLOR=000000>%s</FONT></TH>', colNames{i}));
end
print('</TR>');

for i=1:nrows
  print('<tr>');
  if ~isempty(rowNames)
    print(sprintf('<td BGCOLOR=#00CCFF><FONT COLOR=000000>%s</FONT>', rowNames{i}));
  end
  for j=1:ncols
    %print(sprintf('<td> %5.3f', data(i,j)));
    switch format
      case 'float'
        print(sprintf('<td> %5.3f', data(i,j)));
      case 'int'
         print(sprintf('<td> %d', data(i,j)));
      case 'str'
        print(sprintf('<td> %s', data{i,j}));
    end
  end
end
print('</table>');
print('</html>');
end


