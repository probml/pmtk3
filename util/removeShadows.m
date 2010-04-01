function removeShadows()
% Remove the shadows created by shadowFunction()
removePath(fullfile(tempdir(), 'matlabShadow')); 
warning('on', 'MATLAB:dispatcher:nameConflict');

end