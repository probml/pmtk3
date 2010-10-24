function [s, b] = getFileSize(f)
% Return the size of a file as a formatted string
% The size is in bytes if less than a KB, KB if less than a MB, MB if less
% than a GB, otherwise GB. The string includes the units. If the file
% cannot be found, an empty string is returned. 
%
%% Example
%
% s = getFileSize('mnistAll.mat')
% s =
% 11.3 MB
%%

% This file is from pmtk3.googlecode.com

f = which(f);
if isempty(f)
    s = f;
    return
end
d  = dir(f);
b  = d.bytes; 
kb = b/1024;
mb = kb/1024;
gb = mb/1024;
if gb > 1
    s = sprintf('%.1f GB', mb);
elseif mb > 1
    s = sprintf('%.1f MB', mb);
elseif kb > 1
    s = sprintf('%.1f KB', kb);
else
    s = sprintf('%d B', b);
end




end
