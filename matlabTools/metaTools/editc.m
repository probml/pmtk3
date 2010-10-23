function editc(files)
% Open all of the specified files for editting

% This file is from matlabtools.googlecode.com

for i=1:numel(files)
    edit(files{i});
end
end
