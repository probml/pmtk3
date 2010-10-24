function removeShadows(quiet)
% Remove the shadows created by shadowFunction()

% This file is from pmtk3.googlecode.com

SetDefaultValue(1, 'quiet', false); 
delete(fullfile(tempdir(), 'matlabShadow', '*.m'));
removePath(fullfile(tempdir(), 'matlabShadow')); 
warning('on', 'MATLAB:dispatcher:nameConflict');
if ~quiet
    fprintf('all shadows removed\n'); 
end
end
