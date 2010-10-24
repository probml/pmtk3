function searchAndReplaceLine(fname, oldText, newText)
%% Search and replace a text line in the specified file.
% Both oldText and newText are single strings. To replace multi-line blocks
% of text, run this function several times, once per line, with the
% appropriate inputs. 
%
% If the oldText string occurs multiple times in a file, each occurrence is
% replaced.
%
% This does nothing if no match is found. Matches are strict including case
% and spaces, except for trailing whitespace. 
%
%
%% Example
%
% searchAndReplaceLine('searchAndReplaceLine', '%% Example', '% Example');
%%

% This file is from pmtk3.googlecode.com


f = which(fname); 
src = getText(f); 
dirty = false;
for i=1:numel(src)
   if strcmp(deblank(src{i}), deblank(oldText))
       src{i} = newText;
       dirty = true; 
   end
end
if dirty
   writeText(src, f);  
end
end
