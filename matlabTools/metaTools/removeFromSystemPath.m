function removeFromSystemPath(keyword)
% Remove all of the system paths that contain the keyword, (ignoring case)
% from the system path for the duration of the Matlab session. 
%
%% Example
% removeFromSystemPath('graphviz')
%%

% This file is from pmtk3.googlecode.com

p = winpath(); 
mask = cellfun(@(c)isSubstring(keyword, c, true), p); 
cellfun(@(c)fprintf('removing %s\n', c), p(mask)); 
p = p(~mask); 
setenv('PATH', catString(p, ';')); 


end
