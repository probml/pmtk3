function showFigures()
% This function undoes the effect of hideFigures 
%- see it for details.

% This file is from pmtk3.googlecode.com



set(0, 'defaultFigureVisible', 'on');
set(0, 'defaultAxesVisible', 'on');
fullpath = fullfile(tempdir, 'matlabFigShadow');
removePath(fullpath);
if exist(fullfile(fullpath, 'figure.m'), 'file')
    delete(fullfile(fullpath, 'figure.m'));
    delete(fullfile(fullpath, 'axes.m'));
    rmdir(fullpath);
end
warning('on', 'MATLAB:dispatcher:nameConflict')
fprintf('figures will now be displayed again\n');


end
