function showFigures()
    
    
    
    set(0, 'defaultFigureVisible', 'on');
    set(0, 'defaultAxesVisible', 'on');
    fullpath = fullfile(tempdir, 'matlabShadow');
    removePath(fullpath);
    if exist(fullfile(fullpath, 'figure.m'), 'file')
        delete(fullfile(fullpath, 'figure.m'));
        delete(fullfile(fullpath, 'axes.m'));
        rmdir(fullpath);
    end
    warning('on', 'MATLAB:dispatcher:nameConflict')
   
    
    
end