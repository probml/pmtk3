function republish()
%% Republish the currently open (and selected) PMTK mfile
%
%%

w = which(currentlyOpenFile); 

prefix = fullfile(pmtk3Root(), 'demos'); 
if ~startswith(w, prefix)
    error('%s is not a PMTK3 demo', fnameOnly(w)); 
end

f = w(length(prefix)+2:end); 

previewPublished(w, true, fullfile(pmtk3Root(), 'docs', 'demoOutput', fileparts(f))); 




end