function republish(evalCode)
%% Republish the currently open (and selected) PMTK mfile
%
%%

% This file is from pmtk3.googlecode.com

if nargin < 1
    evalCode = true; 
end
w = which(currentlyOpenFile); 

prefix = fullfile(pmtk3Root(), 'demos'); 
if ~startswith(w, prefix)
    error('%s is not a PMTK3 demo', fnameOnly(w)); 
end

f = w(length(prefix)+2:end); 

previewPublished(w, evalCode, fullfile(pmtk3Root(), 'docs', 'demoOutput', fileparts(f))); 




end
