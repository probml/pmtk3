function visdiffOpen()
%% Open Matlab's file comparison tool comparing the first two open docs
% PMTKneedsMatlab 

% This file is from pmtk3.googlecode.com


files = currentlyOpenFiles(); 
if numel(files) < 2
    fprintf('too few documents open\n');
    return
end
visdiff(files{1}, files{2}); 

end
