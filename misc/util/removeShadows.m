function removeShadows()
% Remove the shadows created by shadowFunction()
delete(fullfile(tempdir(), 'matlabShadow', '*.m'));
removePath(fullfile(tempdir(), 'matlabShadow')); 
warning('on', 'MATLAB:dispatcher:nameConflict');
fprintf('all shadows removed\n'); 
end