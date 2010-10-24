function writeText(text, fname, append)
% Write text to a file.
%
% WARNING: Any existing text inside fname will be lost unless in append
% mode.
%
% INPUTS:
%
% text  - an N-by-1 cell array of strings written out as N separate lines.
% fname - the name of the output file.
% append - (default=false) if true, the text is appended to the end of the
% file or added to a new file if it doesn't exist. If false, the file, if
% it exists, is completely overwritten by the new text.
%
%%

% This file is from pmtk3.googlecode.com

if ischar(text)
    text = mat2cellRows(text);
end

if nargin < 3, append = false;end

if append
    fid = fopen(fname,'a');
else
    fid = fopen(fname,'w+');
end
if fid < 0
    error('could not open %s',fname);
end
for i=1:numel(text)
    fprintf(fid,'%s\n',text{i});
end
fclose(fid);

end
