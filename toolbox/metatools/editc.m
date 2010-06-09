function editc(files)
% Open all of the specified files for editting
for i=1:numel(files)
    edit(files{i});
end
end