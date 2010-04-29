function editc(files)
% edit all of the specified files.
    for i=1:numel(files)
       edit(files{i}); 
    end
end