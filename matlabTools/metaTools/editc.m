function editc(files)
% Open all of the specified files for editting

% This file is from pmtk3.googlecode.com

for i=1:numel(files)
    edit(files{i});
end
end
